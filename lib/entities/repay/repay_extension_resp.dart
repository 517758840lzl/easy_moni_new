import 'package:freezed_annotation/freezed_annotation.dart';

part 'repay_extension_resp.freezed.dart';
part 'repay_extension_resp.g.dart';

/// RepayExtensionResp 数据模型
@freezed
abstract class RepayExtensionResp with _$RepayExtensionResp {
  const factory RepayExtensionResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'data') RepayExtensionRespData? data,
  }) = _RepayExtensionResp;

  factory RepayExtensionResp.fromJson(Map<String, dynamic> json) =>
      _$RepayExtensionRespFromJson(json);
}

/// RepayExtensionRespData 数据模型
@freezed
abstract class RepayExtensionRespData with _$RepayExtensionRespData {
  const factory RepayExtensionRespData({
    @JsonKey(name: 'extensionFee') num? extensionFee,
    @JsonKey(name: 'newExtensionFee') num? newExtensionFee,
    @JsonKey(name: 'extensionWaivedAmount') num? extensionWaivedAmount,
    @JsonKey(name: 'extensionRepaymentDate') String? extensionRepaymentDate,
    @JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,
    @JsonKey(name: 'remainingDay') int? remainingDay,
  }) = _RepayExtensionRespData;

  factory RepayExtensionRespData.fromJson(Map<String, dynamic> json) =>
      _$RepayExtensionRespDataFromJson(json);
}
