import UIKit
import Flutter
import AVFoundation
import ContactsUI
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CNContactPickerDelegate {
  private var contactPickerResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let rvc = window?.rootViewController as? FlutterViewController {
      let locationChannel = FlutterMethodChannel(
        name: "com.easy_moni/location",
        binaryMessenger: rvc.binaryMessenger
      )

      locationChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "checkLocationPermission" {
          let status = CLLocationManager.authorizationStatus()

          switch status {
          case .authorizedAlways, .authorizedWhenInUse:
            result(true)
          case .notDetermined, .denied, .restricted:
            result(false)
          @unknown default:
            result(false)
          }
        } else if call.method == "isLocationServiceEnabled" {
          result(CLLocationManager.locationServicesEnabled())
        } else if call.method == "openAppSettings" {
          guard let url = URL(string: UIApplication.openSettingsURLString) else {
            result(false)
            return
          }

          UIApplication.shared.open(url, options: [:]) { opened in
            result(opened)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      })

      let cameraChannel = FlutterMethodChannel(
        name: "com.easy_moni/camera",
        binaryMessenger: rvc.binaryMessenger
      )

      cameraChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "checkCameraPermission" {
          let status = AVCaptureDevice.authorizationStatus(for: .video)

          switch status {
          case .authorized:
            result(true)
          case .notDetermined, .denied, .restricted:
            result(false)
          @unknown default:
            result(false)
          }
        } else if call.method == "requestCameraPermission" {
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
        } else if call.method == "openAppSettings" {
          guard let url = URL(string: UIApplication.openSettingsURLString) else {
            result(false)
            return
          }

          UIApplication.shared.open(url, options: [:]) { opened in
            result(opened)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      })

      let contactsChannel = FlutterMethodChannel(
        name: "com.easy_moni/contacts",
        binaryMessenger: rvc.binaryMessenger
      )

      contactsChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "pickContact" {
          let picker = CNContactPickerViewController()
          picker.delegate = self
          self.contactPickerResult = result
          rvc.present(picker, animated: true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
