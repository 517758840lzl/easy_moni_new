import Darwin
import UIKit

enum IosDeviceInfoReader {
  static var isPhysicalDevice: Bool {
#if targetEnvironment(simulator)
    return false
#else
    return true
#endif
  }

  static func machineIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    if !isPhysicalDevice {
      if let simulator = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
         !simulator.isEmpty {
        return simulator
      }
    }
    return withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(validatingUTF8: $0) ?? ""
      }
    }
  }
}
