package com.ereeko.easymoni

import android.app.Activity
import android.os.Build
import android.provider.Settings
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

// 归因平台服务：负责广告 ID、安装来源和基础设备归因字段。
internal class AttributionPlatformService(private val activity: Activity) {
    private val backgroundExecutor = Executors.newSingleThreadExecutor()

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.ATTRIBUTION).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAttributionData" -> {
                    backgroundExecutor.execute {
                        try {
                            val data = getAttributionData()
                            activity.runOnUiThread { result.success(data) }
                        } catch (e: Exception) {
                            activity.runOnUiThread { result.error("GET_ATTRIBUTION_FAILED", e.message, null) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    fun shutdown() {
        backgroundExecutor.shutdownNow()
    }

    fun getAdvertisingId(): String {
        return try {
            val info = AdvertisingIdClient.getAdvertisingIdInfo(activity)
            info?.id ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    private fun getAttributionData(): Map<String, Any> {
        val gaid = getAdvertisingId()
        return mapOf(
            "gaid" to gaid,
            "advId" to gaid,
            "referrer" to getInstallReferrer(),
            "deviceId" to (Settings.Secure.getString(activity.contentResolver, Settings.Secure.ANDROID_ID) ?: ""),
            "userAgent" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "packageName" to activity.packageName
        )
    }

    private fun getInstallReferrer(): String {
        val latch = CountDownLatch(1)
        var referrer = ""
        var client: InstallReferrerClient? = null

        return try {
            val referrerClient = InstallReferrerClient.newBuilder(activity).build()
            client = referrerClient
            referrerClient.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    try {
                        if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                            referrer = referrerClient.installReferrer.installReferrer ?: ""
                        }
                    } catch (_: Exception) {
                        referrer = ""
                    } finally {
                        latch.countDown()
                    }
                }

                override fun onInstallReferrerServiceDisconnected() {
                    latch.countDown()
                }
            })
            latch.await(3, TimeUnit.SECONDS)
            referrer
        } catch (e: Exception) {
            ""
        } finally {
            try {
                client?.endConnection()
            } catch (_: Exception) {
            }
        }
    }
}
