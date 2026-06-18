/// 付款接口订单分配明细，描述每笔账单本次承担的支付金额。
class PaymentAllocation {
  const PaymentAllocation({
    required this.allocationAmount,
    required this.appOrderId,
    required this.installmentId,
  });

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

/// 付款订单类型
class PaymentOrderTypes {
  const PaymentOrderTypes._();

  static const int normal = 1;
  static const int extension = 2;
}
