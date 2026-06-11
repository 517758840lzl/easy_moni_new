// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CouponResp _$CouponRespFromJson(Map<String, dynamic> json) => _CouponResp(
  code: (json['code'] as num?)?.toInt(),
  data: json['data'] == null
      ? null
      : CouponData.fromJson(json['data'] as Map<String, dynamic>),
  msg: json['msg'] as String?,
);

Map<String, dynamic> _$CouponRespToJson(_CouponResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

_CouponData _$CouponDataFromJson(Map<String, dynamic> json) => _CouponData(
  coupons: (json['coupons'] as List<dynamic>?)
      ?.map((e) => CouponItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  showCouponCard: (json['showCouponCard'] as num?)?.toInt(),
);

Map<String, dynamic> _$CouponDataToJson(_CouponData instance) =>
    <String, dynamic>{
      'coupons': instance.coupons,
      'showCouponCard': instance.showCouponCard,
    };

_CouponItem _$CouponItemFromJson(Map<String, dynamic> json) => _CouponItem(
  couponId: (json['couponId'] as num?)?.toInt(),
  description: json['description'] as String?,
  discountType: (json['discountType'] as num?)?.toInt(),
  discountValue: json['discountValue'] as num?,
  maxDiscountValue: json['maxDiscountValue'] as num?,
  minDiscountValue: json['minDiscountValue'] as num?,
  repaymentType: (json['repaymentType'] as num?)?.toInt(),
  status: (json['status'] as num?)?.toInt(),
  summary: json['summary'] as String?,
  title: json['title'] as String?,
  type: json['type'] as String?,
  validFrom: (json['validFrom'] as num?)?.toInt(),
  validTo: (json['validTo'] as num?)?.toInt(),
);

Map<String, dynamic> _$CouponItemToJson(_CouponItem instance) =>
    <String, dynamic>{
      'couponId': instance.couponId,
      'description': instance.description,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'maxDiscountValue': instance.maxDiscountValue,
      'minDiscountValue': instance.minDiscountValue,
      'repaymentType': instance.repaymentType,
      'status': instance.status,
      'summary': instance.summary,
      'title': instance.title,
      'type': instance.type,
      'validFrom': instance.validFrom,
      'validTo': instance.validTo,
    };
