import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_resp.freezed.dart';
part 'payment_resp.g.dart';

/// PaymentResp 数据模型
@freezed
abstract class PaymentResp with _$PaymentResp {
  const factory PaymentResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'data') PaymentRespData? data,
    @JsonKey(name: 'msg') String? msg,
  }) = _PaymentResp;

  factory PaymentResp.fromJson(Map<String, dynamic> json) =>
      _$PaymentRespFromJson(json);
}

/// PaymentRespData 数据模型
@freezed
abstract class PaymentRespData with _$PaymentRespData {
  const factory PaymentRespData({
    @JsonKey(name: 'payChannel') String? payChannel,
    @JsonKey(name: 'payUrl') String? payUrl,
    @JsonKey(name: 'paymentCode') String? paymentCode,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'repayAmount') num? repayAmount,
    @JsonKey(name: 'repaymentAmount') num? repaymentAmount,
    @JsonKey(name: 'type') int? type,
  }) = _PaymentRespData;

  factory PaymentRespData.fromJson(Map<String, dynamic> json) =>
      _$PaymentRespDataFromJson(json);
}
