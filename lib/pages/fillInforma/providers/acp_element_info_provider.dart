import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/acp_element_info_resp.dart';

final acpElementInfoProvider = Provider<AcpElementInfoApi>((ref) {
  return AcpElementInfoApi();
});

class AcpElementInfoApi {
  /// 查询KYC步骤数据
  /// 步骤编号
  Future<HttpResult<AcpElementInfoResp>> call(int step) async {
    final result = await HttpProvider.instance.get<AcpElementInfoResp>(
      ApiConstants.queryAcpElementInfo,
      params: {'step': step},
      fromJson: (json) => AcpElementInfoResp.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }
}
