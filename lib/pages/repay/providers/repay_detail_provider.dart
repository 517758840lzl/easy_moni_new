import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repayDetailApiProvider = Provider<RepayDetailApi>((ref) {
  return RepayDetailApi();
});

final repayOrderDetailProvider = FutureProvider.autoDispose
    .family<RepayDetailRespData, RepayDetailQuery>((ref, query) async {
      final appOrderIds = query.appOrderIds;
      if (appOrderIds.isEmpty) {
        throw Exception(AppStrings.orderDetailNoOrderData);
      }
      final result = await ref
          .read(repayDetailApiProvider)
          .call(appOrderIds: appOrderIds, couponIds: query.couponIds);

      if (result.isSuccess && result.data != null) {
        return result.data!;
      }

      throw Exception(result.message ?? AppStrings.orderDetailLoadFailed);
    });

/// 还款详情查询参数：订单号和已选优惠券共同决定详情金额。
class RepayDetailQuery {
  const RepayDetailQuery({
    required this.appOrderIds,
    this.couponIds = const <int>[],
  });

  final List<String> appOrderIds;
  final List<int> couponIds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RepayDetailQuery &&
            listEquals(other.appOrderIds, appOrderIds) &&
            listEquals(other.couponIds, couponIds);
  }

  @override
  int get hashCode {
    return Object.hash(Object.hashAll(appOrderIds), Object.hashAll(couponIds));
  }
}

/// 将订单号列表转换成稳定的 provider family 查询参数。
RepayDetailQuery buildRepayDetailQuery({
  required Iterable<String?> appOrderIds,
  Iterable<int?> couponIds = const <int?>[],
}) {
  return RepayDetailQuery(
    appOrderIds: appOrderIds
        .whereType<String>()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(),
    couponIds: couponIds.whereType<int>().where((id) => id > 0).toList(),
  );
}

class RepayDetailApi {
  /// 获取用户要还款的订单详情，appOrderIds 为待还款订单号列表。
  Future<HttpResult<RepayDetailRespData>> call({
    required List<String> appOrderIds,
    List<int> couponIds = const <int>[],
  }) async {
    final result = await HttpProvider.instance.post<RepayDetailRespData>(
      ApiConstants.billDetails,
      data: {
        'appOrderIds': appOrderIds.map(_requestOrderId).toList(),
        'couponIds': couponIds,
      },
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

Object _requestOrderId(String appOrderId) {
  return int.tryParse(appOrderId) ?? appOrderId;
}
