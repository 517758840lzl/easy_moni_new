// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repay_extension_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepayExtensionResp _$RepayExtensionRespFromJson(Map<String, dynamic> json) =>
    _RepayExtensionResp(
      code: (json['code'] as num?)?.toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : RepayExtensionRespData.fromJson(
              json['data'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RepayExtensionRespToJson(_RepayExtensionResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

_RepayExtensionRespData _$RepayExtensionRespDataFromJson(
  Map<String, dynamic> json,
) => _RepayExtensionRespData(
  extensionFee: json['extensionFee'] as num?,
  newExtensionFee: json['newExtensionFee'] as num?,
  extensionWaivedAmount: json['extensionWaivedAmount'] as num?,
  extensionRepaymentDate: json['extensionRepaymentDate'] as String?,
  totalSureRepayAmounts: json['totalSureRepayAmounts'] as num?,
  remainingDay: (json['remainingDay'] as num?)?.toInt(),
);

Map<String, dynamic> _$RepayExtensionRespDataToJson(
  _RepayExtensionRespData instance,
) => <String, dynamic>{
  'extensionFee': instance.extensionFee,
  'newExtensionFee': instance.newExtensionFee,
  'extensionWaivedAmount': instance.extensionWaivedAmount,
  'extensionRepaymentDate': instance.extensionRepaymentDate,
  'totalSureRepayAmounts': instance.totalSureRepayAmounts,
  'remainingDay': instance.remainingDay,
};
