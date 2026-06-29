import 'dart:math' as math;
import 'dart:typed_data';

import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:image/image.dart' as img;

class ImageCompressTool {
  const ImageCompressTool._();

  static const int _defaultMaxLongSide = 1920;
  static const int _defaultQuality = 88;

  /// 压缩上传图片，统一控制最大边长与 JPEG 质量，降低上传体积。
  static Future<Uint8List> compressForUpload(
    Uint8List bytes, {
    int maxLongSide = _defaultMaxLongSide,
    int quality = _defaultQuality,
  }) async {
    if (bytes.isEmpty) {
      return bytes;
    }

    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return bytes;
      }

      final orientedImage = img.bakeOrientation(decodedImage);
      final resizedImage = _resizeIfNeeded(
        orientedImage,
        maxLongSide: maxLongSide,
      );
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality.clamp(1, 100)),
      );

      if (compressedBytes.length >= bytes.length) {
        return bytes;
      }

      AppLogger.debug(
        '图片压缩完成: original=${bytes.length}, compressed=${compressedBytes.length}, '
        'maxLongSide=$maxLongSide, quality=$quality',
      );
      return compressedBytes;
    } catch (error, stackTrace) {
      AppLogger.debug('图片压缩异常: $error\n$stackTrace');
      return bytes;
    }
  }

  /// 仅在图片长边超过限制时缩放，避免无意义降低小图清晰度。
  static img.Image _resizeIfNeeded(
    img.Image image, {
    required int maxLongSide,
  }) {
    final normalizedMaxLongSide = math.max(1, maxLongSide);
    final longSide = math.max(image.width, image.height);
    if (longSide <= normalizedMaxLongSide) {
      return image;
    }

    final scale = normalizedMaxLongSide / longSide;
    return img.copyResize(
      image,
      width: math.max(1, (image.width * scale).round()),
      height: math.max(1, (image.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
  }
}
