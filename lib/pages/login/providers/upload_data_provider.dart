import 'dart:typed_data';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submitUserUploadDataProvider = Provider<SubmitUserUploadDataApi>((ref) {
  return SubmitUserUploadDataApi();
});

class SubmitUserUploadDataApi {
  /// 上传重新采集并压缩后的用户风控数据。
  Future<HttpResult<dynamic>> call({
    required int trackId,
    Uint8List? deviceInfoBytes,
    Uint8List? appListBytes,
    Uint8List? smsRecordBytes,
  }) {
    final data = <String, dynamic>{
      'trackId': trackId,
      if (appListBytes != null && appListBytes.isNotEmpty)
        'submitUserAppListBytes': appListBytes.toList(),
      if (deviceInfoBytes != null && deviceInfoBytes.isNotEmpty)
        'submitUserDeviceInfoBytes': deviceInfoBytes.toList(),
      if (smsRecordBytes != null && smsRecordBytes.isNotEmpty)
        'submitUserSmsBytes': smsRecordBytes.toList(),
    };

    return HttpProvider.instance.post<dynamic>(
      ApiConstants.submitUserUploadData,
      data: data,
      fromJson: (json) => json,
    );
  }
}
