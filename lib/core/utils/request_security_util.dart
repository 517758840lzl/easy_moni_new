import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_moni/core/config/request_security_config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// 请求安全工具，集中处理请求体 AES 加密、解密和压缩。
class RequestSecurityUtil {
  RequestSecurityUtil._();

  static const int _aesBlockSize = RequestSecurityConfig.aesBlockSize;
  static const Set<int> _validKeyLengths = {16, 24, 32};

  static Uint8List get secretBytes =>
      _secretBytesForKey(RequestSecurityConfig.requestAesKey);

  static encrypt.IV get _nonceBlock =>
      _nonceBlockForKey(RequestSecurityConfig.requestAesKey);

  static encrypt.Encrypter get _encrypter =>
      _encrypterForKey(RequestSecurityConfig.requestAesKey);

  /// 将普通 JSON 数据加密为后端可接收的顶层请求体字符串。
  static String encryptRequestBody(
    Object? data, {
    String aesKey = RequestSecurityConfig.requestAesKey,
    String? ivText,
    String? ivBase64,
  }) {
    final result = encryptJson(
      data,
      aesKey: aesKey,
      ivText: ivText,
      ivBase64: ivBase64,
    );
    return result.cipherText;
  }

  /// 判断数据是否为后端约定的加密传输包。
  static bool isEncryptedTransportBody(
    Map<dynamic, dynamic> data, {
    String bodyKey = RequestSecurityConfig.requestAesKey,
    String? ivKey,
  }) {
    final effectiveIvKey = ivKey ?? RequestSecurityConfig.requestIvKey;
    return data[bodyKey] is String && data[effectiveIvKey] is String;
  }

  /// 解密整个响应体；后端正式响应为 String 密文，Map 加密包用于兼容本地测试。
  static dynamic decryptResponseBody(
    Object? data, {
    String aesKey = RequestSecurityConfig.requestAesKey,
    String? ivText,
    String bodyKey = RequestSecurityConfig.requestAesKey,
    String? ivKey,
  }) {
    final effectiveIvText = ivText ?? RequestSecurityConfig.requestIvKey;
    final effectiveIvKey = ivKey ?? RequestSecurityConfig.requestIvKey;

    if (data is String) {
      final plainText = openPayload(
        data,
        aesKey: aesKey,
        ivText: effectiveIvText,
      );
      return _tryDecodeJson(plainText, fallback: data);
    }

    if (data is! Map ||
        !isEncryptedTransportBody(
          data,
          bodyKey: bodyKey,
          ivKey: effectiveIvKey,
        )) {
      return data;
    }

    final plainText = openPayload(
      data[bodyKey] as String?,
      aesKey: aesKey,
      ivBase64: data[effectiveIvKey] as String?,
      ivText: effectiveIvText,
    );
    return _tryDecodeJson(plainText, fallback: data);
  }

  /// 将 JSON 数据序列化后使用 AES-CBC 加密。
  static RequestEncryptionResult encryptJson(
    Object? data, {
    required String aesKey,
    String? ivText,
    String? ivBase64,
  }) {
    final plainText = jsonEncode(data);
    final cipherText = sealPayload(
      plainText,
      aesKey: aesKey,
      ivText: ivText,
      ivBase64: ivBase64,
    );
    final iv = _buildIv(ivBase64, ivText: ivText, aesKey: aesKey);

    return RequestEncryptionResult(cipherText: cipherText, ivBase64: iv.base64);
  }

  /// 加密字符串内容，返回密文和 IV。
  static RequestEncryptionResult encryptText(
    String plainText, {
    required String aesKey,
    String? ivText,
    String? ivBase64,
  }) {
    final cipherText = sealPayload(
      plainText,
      aesKey: aesKey,
      ivText: ivText,
      ivBase64: ivBase64,
    );
    final iv = _buildIv(ivBase64, ivText: ivText, aesKey: aesKey);

    return RequestEncryptionResult(cipherText: cipherText, ivBase64: iv.base64);
  }

  /// 解密 JSON 密文，便于本地测试和排查加密链路。
  static dynamic decryptJson({
    required String cipherText,
    required String aesKey,
    String? ivBase64,
    String? ivText,
  }) {
    final plainText = openPayload(
      cipherText,
      aesKey: aesKey,
      ivBase64: ivBase64,
      ivText: ivText,
    );
    return jsonDecode(plainText);
  }

  /// 解密字符串密文，便于验证 AES 参数是否与后端一致。
  static String decryptText({
    required String cipherText,
    required String aesKey,
    String? ivBase64,
    String? ivText,
  }) {
    return openPayload(
      cipherText,
      aesKey: aesKey,
      ivBase64: ivBase64,
      ivText: ivText,
    );
  }

  /// 按后端契约加密明文载荷，失败时返回原文，避免中断调用链。
  static String sealPayload(
    String plainText, {
    String aesKey = RequestSecurityConfig.requestAesKey,
    String? ivText,
    String? ivBase64,
  }) {
    try {
      final encrypter = aesKey == RequestSecurityConfig.requestAesKey
          ? _encrypter
          : _encrypterForKey(aesKey);
      final encrypted = encrypter.encrypt(
        plainText,
        iv: _buildIv(ivBase64, ivText: ivText, aesKey: aesKey),
      );
      return encrypted.base64;
    } catch (e) {
      return plainText;
    }
  }

  /// 按后端契约解密密文载荷，失败时返回原密文。
  static String openPayload(
    String? cipherText, {
    String aesKey = RequestSecurityConfig.requestAesKey,
    String? ivBase64,
    String? ivText,
  }) {
    try {
      final encrypter = aesKey == RequestSecurityConfig.requestAesKey
          ? _encrypter
          : _encrypterForKey(aesKey);
      return encrypter.decrypt(
        encrypt.Encrypted.fromBase64(cipherText ?? ''),
        iv: _buildIv(ivBase64, ivText: ivText, aesKey: aesKey),
      );
    } catch (e) {
      return cipherText ?? '';
    }
  }

  /// 将业务数据 JSON 序列化后执行 zlib 压缩。
  static Uint8List deflateBytes(dynamic payload) {
    try {
      final jsonText = jsonEncode(payload);
      final originalBytes = utf8.encode(jsonText);
      final compressedBytes = ZLibEncoder(level: 6).convert(originalBytes);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      rethrow;
    }
  }

  static Uint8List _secretBytesForKey(String aesKey) {
    return Uint8List.fromList(utf8.encode(aesKey));
  }

  static encrypt.Encrypter _encrypterForKey(String aesKey) {
    final keyBytes = _secretBytesForKey(aesKey);
    if (!_validKeyLengths.contains(keyBytes.length)) {
      throw ArgumentError('AES key must be 16, 24, or 32 UTF-8 bytes.');
    }

    final keySpec = encrypt.Key(Uint8List.fromList(keyBytes));
    return encrypt.Encrypter(
      encrypt.AES(keySpec, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
  }

  /// 按后端约定从 AES key 中截取前 16 个 UTF-8 字节作为默认 IV。
  static encrypt.IV _nonceBlockForKey(String aesKey) {
    final bytes = _secretBytesForKey(aesKey);
    if (bytes.length < _aesBlockSize) {
      throw ArgumentError.value(
        aesKey,
        'aesKey',
        'AES key must contain at least $_aesBlockSize UTF-8 bytes.',
      );
    }
    return encrypt.IV(Uint8List.fromList(bytes.sublist(0, _aesBlockSize)));
  }

  static encrypt.IV _buildIv(
    String? ivBase64, {
    String? ivText,
    required String aesKey,
  }) {
    if (ivBase64 != null && ivBase64.isNotEmpty) {
      final ivBytes = base64Decode(ivBase64);
      if (ivBytes.length != _aesBlockSize) {
        throw ArgumentError.value(
          ivBase64,
          'ivBase64',
          'AES CBC IV must be 16 bytes.',
        );
      }
      return encrypt.IV(ivBytes);
    }

    if (ivText == null || ivText.isEmpty) {
      return aesKey == RequestSecurityConfig.requestAesKey
          ? _nonceBlock
          : _nonceBlockForKey(aesKey);
    }

    final ivBytes = utf8.encode(ivText);
    if (ivBytes.length != _aesBlockSize) {
      throw ArgumentError.value(
        ivText,
        'ivText',
        'AES CBC IV must be 16 bytes.',
      );
    }
    return encrypt.IV(ivBytes);
  }

  static dynamic _tryDecodeJson(String plainText, {required Object? fallback}) {
    try {
      return jsonDecode(plainText);
    } catch (e) {
      return fallback;
    }
  }
}

/// AES 加密后的请求数据结果。
class RequestEncryptionResult {
  const RequestEncryptionResult({
    required this.cipherText,
    required this.ivBase64,
  });

  final String cipherText;
  final String ivBase64;

  /// 转换为 Map 加密包，供事件字段加密和本地兼容测试使用。
  Map<String, dynamic> toRequestBody({
    String bodyKey = RequestSecurityConfig.requestAesKey,
    String? ivKey,
  }) {
    final effectiveIvKey = ivKey ?? RequestSecurityConfig.requestIvKey;
    return {bodyKey: cipherText, effectiveIvKey: ivBase64};
  }
}
