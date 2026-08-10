import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detected_face.dart';
import 'face_detection_service.dart';

/// Android 活体检测 —— Google ML Kit Face Detection。
class MlKitFaceDetectionService implements FaceDetectionService {
  FaceDetector? _detector;
  bool _initialized = false;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) return;

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        minFaceSize: 0.15,
      ),
    );
    _initialized = true;
  }

  @override
  Future<List<DetectedFace>> processImageFile(String path) async {
    if (!_initialized || _detector == null) return [];
    try {
      final faces = await _detector!.processImage(InputImage.fromFilePath(path));
      return faces.map(_mapFace).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DetectedFace>> processCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) async {
    if (!_initialized || _detector == null) return [];
    try {
      final image = _inputImageFromCamera(cameraImage, camera);
      if (image == null) return [];
      final faces = await _detector!.processImage(image);
      return faces.map(_mapFace).toList();
    } catch (_) {
      return [];
    }
  }

  DetectedFace _mapFace(Face face) {
    return DetectedFace(
      leftEyeOpen: face.leftEyeOpenProbability,
      rightEyeOpen: face.rightEyeOpenProbability,
      smilingProbability: face.smilingProbability,
      headYaw: face.headEulerAngleY,
      headPitch: face.headEulerAngleX,
      headRoll: face.headEulerAngleZ,
      normalizedLipOpening: _normalizedLipOpening(face),
    );
  }

  double? _normalizedLipOpening(Face face) {
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;
    final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
    if (leftMouth == null || rightMouth == null || bottomMouth == null) {
      return null;
    }

    final mouthWidth = (rightMouth.x - leftMouth.x).abs();
    if (mouthWidth == 0) return null;

    final mouthCenterY = (leftMouth.y + rightMouth.y) / 2;
    final mouthHeight = (bottomMouth.y - mouthCenterY).abs();
    return mouthHeight / mouthWidth;
  }

  InputImage? _inputImageFromCamera(
    CameraImage image,
    CameraDescription camera,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    var rotationCompensation =
        _orientations[DeviceOrientation.portraitUp];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || format != InputImageFormat.nv21) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _initialized = false;
  }
}
