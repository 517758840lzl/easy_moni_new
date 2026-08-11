import CoreLocation
import Flutter
import Network
import UIKit

final class DeviceInfoHelper {
  static let shared = DeviceInfoHelper()

  private init() {}

  func collectUploadExtras() -> [String: Any] {
    [
      "batteryStatusInfo": batteryStatusInfo(),
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

  private func batteryStatusInfo() -> [String: Any] {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true

    let level = device.batteryLevel
    let pct = level >= 0 ? Int((level * 100).rounded()) : 0
    let state = device.batteryState

    return [
      "batteryLevel": pct,
      "batteryMax": 100,
      "batteryPct": pct,
      "isAcCharge": state == .full || state == .charging ? 1 : 0,
      "isCharging": state == .charging || state == .full ? 1 : 0,
      "isUsbCharge": state == .charging ? 1 : 0,
    ]
  }

  private func networkInfo() -> [String: Any] {
    [
      "configuredWifi": [] as [Any],
      "currentWifi": NSNull(),
      "ip": localIPv4Address() ?? "",
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
    let widthInches = widthPixels > 0 ? Double(widthPixels) / xdpi : 0
    let heightInches = heightPixels > 0 ? Double(heightPixels) / ydpi : 0
    let physicalSize: String
    if widthInches > 0 && heightInches > 0 {
      physicalSize = String(format: "%.2f", sqrt(widthInches * widthInches + heightInches * heightInches))
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

    let queue = DispatchQueue(label: "com.easy_moni.device_info.network")
    monitor.start(queue: queue)
    _ = semaphore.wait(timeout: .now() + 0.5)
    monitor.cancel()
    return networkType
  }

  private func localIPv4Address() -> String? {
    var address: String?
    var ifaddrPointer: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddrPointer) == 0, let firstAddr = ifaddrPointer else {
      return nil
    }

    defer { freeifaddrs(ifaddrPointer) }

    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
      let interface = ptr.pointee
      let addrFamily = interface.ifa_addr.pointee.sa_family
      guard addrFamily == UInt8(AF_INET) else { continue }

      let name = String(cString: interface.ifa_name)
      guard name == "en0" || name == "pdp_ip0" else { continue }

      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
      getnameinfo(
        interface.ifa_addr,
        socklen_t(interface.ifa_addr.pointee.sa_len),
        &hostname,
        socklen_t(hostname.count),
        nil,
        0,
        NI_NUMERICHOST
      )
      address = String(cString: hostname)
      if address != nil {
        break
      }
    }

    return address
  }
}
