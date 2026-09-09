//
//  Generated file. Do not edit.
//
import Flutter
import UIKit

import app_tracking_transparency
import appsflyer_sdk
import camera_avfoundation
import device_info_plus
import shared_preferences_foundation
import url_launcher_ios
import webview_flutter_wkwebview

@objc public class GeneratedPluginRegistrant: NSObject {
  @objc public static func register(with registry: FlutterPluginRegistry) {
    if let registrar = registry.registrar(forPlugin: "AppTrackingTransparencyPlugin") {
      AppTrackingTransparencyPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "AppsflyerSdkPlugin") {
      AppsflyerSdkPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "CameraPlugin") {
      CameraPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "FPPDeviceInfoPlusPlugin") {
      FPPDeviceInfoPlusPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "SharedPreferencesPlugin") {
      SharedPreferencesPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "URLLauncherPlugin") {
      URLLauncherPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "WebViewFlutterPlugin") {
      WebViewFlutterPlugin.register(with: registrar)
    }
  }
}
