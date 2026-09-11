import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_moni/core/config/request_security_config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

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

  static bool isEncryptedTransportBody(
    Map<dynamic, dynamic> data, {
    String bodyKey = RequestSecurityConfig.requestAesKey,
    String? ivKey,
  }) {
    final effectiveIvKey = ivKey ?? RequestSecurityConfig.requestIvKey;
    return data[bodyKey] is String && data[effectiveIvKey] is String;
  }

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

class RequestEncryptionResult {
  const RequestEncryptionResult({
    required this.cipherText,
    required this.ivBase64,
  });

  final String cipherText;
  final String ivBase64;

  Map<String, dynamic> toRequestBody({
    String bodyKey = RequestSecurityConfig.requestAesKey,
    String? ivKey,
  }) {
    final effectiveIvKey = ivKey ?? RequestSecurityConfig.requestIvKey;
    return {bodyKey: cipherText, effectiveIvKey: ivBase64};
  }
}
