import 'package:easy_moni/entities/repay/repay_resp.dart';

/// 展期页面入参，隔离列表账单模型和展期接口所需的详情字段。
class RepayExtensionRequestData {
  const RepayExtensionRequestData({
    required this.bill,
    required this.installmentId,
  });

  final RepayResp bill;
  final int? installmentId;
}
