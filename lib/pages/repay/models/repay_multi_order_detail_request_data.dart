/// 多订单还款详情页入参，仅携带接口请求需要的订单号列表。
class RepayMultiOrderDetailRequestData {
  const RepayMultiOrderDetailRequestData({required this.appOrderIds});

  final List<String> appOrderIds;
}
