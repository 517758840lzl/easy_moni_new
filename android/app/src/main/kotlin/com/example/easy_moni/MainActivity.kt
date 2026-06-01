package com.example.easy_moni

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val LOCATION_CHANNEL = "com.easy_moni/location"
    private val CONTACTS_CHANNEL = "com.easy_moni/contacts"
    private val CAMERA_CHANNEL = "com.easy_moni/camera"
    
    private var pendingResult: MethodChannel.Result? = null
    private var pendingContactsResult: MethodChannel.Result? = null
    private var pendingCameraResult: MethodChannel.Result? = null
    private var currentPhotoPath: String? = null
    private var isFrontCamera: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ============ 位置服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkLocationPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.ACCESS_COARSE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestLocationPermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        pendingResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),
                            1001
                        )
                    } else {
                        result.success(true)
                    }
                }
                "isLocationServiceEnabled" -> {
                    val locationManager = getSystemService(LOCATION_SERVICE) as android.location.LocationManager
                    result.success(locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER) ||
                            locationManager.isProviderEnabled(android.location.LocationManager.NETWORK_PROVIDER))
                }
                "getCurrentLocation" -> {
                    // Android 原生获取位置需要 Google Play Services，这里简化处理
                    result.error("NOT_SUPPORTED", "请使用手动选择", null)
                }
                else -> result.notImplemented()
            }
        }

        // ============ 通讯录服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACTS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkContactsPermission" -> {
//                    val hasPermission = ContextCompat.checkSelfPermission(
//                        this, Manifest.permission.READ_CONTACTS
//                    ) == PackageManager.PERMISSION_GRANTED
//                    result.success(hasPermission)
                    result.success(false)
                }
                "requestContactsPermission" -> {
                    result.success(false)
                }
                "getContacts" -> {
                    result.error("PERMISSION_DISABLED", "Contacts permission disabled on Android", null)
                }
                else -> result.notImplemented()
            }
        }

        // ============ 相机/相册服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFromGallery" -> {
                    isFrontCamera = false
                    val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
                    intent.type = "image/*"
                    pendingCameraResult = result
                    startActivityForResult(intent, 2001)
                }
                "takePhoto" -> {
                    isFrontCamera = false
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        pendingCameraResult = result
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 1003)
                    } else {
                        openCamera(result)
                    }
                }
                "checkCameraPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openCamera(result: MethodChannel.Result) {
        val photoFile: File? = try {
            createImageFile()
        } catch (ex: IOException) {
            result.error("ERROR", "Could not create image file", null)
            return
        }
        photoFile?.also {
            val photoURI: Uri = FileProvider.getUriForFile(
                this,
                "${packageName}.fileprovider",
                it
            )
            val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
            pendingCameraResult = result
            startActivityForResult(takePictureIntent, 2002)
        }
    }

    private fun createImageFile(): File {
        val timeStamp = System.currentTimeMillis()
        val imageFileName = "JPEG_${timeStamp}_"
        val storageDir = getExternalFilesDir(null)
        return File.createTempFile(imageFileName, ".jpg", storageDir).also {
            currentPhotoPath = it.absolutePath
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            2001 -> { // Gallery
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
            }
            2002 -> { // Camera
                if (resultCode == Activity.RESULT_OK) {
                    currentPhotoPath?.let { path ->
                        try {
                            val bitmap = BitmapFactory.decodeFile(path)
                            val base64 = bitmapToBase64(bitmap)
                            // 删除临时文件
                            File(path).delete()
                            pendingCameraResult?.success(base64)
                        } catch (e: Exception) {
                            pendingCameraResult?.error("ERROR", e.message, null)
                        }
                    } ?: pendingCameraResult?.error("ERROR", "No photo path", null)
                } else {
                    // 删除临时文件
                    currentPhotoPath?.let { File(it).delete() }
                    pendingCameraResult?.success(null)
                }
                pendingCameraResult = null
                currentPhotoPath = null
            }
        }
    }

    private fun getBase64FromUri(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream?.close()
            bitmapToBase64(bitmap)
        } catch (e: Exception) {
            null
        }
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
        val byteArray = outputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            1001 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingResult?.success(true)
                } else {
                    pendingResult?.success(false)
                }
                pendingResult = null
            }
            1002 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingContactsResult?.success(true)
                } else {
                    pendingContactsResult?.success(false)
                }
                pendingContactsResult = null
            }
            1003 -> { // Camera permission
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    openCamera(pendingCameraResult!!)
                } else {
                    pendingCameraResult?.error("PERMISSION_DENIED", "Camera permission denied", null)
                }
                pendingCameraResult = null
            }
        }
    }
}
