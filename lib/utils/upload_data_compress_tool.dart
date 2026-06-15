import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_moni/core/utils/app_logger.dart';

class UploadDataCompressTool {
  const UploadDataCompressTool._();

  /// 将待上传数据序列化为 JSON，并使用 zlib 压缩成接口需要的二进制内容。
  static Uint8List compressDeviceData(dynamic payload) {
    try {
      final encoded = utf8.encode(jsonEncode(payload));
      final compressed = ZLibEncoder().convert(encoded);
      return Uint8List.fromList(compressed);
    } catch (error, stackTrace) {
      AppLogger.debug('UploadDataCompressTool 压缩异常: $error\n$stackTrace');
      return Uint8List(0);
    }
  }
}
