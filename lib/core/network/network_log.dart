import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Debug 网络日志：解密 JSON 格式化按行输出，密文仅预览。
class NetworkLog {
  NetworkLog._();

  static const _tag = '[HTTP]';
  static const _jsonPrefix = '  │ ';
  static const _maxLineLen = 900;

  static void request({
    required String method,
    required Uri uri,
    Map<String, dynamic>? headers,
    Object? body,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag → $method ${_pathWithQuery(uri)}');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('$_tag   hdr ${_sanitizeHeaders(headers)}');
    }
    if (body != null) {
      debugPrint('$_tag   req ${_previewWire(body)}');
    }
  }

  static void response({
    required String method,
    required Uri uri,
    required int? statusCode,
    Object? wireData,
    Duration? duration,
  }) {
    if (!kDebugMode) return;
    final elapsed = duration != null ? ' ${duration.inMilliseconds}ms' : '';
    debugPrint('$_tag ← $statusCode $method ${_pathWithQuery(uri)}$elapsed');
    if (wireData != null) {
      debugPrint('$_tag   wire ${_previewWire(wireData)}');
    }
  }

  static void plainBody({
    required String method,
    required String path,
    Object? body,
  }) {
    if (!kDebugMode || body == null) return;
    debugPrint('$_tag · $method $path (plain)');
    _printFormattedJson(body);
  }

  static void decrypted({
    required String method,
    required String path,
    required dynamic data,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag ✓ $method $path (decrypted)');
    _printFormattedJson(data);
  }

  static void error({
    required String method,
    required Uri uri,
    required String message,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag ✗ $method ${_pathWithQuery(uri)} | $message');
  }

  static void _printFormattedJson(dynamic data) {
    final pretty = _jsonPretty(data);
    if (pretty == null) {
      _printLongLine('$_jsonPrefix${data?.toString() ?? 'null'}');
      return;
    }

    for (final line in pretty.split('\n')) {
      _printLongLine('$_jsonPrefix$line');
    }
  }

  /// 单行过长时按字符续打，但只在同一 JSON 行内分片，不截断内容。
  static void _printLongLine(String line) {
    if (line.length <= _maxLineLen) {
      debugPrint(line);
      return;
    }

    final total = (line.length + _maxLineLen - 1) ~/ _maxLineLen;
    for (var i = 0; i < total; i++) {
      final start = i * _maxLineLen;
      final end = math.min(start + _maxLineLen, line.length);
      final suffix = total > 1 ? '  (${i + 1}/$total)' : '';
      debugPrint('${line.substring(start, end)}$suffix');
    }
  }

  static String _pathWithQuery(Uri uri) {
    if (uri.hasQuery) {
      return '${uri.path}?${uri.query}';
    }
    return uri.path;
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key.toLowerCase() == 'seal' && value is String && value.length > 24) {
        sanitized[key] = '${value.substring(0, 16)}…(${value.length})';
      } else {
        sanitized[key] = value;
      }
    }
    return sanitized;
  }

  static String _previewWire(Object? data, {int maxLen = 120}) {
    if (data == null) return 'null';
    final text = data is String ? data : data.toString();
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}…(${text.length})';
  }

  static String? _jsonPretty(dynamic data) {
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      }
    } catch (_) {}
    return null;
  }
}
