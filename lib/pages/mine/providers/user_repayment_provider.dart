import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/user_repayment_resp.dart';

final userRepaymentProvider = Provider<UserRepaymentApi>((ref) {
  return UserRepaymentApi();
});

class UserRepaymentApi {
  /// 获取用户还款列表
  /// [statusList] 订单状态列表，如 [4] 表示还款中(Reembolso)
  Future<HttpResult<List<UserRepaymentResp>>> call({
    required List<int> statusList,
  }) async {
    final result = await HttpProvider.instance.post<List<dynamic>>(
      ApiConstants.userRepayment,
      data: {'statusList': statusList},
      fromJson: (json) => json as List<dynamic>,
    );

    if (result.isSuccess && result.data != null) {
      final list = result.data!
          .map((e) => UserRepaymentResp.fromJson(e as Map<String, dynamic>))
          .toList();
      return HttpResult.success(list);
    } else {
      return HttpResult.error(
        HttpResultStatus.serverError,
        result.message ?? '获取还款列表失败',
      );
    }
  }
}
