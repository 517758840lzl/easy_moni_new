import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_confirm_resp.freezed.dart';
part 'loan_confirm_resp.g.dart';

@freezed
abstract class LoanConfirmResp with _$LoanConfirmResp {
  const factory LoanConfirmResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'data') LoanConfirmData? data,
    @JsonKey(name: 'msg') String? msg,
  }) = _LoanConfirmResp;

  factory LoanConfirmResp.fromJson(Map<String, dynamic> json) =>
      _$LoanConfirmRespFromJson(json);
}

@freezed
abstract class LoanConfirmData with _$LoanConfirmData {
  const factory LoanConfirmData({
    @JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,
    @JsonKey(name: 'autoConfirmTips') String? autoConfirmTips,
    @JsonKey(name: 'autoLoan') int? autoLoan,
    @JsonKey(name: 'bankCardId') int? bankCardId,
    @JsonKey(name: 'bankCardName') String? bankCardName,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankCardType') String? bankCardType,
    @JsonKey(name: 'cancelAutoConfirmSwitch') int? cancelAutoConfirmSwitch,
    @JsonKey(name: 'countDownTime') int? countDownTime,
    @JsonKey(name: 'isPopUpConfirmAutoLoan') int? isPopUpConfirmAutoLoan,
    @JsonKey(name: 'list') List<LoanConfirmOrder>? list,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'payDate') String? payDate,
    @JsonKey(name: 'rent') num? rent,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'serviceFee') num? serviceFee,
  }) = _LoanConfirmData;

  factory LoanConfirmData.fromJson(Map<String, dynamic> json) =>
      _$LoanConfirmDataFromJson(json);
}

@freezed
abstract class LoanConfirmOrder with _$LoanConfirmOrder {
  const factory LoanConfirmOrder({
    @JsonKey(name: 'actualToAccount') num? actualToAccount,
    @JsonKey(name: 'appOrderId') int? appOrderId,
    @JsonKey(name: 'appOrderIdStr') String? appOrderIdStr,
    @JsonKey(name: 'appOrderStatus') int? appOrderStatus,
    @JsonKey(name: 'bankCardName') String? bankCardName,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankCardType') String? bankCardType,
    @JsonKey(name: 'borrowRetryDate') String? borrowRetryDate,
    @JsonKey(name: 'customerLevelUnlock') int? customerLevelUnlock,
    @JsonKey(name: 'dailyInterestRateFrom') num? dailyInterestRateFrom,
    @JsonKey(name: 'dailyInterestRateTo') num? dailyInterestRateTo,
    @JsonKey(name: 'daysPerTermFrom') int? daysPerTermFrom,
    @JsonKey(name: 'daysPerTermTo') int? daysPerTermTo,
    @JsonKey(name: 'dueDate') String? dueDate,
    @JsonKey(name: 'interest') num? interest,
    @JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'loanLimitFrom') num? loanLimitFrom,
    @JsonKey(name: 'loanLimitTo') num? loanLimitTo,
    @JsonKey(name: 'productAccount') num? productAccount,
    @JsonKey(name: 'productCode') String? productCode,
    @JsonKey(name: 'productInterest') num? productInterest,
    @JsonKey(name: 'productLevel') int? productLevel,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'productStatus') int? productStatus,
    @JsonKey(name: 'receiptAmount') num? receiptAmount,
    @JsonKey(name: 'remainingDays') int? remainingDays,
    @JsonKey(name: 'repaidAmount') num? repaidAmount,
    @JsonKey(name: 'repayAmount') num? repayAmount,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'repayDateStr') String? repayDateStr,
    @JsonKey(name: 'serviceFee') num? serviceFee,
    @JsonKey(name: 'term') int? term,
    @JsonKey(name: 'totalServiceDays') int? totalServiceDays,
  }) = _LoanConfirmOrder;

  factory LoanConfirmOrder.fromJson(Map<String, dynamic> json) =>
      _$LoanConfirmOrderFromJson(json);
}
