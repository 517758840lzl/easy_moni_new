import 'dart:convert';

import 'package:easy_moni/core/utils/request_security_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const aesKey = '1234567890123456';
  final ivBase64 = base64Encode(List<int>.filled(16, 1));

  group('RequestSecurityUtil', () {
    test('encryptJson encrypts and decrypts request data', () {
      final requestData = {'phone': '13800138000', 'amount': 1000};

      final result = RequestSecurityUtil.encryptJson(
        requestData,
        aesKey: aesKey,
        ivBase64: ivBase64,
      );

      expect(result.cipherText, isNot(jsonEncode(requestData)));
      expect(result.ivBase64, ivBase64);
      expect(result.algorithm, RequestSecurityUtil.algorithm);
      expect(result.isObfuscated, isFalse);

      final decrypted = RequestSecurityUtil.decryptJson(
        cipherText: result.cipherText,
        aesKey: aesKey,
        ivBase64: result.ivBase64,
      );

      expect(decrypted, requestData);
    });

    test('encryptRequestBody builds default transport payload', () {
      final payload = RequestSecurityUtil.encryptRequestBody(
        {'code': '123456'},
        aesKey: aesKey,
        ivBase64: ivBase64,
      );

      expect(payload.keys, containsAll(['body', 'iv', 'algorithm']));
      expect(payload['body'], isA<String>());
      expect(payload['iv'], ivBase64);
      expect(payload['algorithm'], RequestSecurityUtil.algorithm);
    });

    test('protectUrl and protectHeaders keep values unchanged by default', () {
      const url = '/api/user/login';
      final headers = {'token': 'abc', 'deviceId': 'device-id'};

      expect(RequestSecurityUtil.protectUrl(url), url);
      expect(RequestSecurityUtil.protectHeaders(headers), headers);
    });

    test('throws when aes key length is invalid', () {
      expect(
        () => RequestSecurityUtil.encryptText(
          'plain',
          aesKey: 'short',
          ivBase64: ivBase64,
        ),
        throwsArgumentError,
      );
    });
  });
}
