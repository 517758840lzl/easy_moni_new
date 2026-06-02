import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';

final submitAcpElementInfoProvider = Provider<SubmitAcpElementInfoApi>((ref) {
  return SubmitAcpElementInfoApi();
});

class SubmitAcpElementInfoApi {
  /// 提交KYC步骤数据
  /// [processId] 流程ID
  /// [step] 步骤
  /// [jsonParam] 按文档格式提交的字段列表
  Future<HttpResult<dynamic>> call({
    required int processId,
    required int step,
    List<Map<String, dynamic>>? jsonParam,
    Map<String, dynamic>? data,
    int isUpdate = 0,
  }) async {
    final requestBody = jsonParam != null
        ? {
            'isUpdate': isUpdate,
            'jsonParam': jsonParam,
            'processId': processId,
            'step': step,
          }
        : {
            'processId': processId,
            'step': step,
            'data': data ?? <String, dynamic>{},
          };

    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.submitAcpElementInfo,
      data: requestBody,
      fromJson: (json) => json,
    );
    return result;
  }
}
