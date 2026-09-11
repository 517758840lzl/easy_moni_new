package com.ereeko.easymoni

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.provider.Settings
import android.net.Uri
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.atomic.AtomicBoolean
import androidx.core.net.toUri

internal class CameraPlatformService(private val activity: Activity) {
    companion object {
        const val CAMERA_PERMISSION_REQUEST_CODE = 1004
        const val PICK_GALLERY_REQUEST_CODE = 2001
        private const val MAX_GALLERY_IMAGE_SIZE = 1600
        private const val GALLERY_IMAGE_JPEG_QUALITY = 85
    }

    private val backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val isShutdown = AtomicBoolean(false)
    private var channel: MethodChannel? = null
    private var pendingCameraPermissionResult: MethodChannel.Result? = null
    private var pendingCameraResult: MethodChannel.Result? = null
    private var galleryTask: Future<*>? = null

    fun register(messenger: BinaryMessenger) {
        isShutdown.set(false)
        channel = MethodChannel(messenger, NativeChannels.CAMERA).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkCameraPermission" -> {
                        try {
                            val hasPermission = ContextCompat.checkSelfPermission(
                                activity, Manifest.permission.CAMERA
                            ) == PackageManager.PERMISSION_GRANTED
                            result.success(hasPermission)
                        } catch (e: Exception) {
                            result.error("CHECK_CAMERA_PERMISSION_FAILED", e.message, null)
                        }
                    }
                    "requestCameraPermission" -> requestCameraPermission(result)
                    "openAppSettings" -> openAppSettings(result)
                    "pickFromGallery" -> pickFromGallery(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != CAMERA_PERMISSION_REQUEST_CODE) return false

        pendingCameraPermissionResult?.success(
            grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        )
        pendingCameraPermissionResult = null
        return true
    }

    fun shutdown() {
        if (!isShutdown.compareAndSet(false, true)) return

        channel?.setMethodCallHandler(null)
        channel = null
        galleryTask?.cancel(true)
        galleryTask = null
        backgroundExecutor.shutdownNow()
        pendingCameraPermissionResult?.error("CANCELLED", "Camera service was destroyed", null)
        pendingCameraPermissionResult = null
        pendingCameraResult?.error("CANCELLED", "Camera service was destroyed", null)
        pendingCameraResult = null
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_GALLERY_REQUEST_CODE) return false

        if (resultCode == Activity.RESULT_OK && data != null) {
            val selectedImageUri = data.data
            if (selectedImageUri != null) {
                val result = pendingCameraResult
                try {
                    galleryTask = backgroundExecutor.submit {
                        try {
                            val bytes = getBytesFromUri(selectedImageUri)
                            activity.runOnUiThread {
                                if (isShutdown.get() || pendingCameraResult !== result) return@runOnUiThread
                                if (bytes != null) {
                                    result?.success(bytes)
                                } else {
                                    result?.error("ERROR", "Could not read image", null)
                                }
                                pendingCameraResult = null
                                galleryTask = null
                            }
                        } catch (e: Exception) {
                            activity.runOnUiThread {
                                if (isShutdown.get() || pendingCameraResult !== result) return@runOnUiThread
                                result?.error("ERROR", e.message, null)
                                pendingCameraResult = null
                                galleryTask = null
                            }
                        }
                    }
                } catch (e: RejectedExecutionException) {
                    if (pendingCameraResult === result) {
                        result?.error("ERROR", e.message, null)
                        pendingCameraResult = null
                    }
                }
                return true
            } else {
                pendingCameraResult?.error("ERROR", "No image selected", null)
            }
        } else {
            pendingCameraResult?.success(null)
        }
        pendingCameraResult = null
        return true
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        try {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                if (pendingCameraPermissionResult != null) {
                    result.error("REQUEST_IN_PROGRESS", "Camera permission request is already in progress", null)
                    return
                }

                pendingCameraPermissionResult = result
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            } else {
                result.success(true)
            }
        } catch (e: Exception) {
            pendingCameraPermissionResult = null
            result.error("REQUEST_CAMERA_PERMISSION_FAILED", e.message, null)
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

    @SuppressLint("IntentReset")
    private fun pickFromGallery(result: MethodChannel.Result) {
        try {
            if (pendingCameraResult != null) {
                result.error("REQUEST_IN_PROGRESS", "Gallery picker request is already in progress", null)
                return
            }

            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            intent.type = "image/*"
            pendingCameraResult = result
            activity.startActivityForResult(intent, PICK_GALLERY_REQUEST_CODE)
        } catch (e: Exception) {
            pendingCameraResult = null
            result.error("PICK_GALLERY_FAILED", e.message, null)
        }
    }

    private fun getBytesFromUri(uri: Uri): ByteArray? {
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            activity.contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it, null, bounds)
            }

            val options = BitmapFactory.Options().apply {
                inSampleSize = calculateInSampleSize(bounds)
            }
            val bitmap = activity.contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it, null, options)
            } ?: return null

            ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, GALLERY_IMAGE_JPEG_QUALITY, output)
                bitmap.recycle()
                output.toByteArray().takeIf { it.isNotEmpty() }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options): Int {
        val height = options.outHeight
        val width = options.outWidth
        var sampleSize = 1

        while (
            height / sampleSize > MAX_GALLERY_IMAGE_SIZE ||
            width / sampleSize > MAX_GALLERY_IMAGE_SIZE
        ) {
            sampleSize *= 2
        }

        return sampleSize
    }
}
