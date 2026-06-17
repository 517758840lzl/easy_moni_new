/// 展期页面入参，隔离还款详情订单模型和展期接口所需字段。
class RepayExtensionRequestData {
  const RepayExtensionRequestData({
    required this.appOrderId,
    required this.productCode,
    required this.installmentId,
  });

  final String appOrderId;
  final String productCode;
  final int? installmentId;
}
