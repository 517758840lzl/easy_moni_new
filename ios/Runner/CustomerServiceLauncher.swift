import Flutter
import UIKit

struct CustomerServiceLauncher {
  private init() {}

  static func openPhoneDialer(phone: String) -> Bool {
    let normalized = phone.replacingOccurrences(of: " ", with: "")
    guard !normalized.isEmpty,
          let url = URL(string: "tel://\(normalized)"),
          UIApplication.shared.canOpenURL(url)
    else {
      return false
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    return true
  }

  static func openExternalURL(_ urlString: String, result: @escaping FlutterResult) {
    let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
      result(false)
      return
    }

    DispatchQueue.main.async {
      guard UIApplication.shared.canOpenURL(url) else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    }
  }
}
