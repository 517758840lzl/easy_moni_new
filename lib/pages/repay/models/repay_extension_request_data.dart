import 'package:easy_moni/entities/repay/repay_detail_resp.dart';

class RepayExtensionRequestData {
  const RepayExtensionRequestData({required this.loanOrderDetails});

  factory RepayExtensionRequestData.fromJson(Map<String, dynamic> json) {
    return RepayExtensionRequestData(
      loanOrderDetails: (json['loanOrderDetails'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => RepayDetailRespDataLoanOrderDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  final List<RepayDetailRespDataLoanOrderDetails> loanOrderDetails;

  RepayDetailRespDataLoanOrderDetails? get firstOrder {
    if (loanOrderDetails.isEmpty) return null;
    return loanOrderDetails.first;
  }

  Map<String, dynamic> toJson() {
    return {
      'loanOrderDetails': loanOrderDetails
          .map((item) => item.toJson())
          .toList(),
    };
  }
}
