import CoreImage
import Flutter
import UIKit
import Vision

enum VisionFaceDetector {
  static func warmUp() {
    _ = VNDetectFaceRectanglesRequest()
    _ = VNDetectFaceLandmarksRequest()
  }

  static func detectFromFile(path: String) -> [[String: Any]] {
    let url = URL(fileURLWithPath: path)
    guard let image = CIImage(contentsOf: url) else { return [] }
    return detect(ciImage: image, orientation: .up)
  }

  static func detectFromBgra(
    bytes: FlutterStandardTypedData,
    width: Int,
    height: Int,
    bytesPerRow: Int,
    sensorOrientation: Int,
    lensFacing: String
  ) -> [[String: Any]] {
    guard let pixelBuffer = makeBgraPixelBuffer(
      bytes: bytes.data,
      width: width,
      height: height,
      bytesPerRow: bytesPerRow
    ) else {
      return []
    }

    let orientation = cgOrientation(
      sensorOrientation: sensorOrientation,
      frontCamera: lensFacing == "front"
    )
    let handler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      orientation: orientation,
      options: [:]
    )
    return perform(handler: handler)
  }

  private static func detect(
    ciImage: CIImage,
    orientation: CGImagePropertyOrientation
  ) -> [[String: Any]] {
    let handler = VNImageRequestHandler(
      ciImage: ciImage,
      orientation: orientation,
      options: [:]
    )
    return perform(handler: handler)
  }

  private static func perform(handler: VNImageRequestHandler) -> [[String: Any]] {
    let poseRequest = VNDetectFaceRectanglesRequest()
    if #available(iOS 15.0, *) {
      poseRequest.revision = VNDetectFaceRectanglesRequestRevision3
    }

    let landmarksRequest = VNDetectFaceLandmarksRequest()

    do {
      try handler.perform([poseRequest, landmarksRequest])
    } catch {
      return []
    }

    let poseFaces = (poseRequest.results as? [VNFaceObservation]) ?? []
    let landmarkFaces = (landmarksRequest.results as? [VNFaceObservation]) ?? []

    if poseFaces.isEmpty && landmarkFaces.isEmpty {
      return []
    }

    let sources: [VNFaceObservation] =
      poseFaces.isEmpty ? landmarkFaces : poseFaces

    return sources.map { face in
      let landmarkFace = closestFace(to: face, in: landmarkFaces) ?? face
      return metrics(pose: face, landmarks: landmarkFace)
    }
  }

  private static func metrics(
    pose: VNFaceObservation,
    landmarks: VNFaceObservation
  ) -> [String: Any] {
    var map: [String: Any] = [:]

    if let yaw = pose.yaw?.doubleValue {
      map["headYaw"] = yaw * 180.0 / Double.pi
    }

    if let roll = pose.roll?.doubleValue {
      map["headRoll"] = roll * 180.0 / Double.pi
    }

    if let pitch = estimatedPitchDegrees(from: landmarks.landmarks) {
      map["headPitch"] = pitch
    }

    let eye = eyeOpenProbabilities(from: landmarks.landmarks)
    if let left = eye.left {
      map["leftEyeOpen"] = left
    }
    if let right = eye.right {
      map["rightEyeOpen"] = right
    }

    if let lip = normalizedLipOpening(from: landmarks.landmarks) {
      map["normalizedLipOpening"] = lip
    }

    return map
  }

  private static func estimatedPitchDegrees(from landmarks: VNFaceLandmarks2D?) -> Double? {
    guard let landmarks,
          let nose = landmarks.nose,
          let leftEye = landmarks.leftEye,
          let rightEye = landmarks.rightEye,
          nose.pointCount > 0,
          leftEye.pointCount > 0,
          rightEye.pointCount > 0
    else {
      return nil
    }

    let noseCenter = averagePoint(nose)
    let leftCenter = averagePoint(leftEye)
    let rightCenter = averagePoint(rightEye)
    let eyeCenter = CGPoint(
      x: (leftCenter.x + rightCenter.x) / 2,
      y: (leftCenter.y + rightCenter.y) / 2
    )
    let interEye = hypot(leftCenter.x - rightCenter.x, leftCenter.y - rightCenter.y)
    guard interEye > 0.0001 else { return nil }

    let normalizedOffset = (noseCenter.y - eyeCenter.y) / interEye
    return Double(normalizedOffset) * 45.0
  }

  private static func closestFace(
    to target: VNFaceObservation,
    in faces: [VNFaceObservation]
  ) -> VNFaceObservation? {
    guard !faces.isEmpty else { return nil }
    return faces.min { a, b in
      centerDistance(a, target) < centerDistance(b, target)
    }
  }

  private static func centerDistance(
    _ a: VNFaceObservation,
    _ b: VNFaceObservation
  ) -> CGFloat {
    let ac = CGPoint(x: a.boundingBox.midX, y: a.boundingBox.midY)
    let bc = CGPoint(x: b.boundingBox.midX, y: b.boundingBox.midY)
    let dx = ac.x - bc.x
    let dy = ac.y - bc.y
    return dx * dx + dy * dy
  }

  private static func eyeOpenProbabilities(
    from landmarks: VNFaceLandmarks2D?
  ) -> (left: Double?, right: Double?) {
    guard let landmarks else { return (nil, nil) }
    return (
      openProbability(region: landmarks.leftEye),
      openProbability(region: landmarks.rightEye)
    )
  }

  private static func openProbability(region: VNFaceLandmarkRegion2D?) -> Double? {
    guard let region, region.pointCount >= 4 else { return nil }
    let points = (0..<region.pointCount).map { region.normalizedPoints[$0] }

    var minX = CGFloat.greatestFiniteMagnitude
    var maxX = -CGFloat.greatestFiniteMagnitude
    var minY = CGFloat.greatestFiniteMagnitude
    var maxY = -CGFloat.greatestFiniteMagnitude
    for p in points {
      minX = min(minX, p.x)
      maxX = max(maxX, p.x)
      minY = min(minY, p.y)
      maxY = max(maxY, p.y)
    }
    let width = maxX - minX
    let height = maxY - minY
    guard width > 0.0001 else { return nil }

    let ratio = Double(height / width)
    let normalized = (ratio - 0.05) / 0.30
    return max(0.0, min(1.0, normalized))
  }

  private static func normalizedLipOpening(
    from landmarks: VNFaceLandmarks2D?
  ) -> Double? {
    guard let landmarks,
          let outerLips = landmarks.outerLips,
          let leftEye = landmarks.leftEye,
          let rightEye = landmarks.rightEye,
          outerLips.pointCount >= 4,
          leftEye.pointCount > 0,
          rightEye.pointCount > 0
    else {
      return nil
    }

    let lipPoints = (0..<outerLips.pointCount).map { outerLips.normalizedPoints[$0] }
    let minY = lipPoints.map(\.y).min() ?? 0
    let maxY = lipPoints.map(\.y).max() ?? 0
    let opening = abs(maxY - minY)

    let leftCenter = averagePoint(leftEye)
    let rightCenter = averagePoint(rightEye)
    let eyeDist = hypot(leftCenter.x - rightCenter.x, leftCenter.y - rightCenter.y)
    guard eyeDist > 0.0001 else { return nil }
    return Double(opening / eyeDist)
  }

  private static func averagePoint(_ region: VNFaceLandmarkRegion2D) -> CGPoint {
    var sum = CGPoint.zero
    let count = region.pointCount
    guard count > 0 else { return .zero }
    for i in 0..<count {
      let p = region.normalizedPoints[i]
      sum.x += p.x
      sum.y += p.y
    }
    return CGPoint(x: sum.x / CGFloat(count), y: sum.y / CGFloat(count))
  }

  private static func makeBgraPixelBuffer(
    bytes: Data,
    width: Int,
    height: Int,
    bytesPerRow: Int
  ) -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let attrs: [String: Any] = [
      kCVPixelBufferCGImageCompatibilityKey as String: true,
      kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
    ]
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault,
      width,
      height,
      kCVPixelFormatType_32BGRA,
      attrs as CFDictionary,
      &pixelBuffer
    )
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
      return nil
    }

    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

    guard let dest = CVPixelBufferGetBaseAddress(buffer) else { return nil }
    let destBytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
    bytes.withUnsafeBytes { raw in
      guard let src = raw.baseAddress else { return }
      let rowBytes = min(bytesPerRow, destBytesPerRow, width * 4)
      for row in 0..<height {
        memcpy(
          dest.advanced(by: row * destBytesPerRow),
          src.advanced(by: row * bytesPerRow),
          rowBytes
        )
      }
    }
    return buffer
  }

  private static func cgOrientation(
    sensorOrientation: Int,
    frontCamera: Bool
  ) -> CGImagePropertyOrientation {
    switch sensorOrientation {
    case 0:
      return frontCamera ? .upMirrored : .up
    case 90:
      return frontCamera ? .leftMirrored : .right
    case 180:
      return frontCamera ? .downMirrored : .down
    case 270:
      return frontCamera ? .rightMirrored : .left
    default:
      return frontCamera ? .leftMirrored : .right
    }
  }
}
