package com.ereeko.easymoni

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.MediaStore
import android.provider.Settings
import android.net.Uri
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// 相机相册平台服务：负责相机权限、相册选择和图片 Base64 转换。
internal class CameraPlatformService(private val activity: Activity) {
    companion object {
        const val CAMERA_PERMISSION_REQUEST_CODE = 1004
        const val PICK_GALLERY_REQUEST_CODE = 2001
    }

    private var pendingCameraPermissionResult: MethodChannel.Result? = null
    private var pendingCameraResult: MethodChannel.Result? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NativeChannels.CAMERA).setMethodCallHandler { call, result ->
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

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != CAMERA_PERMISSION_REQUEST_CODE) return false

        pendingCameraPermissionResult?.success(
            grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        )
        pendingCameraPermissionResult = null
        return true
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_GALLERY_REQUEST_CODE) return false

        if (resultCode == Activity.RESULT_OK && data != null) {
            val selectedImageUri = data.data
            if (selectedImageUri != null) {
                try {
                    val base64 = getBase64FromUri(selectedImageUri)
                    if (base64 != null) {
                        pendingCameraResult?.success(base64)
                    } else {
                        pendingCameraResult?.error("ERROR", "Could not read image", null)
                    }
                } catch (e: Exception) {
                    pendingCameraResult?.error("ERROR", e.message, null)
                }
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
                data = Uri.parse("package:${activity.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_SETTINGS_FAILED", e.message, null)
        }
    }

    private fun pickFromGallery(result: MethodChannel.Result) {
        try {
            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            intent.type = "image/*"
            pendingCameraResult = result
            activity.startActivityForResult(intent, PICK_GALLERY_REQUEST_CODE)
        } catch (e: Exception) {
            pendingCameraResult = null
            result.error("PICK_GALLERY_FAILED", e.message, null)
        }
    }

    private fun getBase64FromUri(uri: Uri): String? {
        return try {
            val inputStream = activity.contentResolver.openInputStream(uri)
            val bytes = inputStream?.use { it.readBytes() }
            if (bytes == null || bytes.isEmpty()) null else Base64.encodeToString(bytes, Base64.NO_WRAP)
        } catch (e: Exception) {
            null
        }
    }
}
