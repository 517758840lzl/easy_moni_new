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
}
