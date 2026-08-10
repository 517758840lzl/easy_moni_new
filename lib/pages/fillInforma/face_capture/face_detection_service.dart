import 'dart:io';

import 'package:camera/camera.dart';

import 'detected_face.dart';
import 'mlkit_face_detection_service.dart';
import 'vision_face_detection_service.dart';

export 'detected_face.dart';

/// 活体人脸检测抽象：Android → ML Kit，iOS → Apple Vision。
abstract class FaceDetectionService {
  bool get isInitialized;

  Future<void> init();

  Future<List<DetectedFace>> processImageFile(String path);

  Future<List<DetectedFace>> processCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  );

  Future<void> dispose();

  static FaceDetectionService create() {
    if (Platform.isIOS) {
      return VisionFaceDetectionService();
    }
    return MlKitFaceDetectionService();
  }

  static bool isEyeClosed(DetectedFace face, {double threshold = 0.3}) {
    final avg = face.avgEyeOpen;
    if (avg == null) return false;
    return avg < threshold;
  }

  static bool isEyeOpen(DetectedFace face, {double threshold = 0.7}) {
    final avg = face.avgEyeOpen;
    if (avg == null) return false;
    return avg > threshold;
  }

  static bool isHeadTurnedAway(
    DetectedFace face, {
    double angleThreshold = 6.0,
  }) {
    final yaw = face.headYaw;
    if (yaw == null) return false;
    return yaw.abs() >= angleThreshold;
  }

  static bool isHeadTurnedOpposite(
    DetectedFace face, {
    required double firstYawSign,
    double angleThreshold = 6.0,
  }) {
    final yaw = face.headYaw;
    if (yaw == null) return false;
    if (firstYawSign < 0) return yaw >= angleThreshold;
    return yaw <= -angleThreshold;
  }

  static bool isHeadFacingForward(
    DetectedFace face, {
    double angleThreshold = 12.0,
    double eyeOpenThreshold = 0.5,
  }) {
    final yaw = face.headYaw;
    if (yaw == null || yaw.abs() > angleThreshold) return false;
    return isEyeOpen(face, threshold: eyeOpenThreshold);
  }
}
