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
}
