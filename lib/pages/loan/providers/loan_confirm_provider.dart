import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../entities/coupon_resp.dart';
import '../../../entities/loan_confirm/loan_confirm_resp.dart';
import '../models/loan_confirm_request_product.dart';

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

  Future<HttpResult<CouponResp>> fetchCoupons() {
    return HttpProvider.instance.get<CouponResp>(
      ApiConstants.customerCouponList,
      fromJson: (json) => _parseCouponResp(json),
    );
  }

  Future<HttpResult<dynamic>> confirmOrder({
    required LoanConfirmData confirmData,
  }) {
    final orders = confirmData.list ?? const <LoanConfirmOrder>[];

    return HttpProvider.instance.post<dynamic>(
      ApiConstants.confirmOrder,
      data: {
        'bankId': '${confirmData.bankCardId ?? ''}',
        'couponIds': const [],
        'productInfoList': orders.map((item) {
          return {
            'appOrderId': item.appOrderId ?? 0,
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

  CouponResp _parseCouponResp(dynamic json) {
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      return CouponResp.fromJson(json);
    }
    if (json is Map) {
      return CouponResp.fromJson({'data': Map<String, dynamic>.from(json)});
    }
    return const CouponResp();
  }
}
