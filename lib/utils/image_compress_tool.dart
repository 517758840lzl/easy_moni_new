import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
      final result = await compute(
        _compressForUploadInBackground,
        _ImageCompressRequest(
          bytes: bytes,
          maxBytes: normalizedMaxBytes,
          minBytes: normalizedMinBytes,
          maxLongSide: maxLongSide,
          quality: quality,
        ),
      );
      if (result.wasCompressed) {
      }
      return result.bytes;
    } catch (error) {
      if (bytes.length > normalizedMaxBytes) {
        rethrow;
      }
      return bytes;
    }
  }

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

  static Uint8List _encodeWithBounds(
    img.Image image,
    _CompressionBounds bounds,
  ) {
    final resizedImage = _resizeIfNeeded(image, maxLongSide: bounds.longSide);
    return Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: bounds.quality),
    );
  }

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

  static int _limitedLongSide(img.Image image, {required int maxLongSide}) {
    return math.min(
      math.max(1, maxLongSide),
      math.max(1, math.max(image.width, image.height)),
    );
  }
}

_ImageCompressResult _compressForUploadInBackground(
  _ImageCompressRequest request,
) {
  final bytes = request.bytes;
  final decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) {
    if (bytes.length <= request.maxBytes) {
      return _ImageCompressResult(bytes: bytes, wasCompressed: false);
    }
    throw StateError('error');
  }

  if (bytes.length <= request.maxBytes &&
      math.max(decodedImage.width, decodedImage.height) <=
          request.maxLongSide) {
    return _ImageCompressResult(bytes: bytes, wasCompressed: false);
  }

  final orientedImage = img.bakeOrientation(decodedImage);
  final compressedBytes = ImageCompressTool._compressWithUploadBounds(
    orientedImage,
    maxBytes: request.maxBytes,
    minBytes: bytes.length >= request.minBytes ? request.minBytes : 0,
    maxLongSide: request.maxLongSide,
    quality: request.quality,
  );

  if (compressedBytes == null) {
    throw StateError('image too big');
  }

  if (bytes.length <= request.maxBytes &&
      bytes.length >= request.minBytes &&
      compressedBytes.length < request.minBytes) {
    return _ImageCompressResult(bytes: bytes, wasCompressed: false);
  }

  if (bytes.length <= request.maxBytes &&
      compressedBytes.length >= bytes.length) {
    return _ImageCompressResult(bytes: bytes, wasCompressed: false);
  }

  return _ImageCompressResult(bytes: compressedBytes, wasCompressed: true);
}

class _ImageCompressRequest {
  const _ImageCompressRequest({
    required this.bytes,
    required this.maxBytes,
    required this.minBytes,
    required this.maxLongSide,
    required this.quality,
  });

  final Uint8List bytes;
  final int maxBytes;
  final int minBytes;
  final int maxLongSide;
  final int quality;
}

class _ImageCompressResult {
  const _ImageCompressResult({
    required this.bytes,
    required this.wasCompressed,
  });

  final Uint8List bytes;
  final bool wasCompressed;
}

class _CompressionBounds {
  const _CompressionBounds({required this.longSide, required this.quality});

  final int longSide;
  final int quality;
}

class _CompressionResult {
  const _CompressionResult({required this.bytes, required this.bounds});

  final Uint8List bytes;
  final _CompressionBounds bounds;
}
