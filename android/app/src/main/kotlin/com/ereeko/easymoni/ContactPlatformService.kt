package com.ereeko.easymoni

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.provider.ContactsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// 通讯录平台服务：负责打开联系人选择器并解析选中的联系人数据。
internal class ContactPlatformService(private val activity: Activity) {
    companion object {
        const val PICK_CONTACT_REQUEST_CODE = 2002
    }

    private var channel: MethodChannel? = null
    private var pendingPickContactResult: MethodChannel.Result? = null

    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, NativeChannels.CONTACTS).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickContact" -> pickContact(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_CONTACT_REQUEST_CODE) return false

        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            try {
                pendingPickContactResult?.success(getContactFromUri(data.data!!))
            } catch (e: Exception) {
                pendingPickContactResult?.error("PICK_CONTACT_FAILED", e.message, null)
            }
        } else {
            pendingPickContactResult?.success(null)
        }
        pendingPickContactResult = null
        return true
    }

    fun shutdown() {
        channel?.setMethodCallHandler(null)
        channel = null
        pendingPickContactResult?.error("CANCELLED", "Contact service was destroyed", null)
        pendingPickContactResult = null
    }

    private fun pickContact(result: MethodChannel.Result) {
        try {
            if (pendingPickContactResult != null) {
                result.error("REQUEST_IN_PROGRESS", "Contact picker request is already in progress", null)
                return
            }

            val intent = Intent(
                Intent.ACTION_PICK,
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI
            )
            // 避免连续联系人选择请求覆盖上一笔 Flutter Result，导致前一个 Future 无法结束。
            pendingPickContactResult = result
            activity.startActivityForResult(intent, PICK_CONTACT_REQUEST_CODE)
        } catch (e: Exception) {
            pendingPickContactResult = null
            result.error("PICK_CONTACT_FAILED", e.message, null)
        }
    }

    private fun getContactFromUri(uri: android.net.Uri): Map<String, String>? {
        val cursor: Cursor? = activity.contentResolver.query(
            uri,
            arrayOf(
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER
            ),
            null,
            null,
            null
        )

        cursor?.use {
            if (!it.moveToFirst()) return null

            val idIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
            val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val phoneIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

            val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
            val name = if (nameIndex >= 0) it.getString(nameIndex) ?: "" else ""
            val phone = if (phoneIndex >= 0) it.getString(phoneIndex)?.replace("\\s".toRegex(), "") ?: "" else ""

            return mapOf(
                "id" to id,
                "name" to name,
                "phone" to phone
            )
        }

        return null
    }
}
