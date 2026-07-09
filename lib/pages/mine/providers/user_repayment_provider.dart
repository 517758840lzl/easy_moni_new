import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/user_repayment_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepaymentProvider = Provider<UserRepaymentApi>((ref) {
  return UserRepaymentApi();
});

class UserRepaymentApi {
  /// Fetches the user's repayment list.
  /// [statusList] Order status list, such as [4] for repaying.
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
        result.message ?? AppStrings.userRepaymentLoadFailed,
      );
    }
  }
}
