import 'dart:math' as math;
import 'dart:typed_data';

import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:image/image.dart' as img;

class ImageCompressTool {
  const ImageCompressTool._();

  static const int _defaultMaxUploadBytes = 2 * 1024 * 1024;
  static const int _defaultMaxLongSide = 1920;
  static const int _defaultQuality = 88;
  static const int _minQuality = 30;
  static const int _minLongSide = 64;
  static const int _maxCorrectionAttempts = 3;
  static const double _estimateSafetyFactor = 0.95;
  static const double _correctionSafetyFactor = 0.88;

  /// 压缩上传图片，统一控制最大体积、最大边长与 JPEG 质量，满足后端上传限制。
  static Future<Uint8List> compressForUpload(
    Uint8List bytes, {
    int maxBytes = _defaultMaxUploadBytes,
    int maxLongSide = _defaultMaxLongSide,
    int quality = _defaultQuality,
  }) async {
    final normalizedMaxBytes = math.max(1, maxBytes);
    if (bytes.isEmpty) {
      return bytes;
    }

    try {
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        if (bytes.length <= normalizedMaxBytes) {
          return bytes;
        }
        throw StateError('图片解析失败，无法压缩到上传大小限制以内');
      }

      if (bytes.length <= normalizedMaxBytes &&
          math.max(decodedImage.width, decodedImage.height) <= maxLongSide) {
        return bytes;
      }

      final orientedImage = img.bakeOrientation(decodedImage);
      final compressedBytes = _compressWithEstimatedBounds(
        orientedImage,
        originalBytesLength: bytes.length,
        maxBytes: normalizedMaxBytes,
        maxLongSide: maxLongSide,
        quality: quality,
      );

      if (compressedBytes == null) {
        throw StateError('图片压缩后仍超过上传大小限制');
      }

      if (bytes.length <= normalizedMaxBytes &&
          compressedBytes.length >= bytes.length) {
        return bytes;
      }

      AppLogger.debug(
        '图片压缩完成: original=${bytes.length}, compressed=${compressedBytes.length}, '
        'maxBytes=$normalizedMaxBytes, maxLongSide=$maxLongSide, quality=$quality',
      );
      return compressedBytes;
    } catch (error, stackTrace) {
      AppLogger.debug('图片压缩异常: $error\n$stackTrace');
      if (bytes.length > normalizedMaxBytes) {
        rethrow;
      }
      return bytes;
    }
  }

  /// 根据目标体积预估压缩边界，优先用一次 JPEG 编码达成上传限制。
  static Uint8List? _compressWithEstimatedBounds(
    img.Image image, {
    required int originalBytesLength,
    required int maxBytes,
    required int maxLongSide,
    required int quality,
  }) {
    var bounds = _estimateCompressionBounds(
      image: image,
      originalBytesLength: originalBytesLength,
      maxBytes: maxBytes,
      maxLongSide: maxLongSide,
      quality: quality,
    );

    for (var attempt = 0; attempt <= _maxCorrectionAttempts; attempt++) {
      final encodedBytes = _encodeWithBounds(image, bounds);
      if (encodedBytes.length <= maxBytes) {
        return encodedBytes;
      }

      final nextBounds = _correctOversizedBounds(
        currentBounds: bounds,
        encodedBytesLength: encodedBytes.length,
        maxBytes: maxBytes,
      );
      if (nextBounds == bounds) {
        break;
      }
      bounds = nextBounds;
    }

    return null;
  }

  /// 按原图体积和目标体积估算长边与质量，避免进入多轮降质压缩。
  static _CompressionBounds _estimateCompressionBounds({
    required img.Image image,
    required int originalBytesLength,
    required int maxBytes,
    required int maxLongSide,
    required int quality,
  }) {
    final originalLongSide = math.max(image.width, image.height);
    final limitedLongSide = math.min(
      math.max(1, maxLongSide),
      math.max(1, originalLongSide),
    );
    final normalizedQuality = quality.clamp(1, 100).toInt();

    if (originalBytesLength <= maxBytes) {
      return _CompressionBounds(
        longSide: limitedLongSide,
        quality: normalizedQuality,
      );
    }

    final sizeRatio = maxBytes / math.max(1, originalBytesLength);
    final estimatedScale = math.sqrt(sizeRatio) * _estimateSafetyFactor;
    final estimatedLongSide = (originalLongSide * estimatedScale).floor();
    final minLongSide = math.min(_minLongSide, limitedLongSide);
    final targetLongSide = math.max(
      minLongSide,
      math.min(limitedLongSide, estimatedLongSide),
    );
    final areaRatio = math.pow(targetLongSide / originalLongSide, 2);
    final estimatedBytesAfterResize = originalBytesLength * areaRatio;
    final qualityRatio = maxBytes / math.max(1, estimatedBytesAfterResize);
    final targetQuality = math
        .max(
          math.min(_minQuality, normalizedQuality),
          math.min(
            normalizedQuality,
            (normalizedQuality * qualityRatio).floor(),
          ),
        )
        .toInt();

    return _CompressionBounds(longSide: targetLongSide, quality: targetQuality);
  }

  /// 首次估算偏大时，按实际编码体积做少量纠偏，保证最终不会超过 2M。
  static _CompressionBounds _correctOversizedBounds({
    required _CompressionBounds currentBounds,
    required int encodedBytesLength,
    required int maxBytes,
  }) {
    final sizeRatio = maxBytes / math.max(1, encodedBytesLength);
    final estimatedLongSide =
        (currentBounds.longSide *
                math.sqrt(sizeRatio) *
                _correctionSafetyFactor)
            .floor();
    final minLongSide = math.min(_minLongSide, currentBounds.longSide);
    final nextLongSide = math.max(
      minLongSide,
      math.min(currentBounds.longSide - 1, estimatedLongSide),
    );

    if (nextLongSide < currentBounds.longSide) {
      return _CompressionBounds(
        longSide: nextLongSide,
        quality: currentBounds.quality,
      );
    }

    final minQuality = math.min(_minQuality, currentBounds.quality);
    final nextQuality = math.max(
      minQuality,
      (currentBounds.quality * sizeRatio * _correctionSafetyFactor).floor(),
    );
    if (nextQuality < currentBounds.quality) {
      return _CompressionBounds(
        longSide: currentBounds.longSide,
        quality: nextQuality,
      );
    }

    return currentBounds;
  }

  /// 根据压缩边界统一执行缩放和 JPEG 编码。
  static Uint8List _encodeWithBounds(
    img.Image image,
    _CompressionBounds bounds,
  ) {
    final resizedImage = _resizeIfNeeded(image, maxLongSide: bounds.longSide);
    return Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: bounds.quality),
    );
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

/// 图片压缩参数边界，集中描述本次编码使用的尺寸和质量。
class _CompressionBounds {
  const _CompressionBounds({required this.longSide, required this.quality});

  final int longSide;
  final int quality;
}
