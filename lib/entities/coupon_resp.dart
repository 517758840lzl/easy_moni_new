import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_resp.freezed.dart';
part 'coupon_resp.g.dart';

@freezed
abstract class CouponResp with _$CouponResp {
  const factory CouponResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'data') CouponData? data,
    @JsonKey(name: 'msg') String? msg,
  }) = _CouponResp;

  factory CouponResp.fromJson(Map<String, dynamic> json) =>
      _$CouponRespFromJson(json);
}

@freezed
abstract class CouponData with _$CouponData {
  const factory CouponData({
    @JsonKey(name: 'coupons') List<CouponItem>? coupons,
    @JsonKey(name: 'showCouponCard') int? showCouponCard,
  }) = _CouponData;

  factory CouponData.fromJson(Map<String, dynamic> json) =>
      _$CouponDataFromJson(json);
}

@freezed
abstract class CouponItem with _$CouponItem {
  const factory CouponItem({
    @JsonKey(name: 'couponId') int? couponId,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'discountType') int? discountType,
    @JsonKey(name: 'discountValue') num? discountValue,
    @JsonKey(name: 'maxDiscountValue') num? maxDiscountValue,
    @JsonKey(name: 'minDiscountValue') num? minDiscountValue,
    @JsonKey(name: 'repaymentType') int? repaymentType,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'summary') String? summary,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'validFrom') int? validFrom,
    @JsonKey(name: 'validTo') int? validTo,
  }) = _CouponItem;

  factory CouponItem.fromJson(Map<String, dynamic> json) =>
      _$CouponItemFromJson(json);
}
