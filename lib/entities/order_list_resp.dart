import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_list_resp.freezed.dart';
part 'order_list_resp.g.dart';

String? _nullableStringFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@freezed
abstract class OrderListResp with _$OrderListResp {
  const factory OrderListResp({
    @JsonKey(name: 'code') int? code,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'data') List<OrderListItem>? data,
  }) = _OrderListResp;

  factory OrderListResp.fromJson(Map<String, dynamic> json) =>
      _$OrderListRespFromJson(json);
}

@freezed
abstract class OrderListItem with _$OrderListItem {
  const factory OrderListItem({
    @JsonKey(name: 'appOrderId', fromJson: _nullableStringFromJson)
    String? appOrderId,
    @JsonKey(name: 'applicationTime') String? applicationTime,
    @JsonKey(name: 'productSetCode') String? productSetCode,
    @JsonKey(name: 'productLevel', fromJson: _nullableStringFromJson)
    String? productLevel,
    @JsonKey(name: 'orderStatus') int? orderStatus,
    @JsonKey(name: 'orderStatusStr') String? orderStatusStr,
    @JsonKey(name: 'repayAmount') num? repayAmount,
    @JsonKey(name: 'loanAmount') num? loanAmount,
    @JsonKey(name: 'receiptAmount') num? receiptAmount,
    @JsonKey(name: 'interest') num? interest,
    @JsonKey(name: 'overdueInterest') num? overdueInterest,
    @JsonKey(name: 'term') int? term,
    @JsonKey(name: 'totalServiceDays') int? totalServiceDays,
    @JsonKey(name: 'remainingDays') int? remainingDays,
    @JsonKey(name: 'productName') String? productName,
    @JsonKey(name: 'productLogo') String? productLogo,
    @JsonKey(name: 'repayDate') String? repayDate,
    @JsonKey(name: 'repayDateStr') String? repayDateStr,
    @JsonKey(name: 'repaidAmount') num? repaidAmount,
    @JsonKey(name: 'bankCardNo') String? bankCardNo,
    @JsonKey(name: 'bankCardName') String? bankCardName,
    @JsonKey(name: 'bankCardType', fromJson: _nullableStringFromJson)
    String? bankCardType,
    @JsonKey(name: 'updateTime') String? updateTime,
    @JsonKey(name: 'createTime') String? createTime,
    @JsonKey(name: 'effectiveTime') String? effectiveTime,
    @JsonKey(name: 'acqChannel') String? acqChannel,
    @JsonKey(name: 'closeTime') String? closeTime,
    @JsonKey(name: 'rejectTime') int? rejectTime,
    @JsonKey(name: 'sort') int? sort,
    @JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,
    @JsonKey(name: 'countdownTime') int? countdownTime,
  }) = _OrderListItem;

  factory OrderListItem.fromJson(Map<String, dynamic> json) =>
      _$OrderListItemFromJson(json);
}
