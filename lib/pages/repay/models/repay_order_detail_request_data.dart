/// 单笔还款详情页入参，仅携带接口请求需要的订单号。
class RepayOrderDetailRequestData {
  const RepayOrderDetailRequestData({required this.appOrderIds});

  final List<String> appOrderIds;
}
