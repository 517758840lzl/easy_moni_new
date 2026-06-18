// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'use_coupon_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UseCouponResp _$UseCouponRespFromJson(Map<String, dynamic> json) =>
    _UseCouponResp(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : UseCouponRespData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$UseCouponRespToJson(_UseCouponResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

_UseCouponRespData _$UseCouponRespDataFromJson(Map<String, dynamic> json) =>
    _UseCouponRespData(
      actualToAccountMoney: json['actualToAccountMoney'] as num?,
      loanAmount: json['loanAmount'] as num?,
      newLoanAmount: json['newLoanAmount'] as num?,
      newRepaymentAmount: json['newRepaymentAmount'] as num?,
      rent: json['rent'] as num?,
      repaymentAmount: json['repaymentAmount'] as num?,
      serviceFee: json['serviceFee'] as num?,
      totalMinRepayAmounts: json['totalMinRepayAmounts'] as num?,
    );

Map<String, dynamic> _$UseCouponRespDataToJson(_UseCouponRespData instance) =>
    <String, dynamic>{
      'actualToAccountMoney': instance.actualToAccountMoney,
      'loanAmount': instance.loanAmount,
      'newLoanAmount': instance.newLoanAmount,
      'newRepaymentAmount': instance.newRepaymentAmount,
      'rent': instance.rent,
      'repaymentAmount': instance.repaymentAmount,
      'serviceFee': instance.serviceFee,
      'totalMinRepayAmounts': instance.totalMinRepayAmounts,
    };
