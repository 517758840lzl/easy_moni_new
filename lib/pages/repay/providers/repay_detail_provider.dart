import 'dart:convert';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repayDetailApiProvider = Provider<RepayDetailApi>((ref) {
  return RepayDetailApi();
});

final mockRepayDetailApiProvider = Provider<MockRepayDetailApi>((ref) {
  return MockRepayDetailApi();
});

final repayOrderDetailProvider = FutureProvider.autoDispose
    .family<RepayDetailRespData, String>((ref, appOrderIdsParam) async {
      final appOrderIds = parseRepayDetailAppOrderIds(appOrderIdsParam);
      if (appOrderIds.isEmpty) {
        throw Exception(AppStrings.orderDetailNoOrderData);
      }

      // TODO: 当前按页面联调诉求使用本地 Mock API 展示；真实环境切换规则待确认后接入 repayDetailApiProvider。
      final result = await ref
          .read(repayDetailApiProvider)
          .call(appOrderIds: appOrderIds);

      if (result.isSuccess && result.data != null) {
        return result.data!;
      }

      throw Exception(result.message ?? AppStrings.orderDetailLoadFailed);
    });

/// 将路由入参中的订单号串还原为接口请求需要的订单号列表。
List<String> parseRepayDetailAppOrderIds(String appOrderIdsParam) {
  return appOrderIdsParam
      .split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList();
}

/// 将订单号列表转换成稳定的 provider family 参数。
String buildRepayDetailAppOrderIdsParam(Iterable<String?> appOrderIds) {
  return appOrderIds
      .whereType<String>()
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .join(',');
}

class RepayDetailApi {
  /// 获取用户要还款的订单详情，appOrderIds 为待还款订单号列表。
  Future<HttpResult<RepayDetailRespData>> call({
    required List<String> appOrderIds,
  }) async {
    final result = await HttpProvider.instance.post<RepayDetailRespData>(
      ApiConstants.billDetails,
      data: {'appOrderIds': appOrderIds.map(_requestOrderId).toList()},
      fromJson: (json) =>
          RepayDetailRespData.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(result.data!);
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? AppStrings.orderDetailLoadFailed,
    );
  }
}

class MockRepayDetailApi {
  static const String _mockAssetPath = 'lib/pages/repay/mock/repay_detail.json';

  /// 模拟还款详情接口，从本地 JSON 读取数据并延迟返回，方便页面联调。
  Future<HttpResult<RepayDetailRespData>> call({
    required List<String> appOrderIds,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final source = await rootBundle.loadString(_mockAssetPath);
      final map = jsonDecode(source) as Map<String, dynamic>;
      final resp = RepayDetailResp.fromJson(map);
      final data = resp.data;

      if (resp.code != 200 || data == null) {
        return HttpResult.error(
          HttpResultStatus.serverError,
          resp.msg ?? AppStrings.orderDetailLoadFailed,
        );
      }

      final targetIds = appOrderIds.toSet();
      final details = data.loanOrderDetails ?? const [];
      final filteredDetails = details
          .where((item) => targetIds.contains(item.appOrderId))
          .toList();

      return HttpResult.success(
        data.copyWith(loanOrderDetails: filteredDetails),
      );
    } catch (e) {
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }
}

Object _requestOrderId(String appOrderId) {
  return int.tryParse(appOrderId) ?? appOrderId;
}
