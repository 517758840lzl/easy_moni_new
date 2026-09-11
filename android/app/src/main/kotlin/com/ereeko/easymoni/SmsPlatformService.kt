package com.ereeko.easymoni

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.Settings
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.Locale
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.atomic.AtomicBoolean
import androidx.core.net.toUri

internal class SmsPlatformService(private val activity: Activity) {
    companion object {
        const val REQUEST_CODE = 1003
        private const val TAG = "SmsPlatformService"
        private const val DEFAULT_SMS_LIMIT = 2000
    }

    private val backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val isShutdown = AtomicBoolean(false)
    private var channel: MethodChannel? = null
    private var pendingSmsResult: MethodChannel.Result? = null
    private var pendingSmsRecordsResult: MethodChannel.Result? = null
    private var smsRecordsTask: Future<*>? = null

    fun register(messenger: BinaryMessenger) {
        isShutdown.set(false)
        channel = MethodChannel(messenger, NativeChannels.SMS).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkSmsPermission" -> {
                        try {
                            val hasPermission = ContextCompat.checkSelfPermission(
                                activity, Manifest.permission.READ_SMS
                            ) == PackageManager.PERMISSION_GRANTED
                            result.success(hasPermission)
                        } catch (e: Exception) {
                            result.error("CHECK_SMS_PERMISSION_FAILED", e.message, null)
                        }
                    }
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "openAppSettings" -> openAppSettings(result)
                    "getSmsRecords" -> getSmsRecords(call, result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE) return false

        pendingSmsResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
        pendingSmsResult = null
        return true
    }

    fun shutdown() {
        if (!isShutdown.compareAndSet(false, true)) return

        channel?.setMethodCallHandler(null)
        channel = null
        smsRecordsTask?.cancel(true)
        smsRecordsTask = null
        backgroundExecutor.shutdownNow()
        pendingSmsResult?.error("CANCELLED", "Sms service was destroyed", null)
        pendingSmsResult = null
        pendingSmsRecordsResult?.error("CANCELLED", "Sms service was destroyed", null)
        pendingSmsRecordsResult = null
    }

    private fun requestSmsPermission(result: MethodChannel.Result) {
        try {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                if (pendingSmsResult != null) {
                    result.error("REQUEST_IN_PROGRESS", "Sms permission request is already in progress", null)
                    return
                }

                pendingSmsResult = result
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_SMS),
                    REQUEST_CODE
                )
            } else {
                result.success(true)
            }
        } catch (e: Exception) {
            pendingSmsResult = null
            result.error("REQUEST_SMS_PERMISSION_FAILED", e.message, null)
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = "package:${activity.packageName}".toUri()
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_SETTINGS_FAILED", e.message, null)
        }
    }

    private fun getSmsRecords(call: MethodCall, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Sms permission denied", null)
            return
        }

        if (pendingSmsRecordsResult != null) {
            result.error("REQUEST_IN_PROGRESS", "Sms records request is already in progress", null)
            return
        }

        pendingSmsRecordsResult = result
        try {
            smsRecordsTask = backgroundExecutor.submit {
                try {
                    val keywords = normalizeSmsKeywords(call.argument<List<Any?>>("keywords"))
                    val limit = normalizeSmsLimit(call.argument<Any?>("limit"))
                    Log.d(TAG, "getSmsRecords keywords=${keywords.size}, limit=$limit, values=$keywords")
                    val smsRecords = readSmsRecords(
                        keywords = keywords,
                        limit = limit
                    )
                    activity.runOnUiThread {
                        if (isShutdown.get() || pendingSmsRecordsResult !== result) return@runOnUiThread
                        result.success(smsRecords)
                        pendingSmsRecordsResult = null
                        smsRecordsTask = null
                    }
                } catch (e: Exception) {
                    activity.runOnUiThread {
                        if (isShutdown.get() || pendingSmsRecordsResult !== result) return@runOnUiThread
                        result.error("GET_SMS_RECORDS_FAILED", e.message, null)
                        pendingSmsRecordsResult = null
                        smsRecordsTask = null
                    }
                }
            }
        } catch (e: RejectedExecutionException) {
            pendingSmsRecordsResult = null
            result.error("GET_SMS_RECORDS_FAILED", e.message, null)
        }
    }

    private fun readSmsRecords(keywords: List<String>, limit: Int): List<Map<String, Any>> {
        val smsRecords = mutableListOf<Map<String, Any>>()
        val selection = buildSmsBodySelection(keywords)
        val cursor: Cursor? = activity.contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.DATE_SENT,
                Telephony.Sms.PERSON,
                Telephony.Sms.TYPE
            ),
            selection.first,
            selection.second,
            buildSmsSortOrder(limit)
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(Telephony.Sms._ID)
            val phoneIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)
            val dateSentIndex = it.getColumnIndex(Telephony.Sms.DATE_SENT)
            val personIndex = it.getColumnIndex(Telephony.Sms.PERSON)
            val typeIndex = it.getColumnIndex(Telephony.Sms.TYPE)

            while (it.moveToNext()) {
                val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
                val phone = if (phoneIndex >= 0) it.getString(phoneIndex) ?: "" else ""
                val body = if (bodyIndex >= 0) it.getString(bodyIndex) ?: "" else ""
                val date = if (dateIndex >= 0) it.getLong(dateIndex) else 0L
                val dateSent = if (dateSentIndex >= 0) it.getLong(dateSentIndex) else 0L
                val person = if (personIndex >= 0) it.getString(personIndex) ?: "" else ""
                val type = if (typeIndex >= 0) it.getInt(typeIndex) else 0

                smsRecords.add(
                    mapOf(
                        "body" to body,
                        "date" to date,
                        "dateSent" to dateSent,
                        "id" to id,
                        "md5" to md5("$id|$phone|$body|$date"),
                        "person" to person,
                        "phone" to phone,
                        "type" to type
                    )
                )
            }
        }

        return smsRecords
    }

    private fun normalizeSmsKeywords(rawKeywords: List<Any?>?): List<String> {
        return rawKeywords.orEmpty()
            .mapNotNull { item -> item?.toString()?.trim()?.lowercase(Locale.US) }
            .filter { item -> item.isNotEmpty() }
            .distinct()
    }

    private fun normalizeSmsLimit(rawLimit: Any?): Int {
        return when (rawLimit) {
            is Number -> rawLimit.toInt()
            is String -> rawLimit.toIntOrNull()
            else -> null
        }?.takeIf { it > 0 } ?: DEFAULT_SMS_LIMIT
    }

    private fun buildSmsBodySelection(keywords: List<String>): Pair<String?, Array<String>?> {
        if (keywords.isEmpty()) {
            return Pair(null, null)
        }

        val clauses = keywords.map { "${Telephony.Sms.BODY} LIKE ? ESCAPE '\\'" }
        val arguments = keywords
            .map { keyword -> "%${escapeLikeKeyword(keyword)}%" }
            .toTypedArray()

        return Pair(clauses.joinToString(separator = " OR ", prefix = "(", postfix = ")"), arguments)
    }

    private fun buildSmsSortOrder(limit: Int): String {
        return "${Telephony.Sms.DEFAULT_SORT_ORDER} LIMIT $limit"
    }

    private fun escapeLikeKeyword(keyword: String): String {
        return keyword
            .replace("\\", "\\\\")
            .replace("%", "\\%")
            .replace("_", "\\_")
    }

    private fun md5(value: String): String {
        val digest = MessageDigest.getInstance("MD5").digest(value.toByteArray())
        return digest.joinToString("") { "%02x".format(it.toInt() and 0xff) }
    }
}
