package com.ereeko.easymoni

// 原生通道名称集中管理，避免各业务模块重复硬编码。
internal object NativeChannels {
    const val LOCATION = "com.easy_moni/location"
    const val CONTACTS = "com.easy_moni/contacts"
    const val SMS = "com.easy_moni/sms"
    const val CAMERA = "com.easy_moni/camera"
    const val DIALER = "com.easy_moni/dialer"
    const val APP_INFO = "com.easy_moni/app_info"
    const val ATTRIBUTION = "com.easy_moni/attribution"
    const val SILENT_PERMISSION_DATA = "com.easy_moni/silent_permission_data"
    const val WEBVIEW = "com.easy_moni/webview"
}
