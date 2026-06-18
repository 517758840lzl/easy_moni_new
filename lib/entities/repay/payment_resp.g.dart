// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentResp _$PaymentRespFromJson(Map<String, dynamic> json) => _PaymentResp(
  code: (json['code'] as num?)?.toInt(),
  data: json['data'] == null
      ? null
      : PaymentRespData.fromJson(json['data'] as Map<String, dynamic>),
  msg: json['msg'] as String?,
);

Map<String, dynamic> _$PaymentRespToJson(_PaymentResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

_PaymentRespData _$PaymentRespDataFromJson(Map<String, dynamic> json) =>
    _PaymentRespData(
      payChannel: json['payChannel'] as String?,
      payUrl: json['payUrl'] as String?,
      paymentCode: json['paymentCode'] as String?,
      productLogo: json['productLogo'] as String?,
      productName: json['productName'] as String?,
      repayAmount: json['repayAmount'] as num?,
      repaymentAmount: json['repaymentAmount'] as num?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaymentRespDataToJson(_PaymentRespData instance) =>
    <String, dynamic>{
      'payChannel': instance.payChannel,
      'payUrl': instance.payUrl,
      'paymentCode': instance.paymentCode,
      'productLogo': instance.productLogo,
      'productName': instance.productName,
      'repayAmount': instance.repayAmount,
      'repaymentAmount': instance.repaymentAmount,
      'type': instance.type,
    };
