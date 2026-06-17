import 'dart:convert';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:flutter/services.dart';
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

final mockRepayListApiProvider = Provider<MockRepayListApi>((ref) {
  return MockRepayListApi();
});

final repayEntryBillsProvider = FutureProvider.autoDispose<List<RepayResp>>((
  ref,
) async {
  // TODO: 当前按页面联调诉求使用本地 Mock API 展示；真实环境切换规则待确认后接入 repayListApiProvider。
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

class MockRepayListApi {
  static const String _mockAssetPath = 'lib/pages/repay/mock/repay_list.json';

  /// 模拟待还款列表接口，从本地 JSON 读取数据并延迟返回，方便页面联调。
  Future<HttpResult<List<RepayResp>>> call({
    required List<int> statusList,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final source = await rootBundle.loadString(_mockAssetPath);
      final map = jsonDecode(source) as Map<String, dynamic>;
      final code = map['code'] as int?;
      final rawData = map['data'];

      if (code != 200 || rawData is! List) {
        return HttpResult.error(
          HttpResultStatus.serverError,
          map['msg']?.toString() ?? 'Load repayment list failed',
        );
      }

      final list = _parseList(
        rawData,
      ).where((item) => statusList.contains(item.orderStatus)).toList();

      return HttpResult.success(list);
    } catch (e) {
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }
}

List<RepayResp> _parseList(List<dynamic> data) {
  return data
      .map((item) => RepayResp.fromJson(item as Map<String, dynamic>))
      .toList();
}
