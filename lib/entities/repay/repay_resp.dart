import 'package:freezed_annotation/freezed_annotation.dart';

part 'repay_resp.freezed.dart';
part 'repay_resp.g.dart';

/// 还款订单信息模型
@freezed
abstract class RepayResp with _$RepayResp {
  const factory RepayResp({
    @JsonKey(name: 'acqChannel') String? acqChannel,
    @JsonKey(name: 'appOrderId') String? appOrderId,
    @JsonKey(name: 'bankCardName') String? bankCardName,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankCardType') String? bankCardType,
    @JsonKey(name: 'closeTime') int? closeTime,
    @JsonKey(name: 'countdownTime') int? countdownTime,
    @JsonKey(name: 'createTime') String? createTime,
    @JsonKey(name: 'interest') num? interest,
    @JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'orderStatus') int? orderStatus,
    @JsonKey(name: 'orderStatusStr') String? orderStatusStr,
    @JsonKey(name: 'productLevel') int? productLevel,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'productSetCode') String? productSetCode,
    @JsonKey(name: 'receiptAmount') num? receiptAmount,
    @JsonKey(name: 'rejectTime') int? rejectTime,
    @JsonKey(name: 'remainingDays') int? remainingDays,
    @JsonKey(name: 'repaidAmount') num? repaidAmount,
    @JsonKey(name: 'repayAmount') num? repayAmount,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'repayDateStr') String? repayDateStr,
    @JsonKey(name: 'sort') int? sort,
    @JsonKey(name: 'term') int? term,
    @JsonKey(name: 'totalServiceDays') int? totalServiceDays,
    @JsonKey(name: 'updateTime') String? updateTime,
  }) = _RepayResp;

  factory RepayResp.fromJson(Map<String, dynamic> json) =>
      _$RepayRespFromJson(json);
}
