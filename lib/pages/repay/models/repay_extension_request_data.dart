import 'package:easy_moni/entities/repay/repay_detail_resp.dart';

/// 展期页面入参，保留订单详情，避免展期支付参数和优惠券参数重复拆字段。
class RepayExtensionRequestData {
  const RepayExtensionRequestData({
    required this.loanOrderDetails,
  });

  final List<RepayDetailRespDataLoanOrderDetails> loanOrderDetails;

  RepayDetailRespDataLoanOrderDetails? get firstOrder {
    if (loanOrderDetails.isEmpty) return null;
    return loanOrderDetails.first;
  }
}
