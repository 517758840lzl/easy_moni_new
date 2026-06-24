import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/acquisition_progress_resp.dart';

final acquisitionProgressProvider = Provider<AcquisitionProgressApi>((ref) {
  return AcquisitionProgressApi();
});

class AcquisitionProgressApi {
  /// 查询用户状态
  Future<HttpResult<AcquisitionProgressResp>> call() async {
    final result = await HttpProvider.instance.get<AcquisitionProgressResp>(
      ApiConstants.queryAcquisitionProgress,
      fromJson: (json) =>
          AcquisitionProgressResp.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }
}
