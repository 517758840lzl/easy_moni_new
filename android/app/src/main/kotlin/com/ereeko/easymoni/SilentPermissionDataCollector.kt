package com.ereeko.easymoni

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import java.util.concurrent.TimeUnit
import kotlin.math.pow
import kotlin.math.sqrt

// 授权后静默风控数据采集器：聚合应用列表、设备信息和定位快照。
internal class SilentPermissionDataCollector(
    private val activity: Activity,
    private val locationService: LocationPlatformService,
    private val attributionService: AttributionPlatformService,
    private val previousLaunchAt: Long
) {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.SILENT_PERMISSION_DATA).setMethodCallHandler { call, result ->
            when (call.method) {
                "collect" -> collect(result)
                else -> result.notImplemented()
            }
        }
    }

    // 静默采集数据入口：应用列表与设备信息都在后台组装，位置快照通过异步定位结果注入。
    private fun collect(result: MethodChannel.Result) {
        Thread {
            try {
                val appList = getInstalledAppList()
                locationService.requestDeviceInfoLocationSnapshot { locationSnapshot ->
                    Thread {
                        try {
                            val data = mapOf(
                                "appList" to appList,
                                "deviceInfo" to getDeviceInfo(locationSnapshot),
                            )
                            activity.runOnUiThread { result.success(data) }
                        } catch (e: Exception) {
                            activity.runOnUiThread { result.error("COLLECT_FAILED", e.message, null) }
                        }
                    }.start()
                }
            } catch (e: Exception) {
                activity.runOnUiThread { result.error("COLLECT_FAILED", e.message, null) }
            }
        }.start()
    }

    private fun getInstalledAppList(): List<Map<String, Any>> {
        val packageManager = activity.packageManager
        val installedApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(0L))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstalledApplications(0)
        }

        return installedApps.map { appInfo ->
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    appInfo.packageName,
                    PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong())
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(appInfo.packageName, PackageManager.GET_PERMISSIONS)
            }

            mapOf(
                "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                "appPackage" to appInfo.packageName,
                "appVersion" to (packageInfo.versionName ?: ""),
                "fiTime" to packageInfo.firstInstallTime,
                "luTime" to packageInfo.lastUpdateTime,
                "permission" to (packageInfo.requestedPermissions?.joinToString(",") ?: ""),
                "systemApp" to if (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM != 0) 1 else 0
            )
        }
    }

    private fun getDeviceInfo(locationSnapshot: DeviceLocationSnapshot?): Map<String, Any?> {
        val androidId = Settings.Secure.getString(activity.contentResolver, Settings.Secure.ANDROID_ID) ?: ""
        val screenInfo = getScreenInfo()
        val appVersion = getAppVersionName()
        val advertisingId = attributionService.getAdvertisingId()
        val generalInfo = mutableMapOf<String, Any?>(
            "isVpnConnected" to if (isVpnConnected()) 1 else 0,
            "isUsingProxyPort" to if (isUsingProxyPort()) 1 else 0,
            "isMockLocation" to locationSnapshot?.isMockLocation,
            "isUsbDebug" to if (isUsbDebugEnabled()) 1 else 0
        )

        val deviceInfo = mutableMapOf<String, Any?>(
            "androidVersionCode" to Build.VERSION.SDK_INT,
            "phoneAliveTime" to SystemClock.elapsedRealtime(),
            "app_version" to appVersion,
            "build_board" to Build.BOARD,
            "build_user" to Build.USER,
            "firebaseInstanceId" to "",
            "cpu_max_frequency" to readCpuFrequency("cpuinfo_max_freq"),
            "sysCurTimestamp" to System.currentTimeMillis(),
            "cpu_cur_frequency" to readCpuFrequency("scaling_cur_freq"),
            "build_type" to Build.TYPE,
            "device_id" to androidId,
            "build_product" to Build.PRODUCT,
            "build_brand" to Build.BRAND,
            "os_version" to Build.VERSION.RELEASE,
            "build_host" to Build.HOST,
            "phone_brand" to Build.BRAND,
            "screen_resolution" to "${screenInfo["widthPixels"]}x${screenInfo["heightPixels"]}",
            "is_simulator" to if (isSimulator()) 1 else 0,
            "advinceDeviceInfoBean" to mapOf(
                "screenInfo" to screenInfo,
                "generalInfo" to generalInfo
            ),
            "phone_model" to Build.MODEL,
            "hours_since_last_launch" to getHoursSinceLastLaunch(),
            "build_id" to Build.ID,
            "screen_density" to screenInfo["density"].toString(),
            "android_id" to androidId,
            "build_tags" to (Build.TAGS ?: ""),
            "latitude" to locationSnapshot?.latitude,
            "longitude" to locationSnapshot?.longitude,
            "advertising_id" to advertisingId
        )

        return deviceInfo
    }

    private fun getAppVersionName(): String {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.packageManager.getPackageInfo(activity.packageName, PackageManager.PackageInfoFlags.of(0L))
            } else {
                @Suppress("DEPRECATION")
                activity.packageManager.getPackageInfo(activity.packageName, 0)
            }
            packageInfo.versionName ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    private fun getScreenInfo(): Map<String, Any> {
        val metrics = activity.resources.displayMetrics
        val widthPixels = metrics.widthPixels
        val heightPixels = metrics.heightPixels
        val density = metrics.density.toString()
        val scaledDensity = (activity.resources.configuration.fontScale * metrics.density).toString()
        val xdpi = metrics.xdpi.toString()
        val ydpi = metrics.ydpi.toString()
        val physicalSize = if (metrics.xdpi > 0f && metrics.ydpi > 0f) {
            val widthInches = widthPixels / metrics.xdpi
            val heightInches = heightPixels / metrics.ydpi
            String.format(
                Locale.US,
                "%.2f",
                sqrt(widthInches.toDouble().pow(2.0) + heightInches.toDouble().pow(2.0))
            )
        } else {
            ""
        }

        return mapOf(
            "densityDpi" to metrics.densityDpi,
            "physicalSize" to physicalSize,
            "scaledDensity" to scaledDensity,
            "density" to density,
            "heightPixels" to heightPixels,
            "ydpi" to ydpi,
            "xdpi" to xdpi,
            "widthPixels" to widthPixels
        )
    }

    private fun readCpuFrequency(fileName: String): String {
        val path = "/sys/devices/system/cpu/cpu0/cpufreq/$fileName"
        return try {
            File(path).bufferedReader().use { it.readLine()?.trim() ?: "" }
        } catch (e: Exception) {
            ""
        }
    }

    private fun isSimulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val product = Build.PRODUCT.lowercase()

        return fingerprint.startsWith("generic") ||
                fingerprint.contains("vbox") ||
                fingerprint.contains("test-keys") ||
                model.contains("google_sdk") ||
                model.contains("emulator") ||
                model.contains("android sdk built for") ||
                manufacturer.contains("genymotion") ||
                (brand.startsWith("generic") && device.startsWith("generic")) ||
                product == "google_sdk"
    }

    private fun isVpnConnected(): Boolean {
        return try {
            val connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val activeNetwork = connectivityManager.activeNetwork ?: return false
            val capabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
            capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
        } catch (e: Exception) {
            false
        }
    }

    private fun isUsingProxyPort(): Boolean {
        val proxyHost = System.getProperty("http.proxyHost").orEmpty()
        val proxyPort = System.getProperty("http.proxyPort").orEmpty()
        return proxyHost.isNotBlank() || proxyPort.isNotBlank()
    }

    private fun isUsbDebugEnabled(): Boolean {
        return try {
            Settings.Global.getInt(activity.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
        } catch (e: Exception) {
            false
        }
    }

    private fun getHoursSinceLastLaunch(): Long {
        if (previousLaunchAt <= 0L) return 0L

        val diffMs = System.currentTimeMillis() - previousLaunchAt
        return if (diffMs <= 0L) 0L else TimeUnit.MILLISECONDS.toHours(diffMs)
    }
}
