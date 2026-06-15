import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/bill_details_resp.dart';

final billDetailsProvider = Provider<BillDetailsApi>((ref) {
  return BillDetailsApi();
});

class BillDetailsApi {
  /// 获取账单详情
  /// [appOrderIds] 订单ID列表
  Future<HttpResult<BillDetailsResp>> call({
    required List<String> appOrderIds,
  }) async {
    // 将字符串ID转换为 int
    final ids = appOrderIds.map((id) {
      if (id is String) {
        return int.tryParse(id) ?? 0;
      }
      return id as int;
    }).toList();

    final result = await HttpProvider.instance.post<Map<String, dynamic>>(
      ApiConstants.billDetails,
      data: {'appOrderIds': ids},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(BillDetailsResp.fromJson(result.data!));
    } else {
      return HttpResult.error(
        HttpResultStatus.serverError,
        result.message ?? '获取账单详情失败',
      );
    }
  }
}
