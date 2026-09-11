import 'package:freezed_annotation/freezed_annotation.dart';

part 'repay_detail_resp.freezed.dart';
part 'repay_detail_resp.g.dart';

@freezed
abstract class RepayDetailResp with _$RepayDetailResp {
  const factory RepayDetailResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'data') RepayDetailRespData? data,
  }) = _RepayDetailResp;

  factory RepayDetailResp.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespFromJson(json);
}

@freezed
abstract class RepayDetailRespData with _$RepayDetailRespData {
  const factory RepayDetailRespData({
    @JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,
    @JsonKey(name: 'sureRepayPeriods') int? sureRepayPeriods,
    @JsonKey(name: 'remainingDay') int? remainingDay,
    @JsonKey(name: 'extensionSwitch') bool? extensionSwitch,
    @JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,
    @JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails,
    @JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts,
    @JsonKey(name: 'waivedAmount') num? waivedAmount,
  }) = _RepayDetailRespData;

  factory RepayDetailRespData.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespDataFromJson(json);
}

@freezed
abstract class RepayDetailRespDataLoanOrderDetails with _$RepayDetailRespDataLoanOrderDetails {
  const factory RepayDetailRespDataLoanOrderDetails({
    @JsonKey(name: 'appOrderId') String? appOrderId,
    @JsonKey(name: 'productCode') String? productCode,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'installmentId') int? installmentId,
    @JsonKey(name: 'term') int? term,
    @JsonKey(name: 'daysPerTerm') int? daysPerTerm,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'remainingDay') int? remainingDay,
    @JsonKey(name: 'receiptAmount') num? receiptAmount,
    @JsonKey(name: 'serviceFee') num? serviceFee,
    @JsonKey(name: 'repaymentAmount') num? repaymentAmount,
    @JsonKey(name: 'waivedAmount') num? waivedAmount,
    @JsonKey(name: 'installmentNum') int? installmentNum,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankAccountId') int? bankAccountId,
    @JsonKey(name: 'bankAccountType') String? bankAccountType,
    @JsonKey(name: 'bankName') String? bankName,
    @JsonKey(name: 'orderStatus') int? orderStatus,
    @JsonKey(name: 'orderStatusDesc') String? orderStatusDesc,
    @JsonKey(name: 'updateTime') String? updateTime,
    @JsonKey(name: 'acqChannel') String? acqChannel,
    @JsonKey(name: 'closeTime') int? closeTime,
    @JsonKey(name: 'rejectTime') int? rejectTime,
    @JsonKey(name: 'interest') num? interest,
    @JsonKey(name: 'overdueInterest') num? overdueInterest,
  }) = _RepayDetailRespDataLoanOrderDetails;

  factory RepayDetailRespDataLoanOrderDetails.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespDataLoanOrderDetailsFromJson(json);
}
