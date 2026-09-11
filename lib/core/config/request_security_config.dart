import 'dart:convert';

class RequestSecurityConfig {
  RequestSecurityConfig._();

  static const int aesBlockSize = 16;

  static const String requestAesKey = 'DK4h7cLWoYQf092pWm17836iTIR85MyZ';

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
