class ExtensionResp {
  final double extensionFee;
  final double newExtensionFee;
  final double extensionWaivedAmount;
  final List<int> extensionRepaymentDate;
  final double totalSureRepayAmounts;
  final int remainingDay;

  ExtensionResp({
    required this.extensionFee,
    required this.newExtensionFee,
    required this.extensionWaivedAmount,
    required this.extensionRepaymentDate,
    required this.totalSureRepayAmounts,
    required this.remainingDay,
  });

  factory ExtensionResp.fromJson(Map<String, dynamic> json) {
    return ExtensionResp(
      extensionFee: _parseDouble(json['extensionFee']),
      newExtensionFee: _parseDouble(json['newExtensionFee']),
      extensionWaivedAmount: _parseDouble(json['extensionWaivedAmount']),
      extensionRepaymentDate:
          (json['extensionRepaymentDate'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      totalSureRepayAmounts: _parseDouble(json['totalSureRepayAmounts']),
      remainingDay: json['remainingDay'] as int? ?? 0,
    );
  }

  String get newDueDate {
    if (extensionRepaymentDate.length >= 3) {
      final year = extensionRepaymentDate[0];
      final month = extensionRepaymentDate[1].toString().padLeft(2, '0');
      final day = extensionRepaymentDate[2].toString().padLeft(2, '0');
      return '$day/$month/$year';
    }
    return '';
  }

  int get extensionDays {
    if (extensionRepaymentDate.length >= 3) {
      return remainingDay;
    }
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
