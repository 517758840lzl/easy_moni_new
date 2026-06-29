package com.ereeko.easymoni

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.Settings
import android.content.Intent
import android.net.Uri
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.Locale

// 短信平台服务：负责短信读取权限和本机短信记录采集。
internal class SmsPlatformService(private val activity: Activity) {
    companion object {
        const val REQUEST_CODE = 1003
    }

    private var pendingSmsResult: MethodChannel.Result? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.SMS).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        activity, Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestSmsPermission" -> requestSmsPermission(result)
                "openAppSettings" -> openAppSettings(result)
                "getSmsRecords" -> getSmsRecords(call, result)
                else -> result.notImplemented()
            }
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE) return false

        pendingSmsResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
        pendingSmsResult = null
        return true
    }

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            pendingSmsResult = result
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.READ_SMS),
                REQUEST_CODE
            )
        } else {
            result.success(true)
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:${activity.packageName}")
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
        } else {
            try {
                result.success(
                    readSmsRecords(
                        keywords = normalizeSmsKeywords(call.argument<List<Any?>>("keywords")),
                        limit = normalizeSmsLimit(call.argument<Any?>("limit"))
                    )
                )
            } catch (e: Exception) {
                result.error("GET_SMS_RECORDS_FAILED", e.message, null)
            }
        }
    }

    private fun readSmsRecords(keywords: List<String>, limit: Int?): List<Map<String, Any>> {
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

    // 统一清洗 Flutter 传入的短信关键词，原生查询只匹配 body 字段。
    private fun normalizeSmsKeywords(rawKeywords: List<Any?>?): List<String> {
        return rawKeywords.orEmpty()
            .mapNotNull { item -> item?.toString()?.trim()?.lowercase(Locale.US) }
            .filter { item -> item.isNotEmpty() }
            .distinct()
    }

    // 限制条数只接受正整数，避免把未校验内容拼入 sortOrder。
    private fun normalizeSmsLimit(rawLimit: Any?): Int? {
        return when (rawLimit) {
            is Number -> rawLimit.toInt()
            is String -> rawLimit.toIntOrNull()
            else -> null
        }?.takeIf { it > 0 }
    }

    // 构造短信正文关键词查询条件，使用参数占位符避免 SQL 注入。
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

    private fun buildSmsSortOrder(limit: Int?): String {
        return if (limit == null) {
            Telephony.Sms.DEFAULT_SORT_ORDER
        } else {
            "${Telephony.Sms.DEFAULT_SORT_ORDER} LIMIT $limit"
        }
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
