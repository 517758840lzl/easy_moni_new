import UIKit
import Flutter
import AVFoundation
import ContactsUI
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CNContactPickerDelegate {
  private var contactPickerResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let messenger = engineBridge.pluginRegistry
      .registrar(forPlugin: "EasyMoniPlatformChannels")?
      .messenger()
    else {
      return
    }

    registerLocationChannel(messenger: messenger)
    registerCameraChannel(messenger: messenger)
    registerContactsChannel(messenger: messenger)
    registerAppInfoChannel(messenger: messenger)
    registerDialerChannel(messenger: messenger)
    registerVisionChannel(messenger: messenger)
  }

  private func registerLocationChannel(messenger: FlutterBinaryMessenger) {
    let locationChannel = FlutterMethodChannel(
      name: "com.easy_moni/location",
      binaryMessenger: messenger
    )

    locationChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "checkLocationPermission":
        result(LocationPermissionHelper.shared.hasWhenInUse())
      case "requestLocationPermission":
        LocationPermissionHelper.shared.requestWhenInUse(result)
      case "getCurrentLocation":
        LocationPermissionHelper.shared.peekLatLng(result)
      case "isLocationServiceEnabled":
        result(CLLocationManager.locationServicesEnabled())
      case "openAppSettings":
        Self.openSystemSettings(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerCameraChannel(messenger: FlutterBinaryMessenger) {
    let cameraChannel = FlutterMethodChannel(
      name: "com.easy_moni/camera",
      binaryMessenger: messenger
    )

    cameraChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "checkCameraPermission":
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
          result(true)
        case .notDetermined, .denied, .restricted:
          result(false)
        @unknown default:
          result(false)
        }
      case "requestCameraPermission":
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
          result(true)
        case .notDetermined:
          AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
              result(granted)
            }
          }
        case .denied, .restricted:
          result(false)
        @unknown default:
          result(false)
        }
      case "openAppSettings":
        Self.openSystemSettings(result: result)
      case "pickFromGallery":
        guard let controller = Self.keyFlutterViewController() else {
          result(FlutterError(code: "unavailable", message: "No Flutter view controller", details: nil))
          return
        }
        GalleryPickerHelper.shared.pickImage(from: controller, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerContactsChannel(messenger: FlutterBinaryMessenger) {
    let contactsChannel = FlutterMethodChannel(
      name: "com.easy_moni/contacts",
      binaryMessenger: messenger
    )

    contactsChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "App delegate released", details: nil))
        return
      }

      switch call.method {
      case "pickContact":
        guard let controller = Self.keyFlutterViewController() else {
          result(FlutterError(code: "unavailable", message: "No Flutter view controller", details: nil))
          return
        }

        let picker = CNContactPickerViewController()
        picker.delegate = self
        self.contactPickerResult = result
        controller.present(picker, animated: true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerAppInfoChannel(messenger: FlutterBinaryMessenger) {
    let appInfoChannel = FlutterMethodChannel(
      name: "com.easy_moni/app_info",
      binaryMessenger: messenger
    )

    appInfoChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "getVersionName":
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        result(versionName)
      case "getVersionCode":
        let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        result(versionCode)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerDialerChannel(messenger: FlutterBinaryMessenger) {
    let dialerChannel = FlutterMethodChannel(
      name: "com.easy_moni/dialer",
      binaryMessenger: messenger
    )

    dialerChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "openDialer":
        let phone = call.arguments as? [String: Any]
        let number = phone?["phone"] as? String ?? ""
        result(CustomerServiceLauncher.openPhoneDialer(phone: number))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerVisionChannel(messenger: FlutterBinaryMessenger) {
    let visionChannel = FlutterMethodChannel(
      name: "com.easy_moni/face_vision",
      binaryMessenger: messenger
    )

    visionChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "warmUp":
        VisionFaceDetector.warmUp()
        result(nil)
      case "detectFromFile":
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "bad_args", message: "path required", details: nil))
          return
        }
        DispatchQueue.global(qos: .userInitiated).async {
          let faces = VisionFaceDetector.detectFromFile(path: path)
          DispatchQueue.main.async { result(faces) }
        }
      case "detectFromBgra":
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData,
              let width = args["width"] as? Int,
              let height = args["height"] as? Int,
              let bytesPerRow = args["bytesPerRow"] as? Int else {
          result(FlutterError(code: "bad_args", message: "bgra frame required", details: nil))
          return
        }
        let sensorOrientation = args["sensorOrientation"] as? Int ?? 90
        let lensFacing = args["lensFacing"] as? String ?? "front"
        DispatchQueue.global(qos: .userInitiated).async {
          let faces = VisionFaceDetector.detectFromBgra(
            bytes: bytes,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            sensorOrientation: sensorOrientation,
            lensFacing: lensFacing
          )
          DispatchQueue.main.async { result(faces) }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func keyFlutterViewController() -> FlutterViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController as? FlutterViewController
  }

  private static func openSystemSettings(result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result(false)
      return
    }

    DispatchQueue.main.async {
      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    }
  }

  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    // 交给 Flutter（SystemChrome.setPreferredOrientations）按页面控制方向。
    return super.application(application, supportedInterfaceOrientationsFor: window)
  }

  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
    let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""

    contactPickerResult?([
      "id": contact.identifier,
      "name": name,
      "phone": phone
    ])
    contactPickerResult = nil
  }

  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    contactPickerResult?(nil)
    contactPickerResult = nil
  }
}
