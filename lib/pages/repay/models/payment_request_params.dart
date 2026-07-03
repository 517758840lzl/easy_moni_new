/// 付款接口订单分配明细，描述每笔账单本次承担的支付金额。
class PaymentAllocation {
  const PaymentAllocation({
    required this.allocationAmount,
    required this.appOrderId,
    required this.installmentId,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) {
    return PaymentAllocation(
      allocationAmount: json['allocationAmount'] as num? ?? 0,
      appOrderId: json['appOrderId'] as Object? ?? '',
      installmentId: json['installmentId'] as int? ?? 0,
    );
  }

  final num allocationAmount;
  final Object appOrderId;
  final int installmentId;

  Map<String, dynamic> toJson() {
    return {
      'allocationAmount': allocationAmount,
      'appOrderId': appOrderId,
      'installmentId': installmentId,
    };
  }
}

/// 付款接口请求参数，供普通还款和展期支付统一跳转到 H5 容器页。
class PaymentRequestParams {
  const PaymentRequestParams({
    required this.allocations,
    required this.couponIds,
    required this.orderType,
    required this.repayAmount,
    this.choseProductCodes = const <String>[],
    this.currentAppVersion = '',
    this.originalTotalRepayAmount,
    this.payType = '',
    this.repayChannel = '',
  });

  factory PaymentRequestParams.fromJson(Map<String, dynamic> json) {
    return PaymentRequestParams(
      allocations: _jsonList(json['allocations'])
          .whereType<Map>()
          .map(
            (item) =>
                PaymentAllocation.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      couponIds: _jsonList(json['couponIds']).whereType<int>().toList(),
      orderType: json['orderType'] as int? ?? 0,
      repayAmount: json['repayAmount'] as num? ?? 0,
      choseProductCodes: _jsonList(
        json['choseProductCodes'],
      ).whereType<String>().toList(),
      currentAppVersion: json['currentAppVersion'] as String? ?? '',
      originalTotalRepayAmount: json['originalTotalRepayAmount'] as num?,
      payType: json['payType'] as String? ?? '',
      repayChannel: json['repayChannel'] as String? ?? '',
    );
  }

  final List<PaymentAllocation> allocations;
  final List<int> couponIds;
  final int orderType;
  final num repayAmount;
  final List<String> choseProductCodes;
  final String currentAppVersion;
  final num? originalTotalRepayAmount;
  final String payType;
  final String repayChannel;

  Map<String, dynamic> toJson() {
    return {
      'allocations': allocations.map((item) => item.toJson()).toList(),
      'choseProductCodes': choseProductCodes,
      'couponIds': couponIds,
      'currentAppVersion': currentAppVersion,
      'orderType': orderType,
      'originalTotalRepayAmount': originalTotalRepayAmount ?? 0,
      'payType': payType,
      'repayAmount': repayAmount,
      'repayChannel': repayChannel,
    };
  }
}

List<Object?> _jsonList(Object? value) {
  return value is List ? value.cast<Object?>() : const <Object?>[];
}

/// 付款订单类型
class PaymentOrderTypes {
  const PaymentOrderTypes._();

  static const int normal = 1;
  static const int extension = 2;
}
