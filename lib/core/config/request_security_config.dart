import 'dart:convert';

/// 请求安全配置，统一管理后端加密契约中的密钥和默认 IV 字段。
class RequestSecurityConfig {
  RequestSecurityConfig._();

  static const int aesBlockSize = 16;

  /// 请求体 AES 加密密钥，同时也是后端加密包的密文字段名。
  static const String requestAesKey = 'DK4h7cLWoYQf092pWm17836iTIR85MyZ';

  /// 默认 IV 字段名，按后端约定从 AES key 前 16 个 UTF-8 字节截取。
  static final String requestIvKey = _takeFirstUtf8Text(requestAesKey);

  static String _takeFirstUtf8Text(String text) {
    final bytes = utf8.encode(text);
    if (bytes.length < aesBlockSize) {
      throw ArgumentError.value(
        text,
        'text',
        'Text must contain at least $aesBlockSize UTF-8 bytes.',
      );
    }
    return utf8.decode(bytes.take(aesBlockSize).toList());
  }
}
