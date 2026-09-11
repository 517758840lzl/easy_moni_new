package com.ereeko.easymoni

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

internal class DialerPlatformService(private val activity: Activity) {
    private var channel: MethodChannel? = null

    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, NativeChannels.DIALER).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "openDialer" -> {
                        try {
                            val phone = call.argument<String>("phone")?.trim().orEmpty()
                            val intent = Intent(Intent.ACTION_DIAL).apply {
                                data = "tel:$phone".toUri()
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

    fun shutdown() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
