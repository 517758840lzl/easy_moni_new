import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/customer_service_info_resp.dart';

final customerServiceInfoProvider = Provider<CustomerServiceInfoApi>((ref) {
  return CustomerServiceInfoApi();
});

class CustomerServiceInfoApi {
  /// 获取客服信息
  Future<HttpResult<CustomerServiceInfoResp>> call() async {
    final result = await HttpProvider.instance.get<CustomerServiceInfoResp>(
      ApiConstants.customerServiceInfo,
      fromJson: (json) => CustomerServiceInfoResp.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }
}
