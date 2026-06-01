class UserRepaymentResp {
  final String appOrderId;
  final String productSetCode;
  final int? productLevel;
  final int orderStatus;
  final String orderStatusStr;
  final double repayAmount;
  final double loanAmount;
  final double receiptAmount;
  final double interest;
  final int term;
  final int totalServiceDays;
  final int remainingDays;
  final String productName;
  final String productLogo;
  final String repayDate;
  final String repayDateStr;
  final double repaidAmount;
  final String bankCardNo;
  final String bankCardName;
  final String bankCardType;
  final String updateTime;
  final String createTime;
  final String acqChannel;
  final String? closeTime;
  final String? rejectTime;
  final int sort;
  final bool isExtensionSwitch;
  final String? countdownTime;

  UserRepaymentResp({
    required this.appOrderId,
    required this.productSetCode,
    this.productLevel,
    required this.orderStatus,
    required this.orderStatusStr,
    required this.repayAmount,
    required this.loanAmount,
    required this.receiptAmount,
    required this.interest,
    required this.term,
    required this.totalServiceDays,
    required this.remainingDays,
    required this.productName,
    required this.productLogo,
    required this.repayDate,
    required this.repayDateStr,
    required this.repaidAmount,
    required this.bankCardNo,
    required this.bankCardName,
    required this.bankCardType,
    required this.updateTime,
    required this.createTime,
    required this.acqChannel,
    this.closeTime,
    this.rejectTime,
    required this.sort,
    required this.isExtensionSwitch,
    this.countdownTime,
  });

  factory UserRepaymentResp.fromJson(Map<String, dynamic> json) {
    return UserRepaymentResp(
      appOrderId: json['appOrderId']?.toString() ?? '',
      productSetCode: json['productSetCode']?.toString() ?? '',
      productLevel: json['productLevel'] as int?,
      orderStatus: json['orderStatus'] as int? ?? 0,
      orderStatusStr: json['orderStatusStr']?.toString() ?? '',
      repayAmount: _parseDouble(json['repayAmount']),
      loanAmount: _parseDouble(json['loanAmount']),
      receiptAmount: _parseDouble(json['receiptAmount']),
      interest: _parseDouble(json['interest']),
      term: json['term'] as int? ?? 0,
      totalServiceDays: json['totalServiceDays'] as int? ?? 0,
      remainingDays: json['remainingDays'] as int? ?? 0,
      productName: json['productName']?.toString() ?? '',
      productLogo: json['productLogo']?.toString() ?? '',
      repayDate: json['repayDate']?.toString() ?? '',
      repayDateStr: json['repayDateStr']?.toString() ?? '',
      repaidAmount: _parseDouble(json['repaidAmount']),
      bankCardNo: json['bankCardNo']?.toString() ?? '',
      bankCardName: json['bankCardName']?.toString() ?? '',
      bankCardType: json['bankCardType']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
      createTime: json['createTime']?.toString() ?? '',
      acqChannel: json['acqChannel']?.toString() ?? '',
      closeTime: json['closeTime']?.toString(),
      rejectTime: json['rejectTime']?.toString(),
      sort: json['sort'] as int? ?? 0,
      isExtensionSwitch: json['isExtensionSwitch'] as bool? ?? false,
      countdownTime: json['countdownTime']?.toString(),
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
