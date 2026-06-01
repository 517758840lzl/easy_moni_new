import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';

final submitAcpElementInfoProvider = Provider<SubmitAcpElementInfoApi>((ref) {
  return SubmitAcpElementInfoApi();
});

class SubmitAcpElementInfoApi {
  /// 提交KYC步骤数据
  ///  流程ID
  ///  步骤
  ///  提交的表单数据
  Future<HttpResult<dynamic>> call({
    required int processId,
    required int step,
    required Map<String, dynamic> data,
  }) async {
    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.submitAcpElementInfo,
      data: {'processId': processId, 'step': step, 'data': data},
      fromJson: (json) => json,
    );
    return result;
  }
}
