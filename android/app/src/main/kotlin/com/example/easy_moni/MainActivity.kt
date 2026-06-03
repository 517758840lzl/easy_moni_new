package com.example.easy_moni

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.Settings
import android.provider.MediaStore
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val LOCATION_CHANNEL = "com.easy_moni/location"
    private val CONTACTS_CHANNEL = "com.easy_moni/contacts"
    private val CAMERA_CHANNEL = "com.easy_moni/camera"
    
    private var pendingResult: MethodChannel.Result? = null
    private var pendingContactsResult: MethodChannel.Result? = null
    private var pendingCameraResult: MethodChannel.Result? = null

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
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.READ_CONTACTS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestContactsPermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
                        pendingContactsResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.READ_CONTACTS),
                            1002
                        )
                    } else {
                        result.success(true)
                    }
                }
                "getContacts" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
                        result.error("PERMISSION_DENIED", "Contacts permission denied", null)
                    } else {
                        try {
                            result.success(getContacts())
                        } catch (e: Exception) {
                            result.error("GET_CONTACTS_FAILED", e.message, null)
                        }
                    }
                }
                "openAppSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OPEN_SETTINGS_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ============ 相机/相册服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFromGallery" -> {
                    val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
                    intent.type = "image/*"
                    pendingCameraResult = result
                    startActivityForResult(intent, 2001)
                }
                else -> result.notImplemented()
            }
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
        }
    }

    private fun getBase64FromUri(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri)
            val bytes = inputStream?.use { it.readBytes() }
            if (bytes == null || bytes.isEmpty()) null else Base64.encodeToString(bytes, Base64.NO_WRAP)
        } catch (e: Exception) {
            null
        }
    }

    private fun getContacts(): List<Map<String, String>> {
        val contacts = mutableListOf<Map<String, String>>()
        val seenContacts = mutableSetOf<String>()
        val cursor: Cursor? = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER
            ),
            null,
            null,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
            val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val phoneIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

            while (it.moveToNext()) {
                val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
                val name = if (nameIndex >= 0) it.getString(nameIndex) ?: "" else ""
                val phone = if (phoneIndex >= 0) it.getString(phoneIndex)?.replace("\\s".toRegex(), "") ?: "" else ""
                if (phone.isEmpty()) continue

                val key = "$name-$phone"
                if (!seenContacts.add(key)) continue

                contacts.add(
                    mapOf(
                        "id" to id,
                        "name" to name,
                        "phone" to phone
                    )
                )
            }
        }

        return contacts
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
        }
    }
}
