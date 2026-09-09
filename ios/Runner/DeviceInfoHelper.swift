import CoreLocation
import Flutter
import Network
import UIKit

final class DeviceInfoHelper {
  static let shared = DeviceInfoHelper()

  private init() {}

  func collectUploadExtras() -> [String: Any] {
    [
      "networkInfo": networkInfo(),
      "screenMetrics": screenMetrics(),
    ]
  }

  func reverseGeocode(
    latitude: Double,
    longitude: Double,
    accuracy: Double,
    timestamp: Int64,
    completion: @escaping ([String: Any?]?) -> Void
  ) {
    guard latitude != 0 || longitude != 0 else {
      completion(nil)
      return
    }

    let location = CLLocation(latitude: latitude, longitude: longitude)
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
      let placemark = placemarks?.first
      let addressParts = [
        placemark?.subLocality,
        placemark?.locality,
        placemark?.administrativeArea,
        placemark?.country,
      ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

      completion([
        "accuracy": String(accuracy),
        "address": addressParts.isEmpty ? nil : addressParts.joined(separator: ", "),
        "addressList": nil,
        "addressObject": nil,
        "adminArea": placemark?.administrativeArea,
        "countryCode": placemark?.isoCountryCode,
        "countryName": placemark?.country,
        "featureName": placemark?.name,
        "latitude": String(latitude),
        "locality": placemark?.locality,
        "longitude": String(longitude),
        "subAdminArea": placemark?.subAdministrativeArea,
        "time": timestamp,
      ])
    }
  }

  private func networkInfo() -> [String: Any] {
    [
      "configuredWifi": [] as [Any],
      "currentWifi": NSNull(),
      "mac": "",
      "networkType": currentNetworkType(),
    ]
  }

  private func screenMetrics() -> [String: Any] {
    let screen = UIScreen.main
    let bounds = screen.nativeBounds
    let scale = screen.nativeScale
    let widthPixels = Int(bounds.width.rounded())
    let heightPixels = Int(bounds.height.rounded())
    let ppi = Double(scale) * 152.41835143731973
    let xdpi = ppi
    let ydpi = ppi
    let physicalSize: String
    if widthPixels > 0 && heightPixels > 0 {
      physicalSize = String(format: "%.1f*%.1f", Double(widthPixels), Double(heightPixels))
    } else {
      physicalSize = ""
    }

    return [
      "density": String(format: "%.1f", scale),
      "densityDpi": Int((163 * scale).rounded()),
      "heightPixels": heightPixels,
      "physicalSize": physicalSize,
      "scaledDensity": String(format: "%.1f", scale),
      "widthPixels": widthPixels,
      "xdpi": String(xdpi),
      "ydpi": String(ydpi),
    ]
  }

  private func currentNetworkType() -> String {
    let monitor = NWPathMonitor()
    let semaphore = DispatchSemaphore(value: 0)
    var networkType = "none"

    monitor.pathUpdateHandler = { path in
      if path.status != .satisfied {
        networkType = "none"
      } else if path.usesInterfaceType(.wifi) {
        networkType = "wifi"
      } else if path.usesInterfaceType(.cellular) {
        networkType = "cellular"
      } else {
        networkType = "other"
      }
      semaphore.signal()
    }

    let queue = DispatchQueue(label: "com.primecediloan.device_info.network")
    monitor.start(queue: queue)
    _ = semaphore.wait(timeout: .now() + 0.5)
    monitor.cancel()
    return networkType
  }
}
