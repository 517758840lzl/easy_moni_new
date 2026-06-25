// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_info_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceInfoResp _$ServiceInfoRespFromJson(Map<String, dynamic> json) =>
    _ServiceInfoResp(
      code: (json['code'] as num?)?.toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : ServiceInfoRespData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServiceInfoRespToJson(_ServiceInfoResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

_ServiceInfoRespData _$ServiceInfoRespDataFromJson(Map<String, dynamic> json) =>
    _ServiceInfoRespData(
      showType: (json['showType'] as num?)?.toInt(),
      appCustomerServiceInfoResps:
          (json['appCustomerServiceInfoResps'] as List<dynamic>?)
              ?.map(
                (e) => ServiceInfoRespDataAppCustomerServiceInfo.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      appCustomerServiceInfo: json['appCustomerServiceInfo'] == null
          ? null
          : ServiceInfoRespDataAppCustomerServiceInfo.fromJson(
              json['appCustomerServiceInfo'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ServiceInfoRespDataToJson(
  _ServiceInfoRespData instance,
) => <String, dynamic>{
  'showType': instance.showType,
  'appCustomerServiceInfoResps': instance.appCustomerServiceInfoResps,
  'appCustomerServiceInfo': instance.appCustomerServiceInfo,
};

_ServiceInfoRespDataAppCustomerServiceInfo
_$ServiceInfoRespDataAppCustomerServiceInfoFromJson(
  Map<String, dynamic> json,
) => _ServiceInfoRespDataAppCustomerServiceInfo(
  type: (json['type'] as num?)?.toInt(),
  account: json['account'] as String?,
  title: json['title'] as String?,
  desc: json['desc'] as String?,
  accountList: (json['accountList'] as List<dynamic>?)
      ?.map(
        (e) => ServiceInfoRespDataAppCustomerServiceInfo.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ServiceInfoRespDataAppCustomerServiceInfoToJson(
  _ServiceInfoRespDataAppCustomerServiceInfo instance,
) => <String, dynamic>{
  'type': instance.type,
  'account': instance.account,
  'title': instance.title,
  'desc': instance.desc,
  'accountList': instance.accountList,
};
