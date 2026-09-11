import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/service/service_info_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerServiceInfoProvider = Provider<CustomerServiceInfoApi>((ref) {
  return CustomerServiceInfoApi();
});

class CustomerServiceInfoApi {
  Future<HttpResult<ServiceInfoRespData>> call() async {
    final result = await HttpProvider.instance.get<ServiceInfoRespData>(
      ApiConstants.customerServiceInfo,
      includeToken: false,
      fromJson: (json) =>
          ServiceInfoRespData.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }
}

final customerServiceInfoAsyncProvider =
    FutureProvider.autoDispose<ServiceInfoRespData>((ref) async {
      final result = await ref.read(customerServiceInfoProvider).call();
      if (result.isSuccess && result.data != null) {
        return result.data!;
      }
      throw Exception(result.message ?? 'Failed to load customer service info');
    });
