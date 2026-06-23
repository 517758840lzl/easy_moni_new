import 'dart:typed_data';

/// 人脸拍摄结果，承载本地照片数据和上传后的远端地址。
class FaceVerifyCaptureResult {
  const FaceVerifyCaptureResult({
    required this.imageBytes,
    required this.imageUrl,
  });

  final Uint8List imageBytes;
  final String imageUrl;
}
