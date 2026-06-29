package com.ereeko.easymoni

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// 拨号盘平台服务：负责跳转系统拨号界面。
internal class DialerPlatformService(private val activity: Activity) {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.DIALER).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDialer" -> {
                    try {
                        val phone = call.argument<String>("phone")?.trim().orEmpty()
                        val intent = Intent(Intent.ACTION_DIAL).apply {
                            data = Uri.parse("tel:$phone")
                        }
                        activity.startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OPEN_DIALER_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
