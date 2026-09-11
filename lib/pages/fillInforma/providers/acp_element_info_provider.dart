import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final acpElementInfoProvider = Provider<AcpElementInfoApi>((ref) {
  return AcpElementInfoApi();
});

class AcpElementInfoApi {
  Future<HttpResult<AcpElementInfoResp>> call(int step) async {
    return HttpProvider.instance.get<AcpElementInfoResp>(
      ApiConstants.queryAcpElementInfo,
      params: {'step': step},
      fromJson: (json) =>
          AcpElementInfoResp.fromJson(json as Map<String, dynamic>),
    );
  }
}
