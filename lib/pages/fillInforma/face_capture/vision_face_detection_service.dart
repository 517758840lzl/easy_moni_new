import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'face_detection_service.dart';

/// iOS 活体检测 —— Apple Vision（原生 MethodChannel）。
class VisionFaceDetectionService implements FaceDetectionService {
  static const MethodChannel _channel = MethodChannel(
    'com.easy_moni/face_vision',
  );

  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _channel.invokeMethod<void>('warmUp');
    } catch (_) {}
    _initialized = true;
  }

  @override
  Future<List<DetectedFace>> processImageFile(String path) async {
    if (!_initialized) return [];
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'detectFromFile',
        <String, dynamic>{'path': path},
      );
      return _mapResults(raw);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DetectedFace>> processCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) async {
    if (!_initialized || cameraImage.planes.isEmpty) return [];

    final plane = cameraImage.planes.first;
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'detectFromBgra',
        <String, dynamic>{
          'bytes': Uint8List.fromList(plane.bytes),
          'width': cameraImage.width,
          'height': cameraImage.height,
          'bytesPerRow': plane.bytesPerRow,
          'sensorOrientation': camera.sensorOrientation,
          'lensFacing': camera.lensDirection == CameraLensDirection.front
              ? 'front'
              : 'back',
        },
      );
      return _mapResults(raw);
    } catch (_) {
      return [];
    }
  }

  List<DetectedFace> _mapResults(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return DetectedFace(
        leftEyeOpen: (map['leftEyeOpen'] as num?)?.toDouble(),
        rightEyeOpen: (map['rightEyeOpen'] as num?)?.toDouble(),
        smilingProbability: (map['smilingProbability'] as num?)?.toDouble(),
        headYaw: (map['headYaw'] as num?)?.toDouble(),
        headPitch: (map['headPitch'] as num?)?.toDouble(),
        headRoll: (map['headRoll'] as num?)?.toDouble(),
        normalizedLipOpening:
            (map['normalizedLipOpening'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
