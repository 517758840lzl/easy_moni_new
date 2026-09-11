package com.ereeko.easymoni

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean
import androidx.core.net.toUri

internal class LocationPlatformService(private val activity: Activity) {
    companion object {
        const val REQUEST_CODE = 1001
        private const val LOCATION_TIMEOUT_MS = 10000L
    }

    private val fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(activity)
    private val locationHandler = Handler(Looper.getMainLooper())
    private var channel: MethodChannel? = null
    private var pendingResult: MethodChannel.Result? = null
    private val isShutdown = AtomicBoolean(false)

    fun register(messenger: BinaryMessenger) {
        isShutdown.set(false)
        channel = MethodChannel(messenger, NativeChannels.LOCATION).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkLocationPermission" -> {
                        try {
                            result.success(hasLocationPermission())
                        } catch (e: Exception) {
                            result.error("CHECK_LOCATION_PERMISSION_FAILED", e.message, null)
                        }
                    }
                    "requestLocationPermission" -> requestLocationPermission(result)
                    "isLocationServiceEnabled" -> {
                        try {
                            result.success(isLocationServiceEnabled())
                        } catch (e: Exception) {
                            result.error("CHECK_LOCATION_SERVICE_FAILED", e.message, null)
                        }
                    }
                    "getCurrentLocation" -> getCurrentLocation(result)
                    "openAppSettings" -> openAppSettings(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE) return false

        pendingResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
        pendingResult = null
        return true
    }

    fun shutdown() {
        if (!isShutdown.compareAndSet(false, true)) return

        channel?.setMethodCallHandler(null)
        channel = null
        locationHandler.removeCallbacksAndMessages(null)
        pendingResult?.error("CANCELLED", "Location service was destroyed", null)
        pendingResult = null
    }

    fun requestDeviceInfoLocationSnapshot(onComplete: (DeviceLocationSnapshot?) -> Unit) {
        LOCATION_TIMEOUT_MS.requestCurrentLocationSnapshot { locationResult ->
            onComplete(locationResult.snapshot)
        }
    }

    private fun requestLocationPermission(result: MethodChannel.Result) {
        try {
            if (!hasLocationPermission()) {
                if (pendingResult != null) {
                    result.error("REQUEST_IN_PROGRESS", "Location permission request is already in progress", null)
                    return
                }

                pendingResult = result
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),
                    REQUEST_CODE
                )
            } else {
                result.success(true)
            }
        } catch (e: Exception) {
            pendingResult = null
            result.error("REQUEST_LOCATION_PERMISSION_FAILED", e.message, null)
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = "package:${activity.packageName}".toUri()
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_SETTINGS_FAILED", e.message, null)
        }
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        val resultSent = AtomicBoolean(false)
        LOCATION_TIMEOUT_MS.requestCurrentLocationSnapshot { locationResult ->
            val snapshot = locationResult.snapshot
            if (snapshot != null) {
                sendLocationSuccess(result, resultSent, snapshot)
            } else {
                sendLocationError(
                    result,
                    resultSent,
                    locationResult.errorCode.ifBlank { "LOCATION_UNAVAILABLE" },
                    locationResult.errorMessage.ifBlank { "LOCATION_ERROR" }
                )
            }
        }
    }

    private fun Long.requestCurrentLocationSnapshot(
        onComplete: (DeviceLocationResult) -> Unit
    ) {
        val requestRunnable = Runnable {
            if (isShutdown.get() || activity.isFinishing) return@Runnable

            if (!hasLocationPermission()) {
                onComplete(
                    DeviceLocationResult(
                        errorCode = "PERMISSION_DENIED",
                        errorMessage = "Location permission denied"
                    )
                )
                return@Runnable
            }

            if (!isLocationServiceEnabled()) {
                onComplete(
                    DeviceLocationResult(
                        errorCode = "LOCATION_SERVICE_DISABLED",
                        errorMessage = "Location service disabled"
                    )
                )
                return@Runnable
            }

            val resultSent = AtomicBoolean(false)
            val cancellationTokenSource = CancellationTokenSource()
            var timeoutRunnable: Runnable? = null

            fun complete(locationResult: DeviceLocationResult) {
                if (!resultSent.compareAndSet(false, true)) return
                timeoutRunnable?.let { locationHandler.removeCallbacks(it) }
                if (isShutdown.get() || activity.isFinishing) return
                onComplete(locationResult)
            }

            fun completeWithLocation(location: Location) {
                complete(DeviceLocationResult(snapshot = toDeviceLocationSnapshot(location)))
            }

            fun requestLastKnown(fallbackMessage: String) {
                requestLastKnownLocationSnapshot(fallbackMessage) { locationResult ->
                    complete(locationResult)
                }
            }

            try {
                timeoutRunnable = Runnable {
                    cancellationTokenSource.cancel()
                    requestLastKnown("Current location request timed out")
                }
                locationHandler.postDelayed(timeoutRunnable, this)

                fusedLocationClient
                    .getCurrentLocation(Priority.PRIORITY_BALANCED_POWER_ACCURACY, cancellationTokenSource.token)
                    .addOnSuccessListener { location ->
                        if (location != null) {
                            completeWithLocation(location)
                        } else {
                            requestLastKnown("Current location is unavailable")
                        }
                    }
                    .addOnFailureListener { exception ->
                        requestLastKnown(exception.message ?: "Failed to get current location")
                    }
                    .addOnCanceledListener {
                        requestLastKnown("Current location request was canceled")
                    }
            } catch (e: SecurityException) {
                complete(
                    DeviceLocationResult(
                        errorCode = "PERMISSION_DENIED",
                        errorMessage = e.message ?: "Location permission denied"
                    )
                )
            } catch (e: Exception) {
                requestLastKnown(e.message ?: "Failed to get current location")
            }
        }

        if (Looper.myLooper() == Looper.getMainLooper()) {
            requestRunnable.run()
        } else {
            locationHandler.post(requestRunnable)
        }
    }

    private fun requestLastKnownLocationSnapshot(
        fallbackMessage: String,
        onComplete: (DeviceLocationResult) -> Unit
    ) {
        try {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location ->
                    if (location != null) {
                        onComplete(DeviceLocationResult(snapshot = toDeviceLocationSnapshot(location)))
                    } else {
                        onComplete(
                            DeviceLocationResult(
                                errorCode = "LOCATION_UNAVAILABLE",
                                errorMessage = fallbackMessage
                            )
                        )
                    }
                }
                .addOnFailureListener { exception ->
                    onComplete(
                        DeviceLocationResult(
                            errorCode = "LOCATION_UNAVAILABLE",
                            errorMessage = exception.message ?: fallbackMessage
                        )
                    )
                }
        } catch (e: SecurityException) {
            onComplete(
                DeviceLocationResult(
                    errorCode = "PERMISSION_DENIED",
                    errorMessage = e.message ?: "Location permission denied"
                )
            )
        } catch (e: Exception) {
            onComplete(
                DeviceLocationResult(
                    errorCode = "LOCATION_UNAVAILABLE",
                    errorMessage = e.message ?: fallbackMessage
                )
            )
        }
    }

    private fun sendLocationSuccess(
        result: MethodChannel.Result,
        resultSent: AtomicBoolean,
        location: DeviceLocationSnapshot
    ) {
        if (!resultSent.compareAndSet(false, true)) return

        result.success(
            mapOf(
                "latitude" to location.latitude,
                "longitude" to location.longitude
            )
        )
    }

    private fun sendLocationError(
        result: MethodChannel.Result,
        resultSent: AtomicBoolean,
        code: String,
        message: String
    ) {
        if (!resultSent.compareAndSet(false, true)) return

        result.error(code, message, null)
    }

    private fun hasLocationPermission(): Boolean {
        return try {
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        } catch (_: Exception) {
            false
        }
    }

    private fun isLocationServiceEnabled(): Boolean {
        return try {
            val locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
            locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER) ||
                    locationManager.isProviderEnabled(android.location.LocationManager.NETWORK_PROVIDER)
        } catch (_: Exception) {
            false
        }
    }

    private fun toDeviceLocationSnapshot(location: Location): DeviceLocationSnapshot {
        return DeviceLocationSnapshot(
            location.latitude,
            location.longitude,
            if (isMockLocation(location)) 1 else 0
        )
    }

    private fun isMockLocation(location: Location): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            location.isMock
        } else {
            @Suppress("DEPRECATION")
            location.isFromMockProvider
        }
    }
}

internal data class DeviceLocationSnapshot(
    val latitude: Double,
    val longitude: Double,
    val isMockLocation: Int
)

internal data class DeviceLocationResult(
    val snapshot: DeviceLocationSnapshot? = null,
    val errorCode: String = "",
    val errorMessage: String = ""
)
