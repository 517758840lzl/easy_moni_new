import 'dart:typed_data';

class FaceVerifyCaptureResult {
  const FaceVerifyCaptureResult({
    required this.imageBytes,
    required this.imageUrl,
  });

  final Uint8List imageBytes;
  final String imageUrl;
}
