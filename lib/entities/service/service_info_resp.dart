import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_info_resp.freezed.dart';
part 'service_info_resp.g.dart';

@freezed
abstract class ServiceInfoResp with _$ServiceInfoResp {
  const factory ServiceInfoResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'data') ServiceInfoRespData? data,
  }) = _ServiceInfoResp;

  factory ServiceInfoResp.fromJson(Map<String, dynamic> json) =>
      _$ServiceInfoRespFromJson(json);
}

@freezed
abstract class ServiceInfoRespData with _$ServiceInfoRespData {
  const factory ServiceInfoRespData({
    @JsonKey(name: 'showType') int? showType,
    @JsonKey(name: 'appCustomerServiceInfoResps')
    List<ServiceInfoRespDataAppCustomerServiceInfo>?
    appCustomerServiceInfoResps,
    @JsonKey(name: 'appCustomerServiceInfo')
    ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo,
  }) = _ServiceInfoRespData;

  factory ServiceInfoRespData.fromJson(Map<String, dynamic> json) =>
      _$ServiceInfoRespDataFromJson(json);
}

@freezed
abstract class ServiceInfoRespDataAppCustomerServiceInfo
    with _$ServiceInfoRespDataAppCustomerServiceInfo {
  const factory ServiceInfoRespDataAppCustomerServiceInfo({
    @JsonKey(name: 'type') int? type,
    @JsonKey(name: 'account') String? account,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'desc') String? desc,
    @JsonKey(name: 'accountList')
    List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList,
  }) = _ServiceInfoRespDataAppCustomerServiceInfo;

  factory ServiceInfoRespDataAppCustomerServiceInfo.fromJson(
    Map<String, dynamic> json,
  ) => _$ServiceInfoRespDataAppCustomerServiceInfoFromJson(json);
}
