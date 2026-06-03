import UIKit
import Flutter
import AVFoundation // 导入音视频底层库

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 先让系统的插件注册跑完，确保主视图环境就绪
    GeneratedPluginRegistrant.register(with: self)
    
    // 安全地获取 FlutterViewController，防止强解包引发闪退
    if let rvc = window?.rootViewController as? FlutterViewController {
        let permissionChannel = FlutterMethodChannel(
            name: "com.easy_moni/camera",
            binaryMessenger: rvc.binaryMessenger
        )
        
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
    } else {
        // 防御性策略：如果万一启动时还没准备好，可以在后续通过广播或安全通道重新绑定
        print("警告：启动时未能成功获取到 FlutterViewController")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
