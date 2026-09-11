import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final flowStageIngestProvider = Provider<FlowStageIngestApi>((ref) {
  return FlowStageIngestApi();
});

class FlowStageIngestApi {
  Future<HttpResult<dynamic>> call({
    required int trackId,
    String? deviceInfoBytes,
  }) async {
    final hasGpsPermission =
        (await LocationService.checkPermission()) ? 1 : 0;

    final data = <String, dynamic>{
      'trackId': trackId,
      'hasGpsPermission': hasGpsPermission,
      'submitUserDeviceInfoBytes': deviceInfoBytes ?? '',
      'submitUserDeviceInfoReq': const {},
    };

    return HttpProvider.instance.post<dynamic>(
      ApiConstants.flowStageIngest,
      data: data,
      fromJson: (json) => json,
    );
  }
}
