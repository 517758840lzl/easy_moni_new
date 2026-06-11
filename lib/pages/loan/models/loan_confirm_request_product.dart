class LoanConfirmRequestProduct {
  const LoanConfirmRequestProduct({
    required this.appOrderId,
    required this.loanAmount,
    required this.productCode,
    this.feeId = '',
  });

  final int appOrderId;
  final num loanAmount;
  final String productCode;
  final String feeId;

  Map<String, dynamic> toJson() {
    return {
      'appOrderId': appOrderId,
      'feeId': feeId,
      'loanAmount': loanAmount,
      'productCode': productCode,
    };
  }
}
