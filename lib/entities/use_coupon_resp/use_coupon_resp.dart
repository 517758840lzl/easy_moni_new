import 'package:freezed_annotation/freezed_annotation.dart';

part 'use_coupon_resp.freezed.dart';
part 'use_coupon_resp.g.dart';

@freezed
abstract class UseCouponResp with _$UseCouponResp {
  const factory UseCouponResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'data') UseCouponRespData? data,
    @JsonKey(name: 'msg') String? msg,
  }) = _UseCouponResp;

  factory UseCouponResp.fromJson(Map<String, dynamic> json) =>
      _$UseCouponRespFromJson(json);
}

@freezed
abstract class UseCouponRespData with _$UseCouponRespData {
  const factory UseCouponRespData({
    @JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'newLoanAmount') num? newLoanAmount,
    @JsonKey(name: 'newRepaymentAmount') num? newRepaymentAmount,
    @JsonKey(name: 'rent') num? rent,
    @JsonKey(name: 'repaymentAmount') num? repaymentAmount,
    @JsonKey(name: 'serviceFee') num? serviceFee,
    @JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts,
  }) = _UseCouponRespData;

  factory UseCouponRespData.fromJson(Map<String, dynamic> json) =>
      _$UseCouponRespDataFromJson(json);
}
