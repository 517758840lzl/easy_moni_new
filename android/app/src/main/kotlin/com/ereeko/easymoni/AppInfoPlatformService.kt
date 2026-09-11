package com.ereeko.easymoni

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class AppInfoPlatformService(private val activity: Activity) {
    private var appInfoChannel: MethodChannel? = null
    private var appTaskChannel: MethodChannel? = null

    fun register(messenger: BinaryMessenger) {
        appInfoChannel = MethodChannel(messenger, NativeChannels.APP_INFO).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getVersionName" -> result.success(getVersionName())
                    "getVersionCode" -> result.success(getVersionCode())
                    else -> result.notImplemented()
                }
            }
        }
        appTaskChannel = MethodChannel(messenger, NativeChannels.APP_TASK).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "moveTaskToBack" -> result.success(activity.moveTaskToBack(true))
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun shutdown() {
        appInfoChannel?.setMethodCallHandler(null)
        appInfoChannel = null
        appTaskChannel?.setMethodCallHandler(null)
        appTaskChannel = null
    }

    private fun getVersionName(): String {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.packageManager.getPackageInfo(
                    activity.packageName,
                    PackageManager.PackageInfoFlags.of(0L)
                )
            } else {
                @Suppress("DEPRECATION")
                activity.packageManager.getPackageInfo(activity.packageName, 0)
            }
            packageInfo.versionName ?: ""
        } catch (_: Exception) {
            ""
        }
    }

    private fun getVersionCode(): String {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.packageManager.getPackageInfo(
                    activity.packageName,
                    PackageManager.PackageInfoFlags.of(0L)
                )
            } else {
                @Suppress("DEPRECATION")
                activity.packageManager.getPackageInfo(activity.packageName, 0)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode.toString()
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toString()
            }
        } catch (_: Exception) {
            ""
        }
    }
}
