import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class UploadDataCompressTool {
  const UploadDataCompressTool._();

  /// 将待上传数据序列化为 JSON，并使用 zlib 压缩。
  static Uint8List compressDeviceData(dynamic payload) {
    try {
      final encoded = utf8.encode(jsonEncode(payload));
      final compressed = ZLibEncoder().convert(encoded);
      return Uint8List.fromList(compressed);
    } catch (error) {
      return Uint8List(0);
    }
  }

  /// 与 active-loan 一致：zlib 压缩后再 Base64 编码成字符串上传。
  static String compressDeviceDataBase64(dynamic payload) {
    final bytes = compressDeviceData(payload);
    if (bytes.isEmpty) return '';
    return base64Encode(bytes);
  }
}
