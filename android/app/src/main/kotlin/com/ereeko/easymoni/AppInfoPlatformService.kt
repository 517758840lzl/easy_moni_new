package com.ereeko.easymoni

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// 应用信息原生服务：读取安装包中由 Flutter 构建配置写入的版本名。
internal class AppInfoPlatformService(private val activity: Activity) {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.APP_INFO).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVersionName" -> result.success(getVersionName())
                else -> result.notImplemented()
            }
        }
    }

    // versionName 来源于 android/app/build.gradle.kts 中的 flutter.versionName。
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
        } catch (e: Exception) {
            ""
        }
    }
}
