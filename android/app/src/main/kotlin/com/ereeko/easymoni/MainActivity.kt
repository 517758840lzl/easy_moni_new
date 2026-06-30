package com.ereeko.easymoni

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        private const val DEVICE_INFO_PREFS = "device_info_prefs"
        private const val KEY_LAST_LAUNCH_AT = "last_launch_at"
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
        super.onCreate(savedInstanceState)

        // 风控设备信息需要上一次启动时间，用于计算距上次启动的小时数。
        val prefs = getSharedPreferences(DEVICE_INFO_PREFS, Context.MODE_PRIVATE)
        previousLaunchAt = prefs.getLong(KEY_LAST_LAUNCH_AT, 0L)
        prefs.edit().putLong(KEY_LAST_LAUNCH_AT, System.currentTimeMillis()).apply()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (contactService.handleActivityResult(requestCode, resultCode, data)) return
        if (cameraService.handleActivityResult(requestCode, resultCode, data)) return
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (locationService.handlePermissionResult(requestCode, grantResults)) return
        if (smsService.handlePermissionResult(requestCode, grantResults)) return
        if (cameraService.handlePermissionResult(requestCode, grantResults)) return
    }
}
