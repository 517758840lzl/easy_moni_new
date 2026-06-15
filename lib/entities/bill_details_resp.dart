class BillDetailsResp {
  final double totalSureRepayAmounts;
  final int sureRepayPeriods;
  final int remainingDay;
  final bool extensionSwitch;
  final bool isExtensionSwitch;
  final List<LoanOrderDetail> loanOrderDetails;
  final double totalMinRepayAmounts;
  final double waivedAmount;

  BillDetailsResp({
    required this.totalSureRepayAmounts,
    required this.sureRepayPeriods,
    required this.remainingDay,
    required this.extensionSwitch,
    required this.isExtensionSwitch,
    required this.loanOrderDetails,
    required this.totalMinRepayAmounts,
    required this.waivedAmount,
  });

  factory BillDetailsResp.fromJson(Map<String, dynamic> json) {
    return BillDetailsResp(
      totalSureRepayAmounts: _parseDouble(json['totalSureRepayAmounts']),
      sureRepayPeriods: json['sureRepayPeriods'] as int? ?? 0,
      remainingDay: json['remainingDay'] as int? ?? 0,
      extensionSwitch: json['extensionSwitch'] as bool? ?? false,
      isExtensionSwitch: json['isExtensionSwitch'] as bool? ?? false,
      loanOrderDetails:
          (json['loanOrderDetails'] as List<dynamic>?)
              ?.map((e) => LoanOrderDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalMinRepayAmounts: _parseDouble(json['totalMinRepayAmounts']),
      waivedAmount: _parseDouble(json['waivedAmount']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class LoanOrderDetail {
  final String appOrderId;
  final String productCode;
  final String productLogo;
  final String productName;
  final double loanAmount;
  final int installmentId;
  final int term;
  final int daysPerTerm;
  final String repayDate;
  final int remainingDay;
  final double receiptAmount;
  final double serviceFee;
  final double repaymentAmount;
  final double waivedAmount;
  final int installmentNum;
  final String bankCardNo;
  final int bankAccountId;
  final dynamic bankAccountType;
  final String bankName;
  final int orderStatus;
  final dynamic orderStatusDesc;
  final String updateTime;
  final String acqChannel;
  final dynamic closeTime;
  final dynamic rejectTime;
  final double interest;
  final double overdueInterest;

  LoanOrderDetail({
    required this.appOrderId,
    required this.productCode,
    required this.productLogo,
    required this.productName,
    required this.loanAmount,
    required this.installmentId,
    required this.term,
    required this.daysPerTerm,
    required this.repayDate,
    required this.remainingDay,
    required this.receiptAmount,
    required this.serviceFee,
    required this.repaymentAmount,
    required this.waivedAmount,
    required this.installmentNum,
    required this.bankCardNo,
    required this.bankAccountId,
    this.bankAccountType,
    required this.bankName,
    required this.orderStatus,
    this.orderStatusDesc,
    required this.updateTime,
    required this.acqChannel,
    this.closeTime,
    this.rejectTime,
    required this.interest,
    required this.overdueInterest,
  });

  factory LoanOrderDetail.fromJson(Map<String, dynamic> json) {
    return LoanOrderDetail(
      appOrderId: json['appOrderId']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      productLogo: json['productLogo']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      loanAmount: _parseDouble(json['loanAmount']),
      installmentId: json['installmentId'] as int? ?? 0,
      term: json['term'] as int? ?? 0,
      daysPerTerm: json['daysPerTerm'] as int? ?? 0,
      repayDate: json['repayDate']?.toString() ?? '',
      remainingDay: json['remainingDay'] as int? ?? 0,
      receiptAmount: _parseDouble(json['receiptAmount']),
      serviceFee: _parseDouble(json['serviceFee']),
      repaymentAmount: _parseDouble(json['repaymentAmount']),
      waivedAmount: _parseDouble(json['waivedAmount']),
      installmentNum: json['installmentNum'] as int? ?? 0,
      bankCardNo: json['bankCardNo']?.toString() ?? '',
      bankAccountId: json['bankAccountId'] as int? ?? 0,
      bankAccountType: json['bankAccountType'],
      bankName: json['bankName']?.toString() ?? '',
      orderStatus: json['orderStatus'] as int? ?? 0,
      orderStatusDesc: json['orderStatusDesc'],
      updateTime: json['updateTime']?.toString() ?? '',
      acqChannel: json['acqChannel']?.toString() ?? '',
      closeTime: json['closeTime'],
      rejectTime: json['rejectTime'],
      interest: _parseDouble(json['interest']),
      overdueInterest: _parseDouble(json['overdueInterest']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
