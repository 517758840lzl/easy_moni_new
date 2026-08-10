import CoreLocation
import Flutter
import Foundation

final class LocationPermissionHelper: NSObject, CLLocationManagerDelegate {
  static let shared = LocationPermissionHelper()

  private var manager: CLLocationManager?
  private var pendingAuthResult: FlutterResult?
  private var pendingLocationResult: FlutterResult?
  private var locationTimeoutWork: DispatchWorkItem?

  private override init() {
    super.init()
  }

  private func authStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return ensureManager().authorizationStatus
    }
    return CLLocationManager.authorizationStatus()
  }

  func hasWhenInUse() -> Bool {
    switch authStatus() {
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    default:
      return false
    }
  }

  func requestWhenInUse(_ result: @escaping FlutterResult) {
    if Thread.isMainThread {
      performRequest(result)
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.performRequest(result)
      }
    }
  }

  private func performRequest(_ result: @escaping FlutterResult) {
    let status = authStatus()
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      result(true)
      return
    }

    if status == .denied || status == .restricted {
      result(false)
      return
    }

    if let previous = pendingAuthResult {
      previous(false)
    }
    pendingAuthResult = result

    let mgr = ensureManager()
    mgr.requestWhenInUseAuthorization()
  }

  func peekLatLng(_ result: @escaping FlutterResult) {
    if Thread.isMainThread {
      performPeekLatLng(result)
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.performPeekLatLng(result)
      }
    }
  }

  private func performPeekLatLng(_ result: @escaping FlutterResult) {
    guard hasWhenInUse() else {
      result(zeroCoords())
      return
    }

    let mgr = ensureManager()
    applyApproximateLocationSettings(to: mgr)

    if let loc = mgr.location, loc.horizontalAccuracy >= 0 {
      result(coordsDict(loc.coordinate))
      return
    }

    if pendingLocationResult != nil {
      result(zeroCoords())
      return
    }

    pendingLocationResult = result
    let timeout = DispatchWorkItem { [weak self] in
      guard let self else { return }
      guard let pending = self.pendingLocationResult else { return }
      self.pendingLocationResult = nil
      self.locationTimeoutWork = nil
      pending(self.zeroCoords())
    }
    locationTimeoutWork = timeout
    DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: timeout)
    mgr.requestLocation()
  }

  private func applyApproximateLocationSettings(to manager: CLLocationManager) {
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
    manager.distanceFilter = kCLDistanceFilterNone
  }

  private func ensureManager() -> CLLocationManager {
    if let manager { return manager }
    let mgr = CLLocationManager()
    mgr.delegate = self
    applyApproximateLocationSettings(to: mgr)
    manager = mgr
    return mgr
  }

  private func zeroCoords() -> [String: Double] {
    ["latitude": 0.0, "longitude": 0.0]
  }

  private func coordsDict(_ coordinate: CLLocationCoordinate2D) -> [String: Double] {
    ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
  }

  private func finishPendingAuthIfNeeded(status: CLAuthorizationStatus) {
    guard let pending = pendingAuthResult else { return }
    if status == .notDetermined { return }
    let granted = status == .authorizedWhenInUse || status == .authorizedAlways
    pendingAuthResult = nil
    pending(granted)
  }

  private func finishPendingLocation(_ coordinate: CLLocationCoordinate2D?) {
    locationTimeoutWork?.cancel()
    locationTimeoutWork = nil
    guard let pending = pendingLocationResult else { return }
    pendingLocationResult = nil
    if let coordinate {
      pending(coordsDict(coordinate))
    } else {
      pending(zeroCoords())
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if #available(iOS 14.0, *) {
      finishPendingAuthIfNeeded(status: manager.authorizationStatus)
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    if #available(iOS 14.0, *) {
      return
    }
    finishPendingAuthIfNeeded(status: status)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard pendingLocationResult != nil else { return }
    let best = locations.last { $0.horizontalAccuracy >= 0 } ?? locations.last
    finishPendingLocation(best?.coordinate)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard pendingLocationResult != nil else { return }
    finishPendingLocation(nil)
  }
}
