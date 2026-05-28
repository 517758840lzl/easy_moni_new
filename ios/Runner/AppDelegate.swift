import UIKit
import Flutter
import AVFoundation // 导入音视频底层库

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let permissionChannel = FlutterMethodChannel(name: "com.easy_moni/camera",
                                              binaryMessenger: controller.binaryMessenger)
    
    // 监听来自 Flutter 的调用
    permissionChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "checkCameraPermission" {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            result(true) // 已经有权限
        case .notDetermined:
            // 还没申请过，发起 iOS 原生系统弹窗
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    result(granted) // 返回用户勾选的结果
                }
            }
        case .denied, .restricted:
            result(false) // 被拒绝了
        @unknown default:
            result(false)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
