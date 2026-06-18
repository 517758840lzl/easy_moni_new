import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 还款入口页订单状态定义，集中管理待还款列表请求参数。
class RepayListOrderStatus {
  RepayListOrderStatus._();

  static const int repaying = 4;
  static const List<int> waitingRepaymentStatusList = <int>[repaying];
}

final repayListApiProvider = Provider<RepayListApi>((ref) {
  return RepayListApi();
});

final repayEntryBillsProvider = FutureProvider.autoDispose<List<RepayResp>>((
  ref,
) async {
  final result = await ref
      .read(repayListApiProvider)
      .call(statusList: RepayListOrderStatus.waitingRepaymentStatusList);

  if (result.isSuccess) {
    return result.data ?? const <RepayResp>[];
  }

  throw Exception(result.message ?? 'Load repayment list failed');
});

class RepayListApi {
  /// 获取待还款列表，statusList 为订单状态列表，当前入口页固定请求 [4]。
  Future<HttpResult<List<RepayResp>>> call({
    required List<int> statusList,
  }) async {
    final result = await HttpProvider.instance.post<List<dynamic>>(
      ApiConstants.userRepayment,
      data: {'statusList': statusList},
      fromJson: (json) => json as List<dynamic>,
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(_parseList(result.data!));
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? 'Load repayment list failed',
    );
  }
}

List<RepayResp> _parseList(List<dynamic> data) {
  return data
      .map((item) => RepayResp.fromJson(item as Map<String, dynamic>))
      .toList();
}
