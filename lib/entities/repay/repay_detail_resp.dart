import 'package:freezed_annotation/freezed_annotation.dart';

part 'repay_detail_resp.freezed.dart';
part 'repay_detail_resp.g.dart';

/// RepayDetailResp 数据模型
@freezed
abstract class RepayDetailResp with _$RepayDetailResp {
  const factory RepayDetailResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'data') RepayDetailRespData? data,
    @JsonKey(name: 'msg') String? msg,
  }) = _RepayDetailResp;

  factory RepayDetailResp.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespFromJson(json);
}

/// RepayDetailRespData 数据模型
@freezed
abstract class RepayDetailRespData with _$RepayDetailRespData {
  const factory RepayDetailRespData({
    @JsonKey(name: 'extensionSwitch') bool? extensionSwitch,
    @JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,
    @JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails,
    @JsonKey(name: 'remainingDay') int? remainingDay,
    @JsonKey(name: 'sureRepayPeriods') int? sureRepayPeriods,
    @JsonKey(name: 'totalMinRepayAmounts') int? totalMinRepayAmounts,
    @JsonKey(name: 'totalSureRepayAmounts') int? totalSureRepayAmounts,
    @JsonKey(name: 'waivedAmount') int? waivedAmount,
  }) = _RepayDetailRespData;

  factory RepayDetailRespData.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespDataFromJson(json);
}

/// RepayDetailRespDataLoanOrderDetails 数据模型
@freezed
abstract class RepayDetailRespDataLoanOrderDetails with _$RepayDetailRespDataLoanOrderDetails {
  const factory RepayDetailRespDataLoanOrderDetails({
    @JsonKey(name: 'acqChannel') String? acqChannel,
    @JsonKey(name: 'appOrderId') String? appOrderId,
    @JsonKey(name: 'bankAccountId') int? bankAccountId,
    @JsonKey(name: 'bankAccountType') String? bankAccountType,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankName') String? bankName,
    @JsonKey(name: 'closeTime') int? closeTime,
    @JsonKey(name: 'daysPerTerm') int? daysPerTerm,
    @JsonKey(name: 'installmentId') int? installmentId,
    @JsonKey(name: 'installmentNum') int? installmentNum,
    @JsonKey(name: 'interest') int? interest,
    @JsonKey(name: 'loanAmount') int? loanAmount,
    @JsonKey(name: 'orderStatus') int? orderStatus,
    @JsonKey(name: 'orderStatusDesc') String? orderStatusDesc,
    @JsonKey(name: 'overdueInterest') int? overdueInterest,
    @JsonKey(name: 'productCode') String? productCode,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'receiptAmount') int? receiptAmount,
    @JsonKey(name: 'rejectTime') int? rejectTime,
    @JsonKey(name: 'remainingDay') int? remainingDay,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'repaymentAmount') int? repaymentAmount,
    @JsonKey(name: 'serviceFee') int? serviceFee,
    @JsonKey(name: 'term') int? term,
    @JsonKey(name: 'updateTime') String? updateTime,
    @JsonKey(name: 'waivedAmount') int? waivedAmount,
  }) = _RepayDetailRespDataLoanOrderDetails;

  factory RepayDetailRespDataLoanOrderDetails.fromJson(Map<String, dynamic> json) =>
      _$RepayDetailRespDataLoanOrderDetailsFromJson(json);
}
