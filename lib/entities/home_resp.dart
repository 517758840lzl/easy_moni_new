import 'dart:convert';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/utils/extensions.dart';

class HomeResp {
  final HomeConfirmData? confirmData;
  final String? couponsTitle;
  final bool? hasAvailableCoupons;

  const HomeResp({
    this.confirmData,
    this.couponsTitle,
    this.hasAvailableCoupons,
  });

  factory HomeResp.fromJson(dynamic json) {
    try {
      final map = _toMap(json);
      return HomeResp(
        confirmData: map['confirmData'] != null
            ? HomeConfirmData.fromJson(map['confirmData'])
            : null,
        couponsTitle: map['couponsTitle'] as String?,
        hasAvailableCoupons: _parseBool(map['hasAvailableCoupons']),
      );
    } catch (e, stack) {
      AppLogger.debug('HomeResp.fromJson 异常: $e\n$stack');
      return const HomeResp();
    }
  }
}

class HomeConfirmData {
  final double? actualToAccountMoney;
  final String? autoConfirmTips;
  final int? autoLoan;
  final int? bankCardId;
  final String? bankCardName;
  final String? bankCardNo;
  final String? bankCardType;
  final int? cancelAutoConfirmSwitch;
  final int? countDownTime;
  final int? isPopUpConfirmAutoLoan;
  final List<HomeProductItem>? list;
  final double? loanAmount;
  final String? payDate;
  final double? rent;
  final String? repayDate;
  final double? serviceFee;

  const HomeConfirmData({
    this.actualToAccountMoney,
    this.autoConfirmTips,
    this.autoLoan,
    this.bankCardId,
    this.bankCardName,
    this.bankCardNo,
    this.bankCardType,
    this.cancelAutoConfirmSwitch,
    this.countDownTime,
    this.isPopUpConfirmAutoLoan,
    this.list,
    this.loanAmount,
    this.payDate,
    this.rent,
    this.repayDate,
    this.serviceFee,
  });

  factory HomeConfirmData.fromJson(dynamic json) {
    final map = _toMap(json);
    return HomeConfirmData(
      actualToAccountMoney: _parseDouble(map['actualToAccountMoney']),
      autoConfirmTips: map['autoConfirmTips'] as String?,
      autoLoan: _parseInt(map['autoLoan']),
      bankCardId: _parseInt(map['bankCardId']),
      bankCardName: map['bankCardName'] as String?,
      bankCardNo: map['bankCardNo'] as String?,
      bankCardType: map['bankCardType'] as String?,
      cancelAutoConfirmSwitch: _parseInt(map['cancelAutoConfirmSwitch']),
      countDownTime: _parseInt(map['countDownTime']),
      isPopUpConfirmAutoLoan: _parseInt(map['isPopUpConfirmAutoLoan']),
      list: (map['list'] as List<dynamic>?)
          ?.map((e) => HomeProductItem.fromJson(e))
          .toList(),
      loanAmount: _parseDouble(map['loanAmount']),
      payDate: map['payDate'] as String?,
      rent: _parseDouble(map['rent']),
      repayDate: map['repayDate'] as String?,
      serviceFee: _parseDouble(map['serviceFee']),
    );
  }
}

class HomeProductItem {
  final double? actualToAccount;
  final int? appOrderId;
  final String? appOrderIdStr;
  final int? appOrderStatus;
  final String? bankCardName;
  final String? bankCardNo;
  final String? bankCardType;
  final String? borrowRetryDate;
  final int? customerLevelUnlock;
  final double? dailyInterestRateFrom;
  final double? dailyInterestRateTo;
  final int? daysPerTermFrom;
  final int? daysPerTermTo;
  final String? dueDate;
  final double? interest;
  final bool? isExtensionSwitch;
  final double? loanAmount;
  final double? loanLimitFrom;
  final double? loanLimitTo;
  final int? productAccount;
  final String? productCode;
  final double? productInterest;
  final int? productLevel;
  final String? productLogo;
  final String? productName;
  final int? productStatus;
  final double? receiptAmount;
  final int? remainingDays;
  final double? repaidAmount;
  final double? repayAmount;
  final String? repayDate;
  final String? repayDateStr;
  final double? serviceFee;
  final int? term;
  final int? totalServiceDays;

  const HomeProductItem({
    this.actualToAccount,
    this.appOrderId,
    this.appOrderIdStr,
    this.appOrderStatus,
    this.bankCardName,
    this.bankCardNo,
    this.bankCardType,
    this.borrowRetryDate,
    this.customerLevelUnlock,
    this.dailyInterestRateFrom,
    this.dailyInterestRateTo,
    this.daysPerTermFrom,
    this.daysPerTermTo,
    this.dueDate,
    this.interest,
    this.isExtensionSwitch,
    this.loanAmount,
    this.loanLimitFrom,
    this.loanLimitTo,
    this.productAccount,
    this.productCode,
    this.productInterest,
    this.productLevel,
    this.productLogo,
    this.productName,
    this.productStatus,
    this.receiptAmount,
    this.remainingDays,
    this.repaidAmount,
    this.repayAmount,
    this.repayDate,
    this.repayDateStr,
    this.serviceFee,
    this.term,
    this.totalServiceDays,
  });

  factory HomeProductItem.fromJson(dynamic json) {
    final map = _toMap(json);
    return HomeProductItem(
      actualToAccount: _parseDouble(map['actualToAccount']),
      appOrderId: _parseInt(map['appOrderId']),
      appOrderIdStr: map['appOrderIdStr'] as String?,
      appOrderStatus: _parseInt(map['appOrderStatus']),
      bankCardName: map['bankCardName'] as String?,
      bankCardNo: map['bankCardNo'] as String?,
      bankCardType: map['bankCardType'] as String?,
      borrowRetryDate: map['borrowRetryDate'] as String?,
      customerLevelUnlock: _parseInt(map['customerLevelUnlock']),
      dailyInterestRateFrom: _parseDouble(map['dailyInterestRateFrom']),
      dailyInterestRateTo: _parseDouble(map['dailyInterestRateTo']),
      daysPerTermFrom: _parseInt(map['daysPerTermFrom']),
      daysPerTermTo: _parseInt(map['daysPerTermTo']),
      dueDate: map['dueDate'] as String?,
      interest: _parseDouble(map['interest']),
      isExtensionSwitch: _parseBool(map['isExtensionSwitch']),
      loanAmount: _parseDouble(map['loanAmount']),
      loanLimitFrom: _parseDouble(map['loanLimitFrom']),
      loanLimitTo: _parseDouble(map['loanLimitTo']),
      productAccount: _parseInt(map['productAccount']),
      productCode: map['productCode'] as String?,
      productInterest: _parseDouble(map['productInterest']),
      productLevel: _parseInt(map['productLevel']),
      productLogo: map['productLogo'] as String?,
      productName: map['productName'] as String?,
      productStatus: _parseInt(map['productStatus']),
      receiptAmount: _parseDouble(map['receiptAmount']),
      remainingDays: _parseInt(map['remainingDays']),
      repaidAmount: _parseDouble(map['repaidAmount']),
      repayAmount: _parseDouble(map['repayAmount']),
      repayDate: map['repayDate'] as String?,
      repayDateStr: map['repayDateStr'] as String?,
      serviceFee: _parseDouble(map['serviceFee']),
      term: _parseInt(map['term']),
      totalServiceDays: _parseInt(map['totalServiceDays']),
    );
  }

  double get displayAmount => loanLimitTo ?? loanAmount ?? 0;

  double get availableAmount {
    if (productStatus == 0) {
      return productAccount?.toDouble() ?? 0;
    }
    return displayAmount;
  }

  String get availableAmountLabel {
    if (productStatus == 0) {
      return availableAmount.formatAmount().trimZeroDecimal();
    }

    final from = loanLimitFrom;
    final to = loanLimitTo;
    if (from != null && to != null) {
      // 数字格式化
      return '${from.formatAmount().trimZeroDecimal()} - ${to.formatAmount().trimZeroDecimal()}';
    }
    return availableAmount.formatAmount();
  }

  String get interestLabel {
    final from = dailyInterestRateFrom;
    final to = dailyInterestRateTo;
    if (from == null && to == null) return '-';
    if (from != null && to != null && from != to) {
      return '${_formatRate(from)} - ${_formatRate(to)}';
    }
    return _formatRate(from ?? to ?? 0);
  }

  String get termLabel {
    final from = daysPerTermFrom ?? term;
    final to = daysPerTermTo ?? term;
    return from.formatLoanTermLabel(to: to);
  }

  static String _formatRate(double rate) {
    final percent = rate < 1 ? rate * 100 : rate;
    return '${percent.toStringAsFixed(2)}%';
  }
}

Map<String, dynamic> _toMap(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return Map<String, dynamic>.from(json);
  if (json is String) {
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  }
  throw FormatException('Invalid json: ${json.runtimeType}');
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return null;
}
