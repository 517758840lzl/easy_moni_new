import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/extension_resp.dart';

final extensionProvider = Provider<ExtensionApi>((ref) {
  return ExtensionApi();
});

class ExtensionApi {
  /// 获取展期还款详情
  /// [couponIds] 优惠券ID列表
  /// [installmentId] 分期ID
  Future<HttpResult<ExtensionResp>> call({
    List<int> couponIds = const [],
    required int installmentId,
  }) async {
    final result = await HttpProvider.instance.post<Map<String, dynamic>>(
      ApiConstants.extension,
      data: {'couponIds': couponIds, 'installmentId': installmentId},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(ExtensionResp.fromJson(result.data!));
    } else {
      return HttpResult.error(
        HttpResultStatus.serverError,
        result.message ?? '获取展期详情失败',
      );
    }
  }
}
