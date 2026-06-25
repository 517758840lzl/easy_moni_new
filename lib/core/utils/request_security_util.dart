import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

/// 请求安全工具，集中处理请求体 AES 加密和后续混淆扩展。
class RequestSecurityUtil {
  RequestSecurityUtil._();

  static const String algorithm = 'AES/CBC/PKCS7';
  static const int _aesBlockSize = 16;
  static const Set<int> _validKeyLengths = {16, 24, 32};

  /// 将普通 JSON 数据加密为后端可接收的请求体结构。
  static Map<String, dynamic> encryptRequestBody(
    Object? data, {
    required String aesKey,
    String bodyKey = 'body',
    String ivKey = 'iv',
    String algorithmKey = 'algorithm',
    String? ivBase64,
    bool enableObfuscation = false,
  }) {
    final result = encryptJson(
      data,
      aesKey: aesKey,
      ivBase64: ivBase64,
      enableObfuscation: enableObfuscation,
    );
    // TODO: 与后端确认最终加密请求体字段名和是否需要上送 algorithm。
    return result.toRequestBody(
      bodyKey: bodyKey,
      ivKey: ivKey,
      algorithmKey: algorithmKey,
    );
  }

  /// 将 JSON 数据序列化后使用 AES-CBC 加密。
  static RequestEncryptionResult encryptJson(
    Object? data, {
    required String aesKey,
    String? ivBase64,
    bool enableObfuscation = false,
  }) {
    return encryptText(
      jsonEncode(data),
      aesKey: aesKey,
      ivBase64: ivBase64,
      enableObfuscation: enableObfuscation,
    );
  }

  /// 加密字符串内容，返回密文、IV 和算法信息。
  static RequestEncryptionResult encryptText(
    String plainText, {
    required String aesKey,
    String? ivBase64,
    bool enableObfuscation = false,
  }) {
    final key = _buildKey(aesKey);
    final iv = _buildIv(ivBase64);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final cipherText = _protectText(
      encrypted.base64,
      enableObfuscation: enableObfuscation,
    );

    return RequestEncryptionResult(
      cipherText: cipherText,
      ivBase64: iv.base64,
      algorithm: algorithm,
      isObfuscated: enableObfuscation,
    );
  }

  /// 解密 JSON 密文，便于本地测试和排查加密链路。
  static dynamic decryptJson({
    required String cipherText,
    required String aesKey,
    required String ivBase64,
    bool enableObfuscation = false,
  }) {
    final plainText = decryptText(
      cipherText: cipherText,
      aesKey: aesKey,
      ivBase64: ivBase64,
      enableObfuscation: enableObfuscation,
    );
    return jsonDecode(plainText);
  }

  /// 解密字符串密文，便于验证 AES 参数是否与后端一致。
  static String decryptText({
    required String cipherText,
    required String aesKey,
    required String ivBase64,
    bool enableObfuscation = false,
  }) {
    final key = _buildKey(aesKey);
    final iv = _buildIv(ivBase64);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
    final normalizedCipherText = _restoreText(
      cipherText,
      enableObfuscation: enableObfuscation,
    );

    return encrypter.decrypt64(normalizedCipherText, iv: iv);
  }

  /// 处理请求头混淆；测试阶段默认保持原样。
  static Map<String, String> protectHeaders(
    Map<String, String> headers, {
    bool enableObfuscation = false,
  }) {
    if (!enableObfuscation) {
      return Map<String, String>.from(headers);
    }

    // TODO: 与后端确认请求头混淆规则后替换当前占位实现。
    return headers.map(
      (key, value) => MapEntry(
        _protectText(key, enableObfuscation: true),
        _protectText(value, enableObfuscation: true),
      ),
    );
  }

  /// 处理接口地址混淆；测试阶段默认保持原样。
  static String protectUrl(String url, {bool enableObfuscation = false}) {
    if (!enableObfuscation) {
      return url;
    }

    // TODO: 与后端确认接口地址混淆规则后替换当前占位实现。
    return _protectText(url, enableObfuscation: true);
  }

  static encrypt.Key _buildKey(String aesKey) {
    final keyBytes = utf8.encode(aesKey);
    if (!_validKeyLengths.contains(keyBytes.length)) {
      throw ArgumentError('AES key must be 16, 24, or 32 UTF-8 bytes.');
    }
    return encrypt.Key.fromUtf8(aesKey);
  }

  static encrypt.IV _buildIv(String? ivBase64) {
    if (ivBase64 == null || ivBase64.isEmpty) {
      return encrypt.IV.fromSecureRandom(_aesBlockSize);
    }

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

  static String _protectText(String text, {required bool enableObfuscation}) {
    if (!enableObfuscation) {
      return text;
    }

    final bytes = utf8.encode(text);
    return base64UrlEncode(bytes);
  }

  static String _restoreText(String text, {required bool enableObfuscation}) {
    if (!enableObfuscation) {
      return text;
    }

    return utf8.decode(base64Url.decode(text));
  }
}

/// AES 加密后的请求数据结果。
class RequestEncryptionResult {
  const RequestEncryptionResult({
    required this.cipherText,
    required this.ivBase64,
    required this.algorithm,
    required this.isObfuscated,
  });

  final String cipherText;
  final String ivBase64;
  final String algorithm;
  final bool isObfuscated;

  /// 转换为请求体 Map，方便 HttpProvider 后续统一接入。
  Map<String, dynamic> toRequestBody({
    String bodyKey = 'body',
    String ivKey = 'iv',
    String algorithmKey = 'algorithm',
  }) {
    return {bodyKey: cipherText, ivKey: ivBase64, algorithmKey: algorithm};
  }
}
