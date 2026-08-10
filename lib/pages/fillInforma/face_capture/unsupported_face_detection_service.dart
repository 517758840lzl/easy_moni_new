import 'package:camera/camera.dart';

import 'face_detection_service.dart';

class UnsupportedFaceDetectionService implements FaceDetectionService {
  @override
  bool get isInitialized => false;

  @override
  Future<void> init() async {}

  @override
  Future<List<DetectedFace>> processImageFile(String path) async => [];

  @override
  Future<List<DetectedFace>> processCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) async =>
      [];

  @override
  Future<void> dispose() async {}
}
