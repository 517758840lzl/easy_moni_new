import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/loan_confirm/loan_confirm_resp.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';

final loanConfirmProvider = Provider<LoanConfirmApi>((ref) {
  return LoanConfirmApi();
});

class LoanConfirmApi {
  Future<HttpResult<LoanConfirmResp>> fetchConfirmInfo({
    required List<LoanConfirmRequestProduct> products,
    int isResetCountDownTime = 1,
  }) {
    return HttpProvider.instance.post<LoanConfirmResp>(
      ApiConstants.confirmUserApplyAmountInfo,
      data: {
        'isResetCountDownTime': isResetCountDownTime,
        'list': products.map((item) => item.toJson()).toList(),
      },
      fromJson: (json) => _parseLoanConfirmResp(json),
    );
  }

  Future<HttpResult<dynamic>> confirmOrder({
    required LoanConfirmData confirmData,
    List<int> couponIds = const <int>[],
  }) {
    final orders = confirmData.list ?? const <LoanConfirmOrder>[];

    return HttpProvider.instance.post<dynamic>(
      ApiConstants.confirmOrder,
      data: {
        'bankId': '${confirmData.bankCardId ?? ''}',
        'couponIds': couponIds,
        'productInfoList': orders.map((item) {
          return {
            'appOrderId': item.appOrderId ?? 0,
            // 优惠券只通过 couponIds 传递，借款金额保持确认页原始订单金额。
            'loanAmount': item.loanAmount ?? 0,
            'productCode': item.productCode ?? '',
          };
        }).toList(),
      },
      fromJson: (json) => json,
    );
  }

  LoanConfirmResp _parseLoanConfirmResp(dynamic json) {
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      return LoanConfirmResp.fromJson(json);
    }
    if (json is Map) {
      return LoanConfirmResp.fromJson({
        'data': Map<String, dynamic>.from(json),
      });
    }
    return const LoanConfirmResp();
  }
}
