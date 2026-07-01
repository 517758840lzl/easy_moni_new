import 'dart:math' as math;
import 'dart:typed_data';

import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:image/image.dart' as img;

class ImageCompressTool {
  const ImageCompressTool._();

  static const int _defaultMaxUploadBytes = 2 * 1024 * 1024;
  static const int _defaultMinUploadBytes = 200 * 1024;
  static const int _defaultMaxLongSide = 1920;
  static const int _defaultQuality = 88;
  static const int _minQuality = 30;
  static const int _maxQuality = 100;
  static const int _minLongSide = 64;

  /// 压缩上传图片，统一控制最大体积、最小目标体积、最大边长与 JPEG 质量，满足后端上传限制。
  static Future<Uint8List> compressForUpload(
    Uint8List bytes, {
    int maxBytes = _defaultMaxUploadBytes,
    int minBytes = _defaultMinUploadBytes,
    int maxLongSide = _defaultMaxLongSide,
    int quality = _defaultQuality,
  }) async {
    final normalizedMaxBytes = math.max(1, maxBytes);
    final normalizedMinBytes = math.min(
      normalizedMaxBytes,
      math.max(0, minBytes),
    );
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
      final compressedBytes = _compressWithUploadBounds(
        orientedImage,
        maxBytes: normalizedMaxBytes,
        minBytes: bytes.length >= normalizedMinBytes ? normalizedMinBytes : 0,
        maxLongSide: maxLongSide,
        quality: quality,
      );

      if (compressedBytes == null) {
        throw StateError('图片压缩后仍超过上传大小限制');
      }

      if (bytes.length <= normalizedMaxBytes &&
          bytes.length >= normalizedMinBytes &&
          compressedBytes.length < normalizedMinBytes) {
        return bytes;
      }

      if (bytes.length <= normalizedMaxBytes &&
          compressedBytes.length >= bytes.length) {
        return bytes;
      }

      AppLogger.debug(
        '图片压缩完成: original=${bytes.length}, compressed=${compressedBytes.length}, '
        'maxBytes=$normalizedMaxBytes, minBytes=$normalizedMinBytes, '
        'maxLongSide=$maxLongSide, quality=$quality',
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

  /// 选择满足上传限制的最高可用压缩边界，尽量避免把图片压到 200KB 以下。
  static Uint8List? _compressWithUploadBounds(
    img.Image image, {
    required int maxBytes,
    required int minBytes,
    required int maxLongSide,
    required int quality,
  }) {
    final limitedLongSide = _limitedLongSide(image, maxLongSide: maxLongSide);
    final normalizedQuality = quality.clamp(1, _maxQuality).toInt();
    final preferredBounds = _CompressionBounds(
      longSide: limitedLongSide,
      quality: normalizedQuality,
    );
    final preferredBytes = _encodeWithBounds(image, preferredBounds);
    if (preferredBytes.length <= maxBytes) {
      return _raiseQualityForMinimum(
        image,
        currentBytes: preferredBytes,
        currentBounds: preferredBounds,
        maxBytes: maxBytes,
        minBytes: minBytes,
      );
    }

    final bestResizedBytes = _findLargestLongSideWithinLimit(
      image,
      minLongSide: math.min(_minLongSide, limitedLongSide),
      maxLongSide: limitedLongSide,
      quality: normalizedQuality,
      maxBytes: maxBytes,
    );
    if (bestResizedBytes != null) {
      return _raiseQualityForMinimum(
        image,
        currentBytes: bestResizedBytes.bytes,
        currentBounds: bestResizedBytes.bounds,
        maxBytes: maxBytes,
        minBytes: minBytes,
      );
    }

    return _findHighestQualityWithinLimit(
      image,
      longSide: math.min(_minLongSide, limitedLongSide),
      maxQuality: normalizedQuality,
      maxBytes: maxBytes,
    )?.bytes;
  }

  /// 在不超过上传上限的前提下，提升质量以靠近 200KB 最小目标。
  static Uint8List _raiseQualityForMinimum(
    img.Image image, {
    required Uint8List currentBytes,
    required _CompressionBounds currentBounds,
    required int maxBytes,
    required int minBytes,
  }) {
    if (minBytes <= 0 ||
        currentBytes.length >= minBytes ||
        currentBounds.quality >= _maxQuality) {
      return currentBytes;
    }

    var bestBytes = currentBytes;
    for (
      var nextQuality = currentBounds.quality + 1;
      nextQuality <= _maxQuality;
      nextQuality++
    ) {
      final nextBytes = _encodeWithBounds(
        image,
        _CompressionBounds(
          longSide: currentBounds.longSide,
          quality: nextQuality,
        ),
      );
      if (nextBytes.length > maxBytes) {
        break;
      }

      bestBytes = nextBytes;
      if (nextBytes.length >= minBytes) {
        break;
      }
    }

    return bestBytes;
  }

  /// 用二分查找找出指定质量下不超过上传上限的最大边长。
  static _CompressionResult? _findLargestLongSideWithinLimit(
    img.Image image, {
    required int minLongSide,
    required int maxLongSide,
    required int quality,
    required int maxBytes,
  }) {
    var low = minLongSide;
    var high = maxLongSide;
    _CompressionResult? bestResult;

    while (low <= high) {
      final middleLongSide = ((low + high) / 2).floor();
      final bounds = _CompressionBounds(
        longSide: middleLongSide,
        quality: quality,
      );
      final encodedBytes = _encodeWithBounds(image, bounds);

      if (encodedBytes.length <= maxBytes) {
        bestResult = _CompressionResult(bytes: encodedBytes, bounds: bounds);
        low = middleLongSide + 1;
      } else {
        high = middleLongSide - 1;
      }
    }

    return bestResult;
  }

  /// 边长已经降到最低仍超限时，继续查找可用的最高 JPEG 质量。
  static _CompressionResult? _findHighestQualityWithinLimit(
    img.Image image, {
    required int longSide,
    required int maxQuality,
    required int maxBytes,
  }) {
    final minQuality = math.min(_minQuality, maxQuality);
    var low = minQuality;
    var high = maxQuality;
    _CompressionResult? bestResult;

    while (low <= high) {
      final middleQuality = ((low + high) / 2).floor();
      final bounds = _CompressionBounds(
        longSide: longSide,
        quality: middleQuality,
      );
      final encodedBytes = _encodeWithBounds(image, bounds);

      if (encodedBytes.length <= maxBytes) {
        bestResult = _CompressionResult(bytes: encodedBytes, bounds: bounds);
        low = middleQuality + 1;
      } else {
        high = middleQuality - 1;
      }
    }

    return bestResult;
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

  /// 计算上传允许的最大长边，不放大小图。
  static int _limitedLongSide(img.Image image, {required int maxLongSide}) {
    return math.min(
      math.max(1, maxLongSide),
      math.max(1, math.max(image.width, image.height)),
    );
  }
}

/// 图片压缩参数边界，集中描述本次编码使用的尺寸和质量。
class _CompressionBounds {
  const _CompressionBounds({required this.longSide, required this.quality});

  final int longSide;
  final int quality;
}

/// 图片压缩结果，保留实际字节和对应参数，便于后续继续优化质量。
class _CompressionResult {
  const _CompressionResult({required this.bytes, required this.bounds});

  final Uint8List bytes;
  final _CompressionBounds bounds;
}
