import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_extension_resp.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repayExtensionApiProvider = Provider<RepayExtensionApi>((ref) {
  return RepayExtensionApi();
});

final repayExtensionProvider = FutureProvider.autoDispose
    .family<RepayExtensionRespData, RepayExtensionQuery>((ref, query) async {
      final installmentId = query.installmentId;
      if (installmentId == null || installmentId <= 0) {
        throw Exception(AppStrings.repayExtensionNoOrderData);
      }

      final result = await ref
          .read(repayExtensionApiProvider)
          .call(installmentId: installmentId, couponIds: query.couponIds);

      if (result.isSuccess && result.data != null) {
        return result.data!;
      }

      throw Exception(result.message ?? AppStrings.repayExtensionLoadFailed);
    });

/// 展期详情查询参数：账单 ID 和已选优惠券共同决定重新试算后的展期金额。
class RepayExtensionQuery {
  const RepayExtensionQuery({
    required this.installmentId,
    this.couponIds = const <int>[],
  });

  final int? installmentId;
  final List<int> couponIds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RepayExtensionQuery &&
            other.installmentId == installmentId &&
            listEquals(other.couponIds, couponIds);
  }

  @override
  int get hashCode {
    return Object.hash(installmentId, Object.hashAll(couponIds));
  }
}

/// 将页面状态转换成稳定的 provider family 查询参数。
RepayExtensionQuery buildRepayExtensionQuery({
  required int? installmentId,
  Iterable<int?> couponIds = const <int?>[],
}) {
  return RepayExtensionQuery(
    installmentId: installmentId,
    couponIds: couponIds.whereType<int>().where((id) => id > 0).toList(),
  );
}

class RepayExtensionApi {
  /// 获取展期详情，installmentId 为当前申请展期账单的ID。
  Future<HttpResult<RepayExtensionRespData>> call({
    required int installmentId,
    List<int> couponIds = const <int>[],
  }) async {
    final result = await HttpProvider.instance.post<RepayExtensionRespData>(
      ApiConstants.extension,
      data: {'couponIds': couponIds, 'installmentId': installmentId},
      fromJson: (json) =>
          RepayExtensionRespData.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(result.data!);
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? AppStrings.repayExtensionLoadFailed,
    );
  }
}
