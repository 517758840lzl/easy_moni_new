import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/upload_data/upload_platform_support.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submitUserUploadDataProvider = Provider<SubmitUserUploadDataApi>((ref) {
  return SubmitUserUploadDataApi();
});

class SubmitUserUploadDataApi {
  Future<HttpResult<dynamic>> call({
    required int trackId,
    String? deviceInfoBytes,
    String? appListBytes,
    String? smsRecordBytes,
  }) async {
    final hasGpsPermission =
        (await LocationService.checkPermission()) ? 1 : 0;
    final hasSmsPermission =
        UploadPlatformSupport.supportsAppListAndSms &&
            (await SmsService.checkPermission())
        ? 1
        : 0;

    final data = <String, dynamic>{
      'trackId': trackId,
      'hasContactPermission': 0,
      'hasGpsPermission': hasGpsPermission,
      'hasSmsPermission': hasSmsPermission,
      'submitUserConnectBytes': '',
      'submitUserConnectReq': const [],
      'submitUserAppListBytes': appListBytes ?? '',
      'submitUserAppListReq': const [],
      'submitUserDeviceInfoBytes': deviceInfoBytes ?? '',
      'submitUserDeviceInfoReq': const {},
      'submitUserSmsBytes': smsRecordBytes ?? '',
      'submitUserSmsReq': const [],
    };

    return HttpProvider.instance.post<dynamic>(
      ApiConstants.submitUserUploadData,
      data: data,
      fromJson: (json) => json,
    );
  }
}
