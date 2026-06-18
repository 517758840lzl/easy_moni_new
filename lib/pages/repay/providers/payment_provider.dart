import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/payment_resp.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentApiProvider = Provider<PaymentApi>((ref) {
  return PaymentApi();
});

final paymentUrlProvider = FutureProvider.autoDispose
    .family<PaymentRespData, PaymentRequestParams>((ref, params) async {
      if (params.allocations.isEmpty) {
        throw Exception(AppStrings.paymentNoOrderData);
      }

      final result = await ref.read(paymentApiProvider).call(params);
      final payUrl = result.data?.payUrl?.trim();

      if (result.isSuccess &&
          result.data != null &&
          payUrl?.isNotEmpty == true) {
        return result.data!;
      }

      throw Exception(result.message ?? AppStrings.paymentGenerateFailed);
    });

class PaymentApi {
  /// 调用付款接口生成 H5 支付链接。
  Future<HttpResult<PaymentRespData>> call(PaymentRequestParams params) async {
    final result = await HttpProvider.instance.post<PaymentRespData>(
      ApiConstants.generatesUrl,
      data: params.toJson(),
      fromJson: (json) =>
          PaymentRespData.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(result.data!);
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? AppStrings.paymentGenerateFailed,
    );
  }
}
