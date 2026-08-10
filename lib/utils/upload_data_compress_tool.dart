import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class UploadDataCompressTool {
  const UploadDataCompressTool._();

  static Uint8List compressDeviceData(dynamic payload) {
    try {
      final encoded = utf8.encode(jsonEncode(payload));
      final compressed = ZLibEncoder().convert(encoded);
      return Uint8List.fromList(compressed);
    } catch (error) {
      return Uint8List(0);
    }
  }

  static String compressDeviceDataBase64(dynamic payload) {
    final bytes = compressDeviceData(payload);
    if (bytes.isEmpty) return '';
    return base64Encode(bytes);
  }
}
