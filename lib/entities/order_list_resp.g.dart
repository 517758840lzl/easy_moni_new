// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_list_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderListResp _$OrderListRespFromJson(Map<String, dynamic> json) =>
    _OrderListResp(
      code: (json['code'] as num?)?.toInt(),
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderListRespToJson(_OrderListResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

_OrderListItem _$OrderListItemFromJson(Map<String, dynamic> json) =>
    _OrderListItem(
      appOrderId: _nullableStringFromJson(json['appOrderId']),
      applicationTime: json['applicationTime'] as String?,
      productSetCode: json['productSetCode'] as String?,
      productLevel: _nullableStringFromJson(json['productLevel']),
      orderStatus: (json['orderStatus'] as num?)?.toInt(),
      orderStatusStr: json['orderStatusStr'] as String?,
      repayAmount: json['repayAmount'] as num?,
      loanAmount: json['loanAmount'] as num?,
      receiptAmount: json['receiptAmount'] as num?,
      interest: json['interest'] as num?,
      overdueInterest: json['overdueInterest'] as num?,
      term: (json['term'] as num?)?.toInt(),
      totalServiceDays: (json['totalServiceDays'] as num?)?.toInt(),
      remainingDays: (json['remainingDays'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      productLogo: json['productLogo'] as String?,
      repayDate: json['repayDate'] as String?,
      repayDateStr: json['repayDateStr'] as String?,
      repaidAmount: json['repaidAmount'] as num?,
      bankCardNo: json['bankCardNo'] as String?,
      bankCardName: json['bankCardName'] as String?,
      bankCardType: _nullableStringFromJson(json['bankCardType']),
      updateTime: json['updateTime'] as String?,
      createTime: json['createTime'] as String?,
      effectiveTime: json['effectiveTime'] as String?,
      acqChannel: json['acqChannel'] as String?,
      closeTime: json['closeTime'] as String?,
      rejectTime: (json['rejectTime'] as num?)?.toInt(),
      sort: (json['sort'] as num?)?.toInt(),
      isExtensionSwitch: json['isExtensionSwitch'] as bool?,
      countdownTime: (json['countdownTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderListItemToJson(_OrderListItem instance) =>
    <String, dynamic>{
      'appOrderId': instance.appOrderId,
      'applicationTime': instance.applicationTime,
      'productSetCode': instance.productSetCode,
      'productLevel': instance.productLevel,
      'orderStatus': instance.orderStatus,
      'orderStatusStr': instance.orderStatusStr,
      'repayAmount': instance.repayAmount,
      'loanAmount': instance.loanAmount,
      'receiptAmount': instance.receiptAmount,
      'interest': instance.interest,
      'overdueInterest': instance.overdueInterest,
      'term': instance.term,
      'totalServiceDays': instance.totalServiceDays,
      'remainingDays': instance.remainingDays,
      'productName': instance.productName,
      'productLogo': instance.productLogo,
      'repayDate': instance.repayDate,
      'repayDateStr': instance.repayDateStr,
      'repaidAmount': instance.repaidAmount,
      'bankCardNo': instance.bankCardNo,
      'bankCardName': instance.bankCardName,
      'bankCardType': instance.bankCardType,
      'updateTime': instance.updateTime,
      'createTime': instance.createTime,
      'effectiveTime': instance.effectiveTime,
      'acqChannel': instance.acqChannel,
      'closeTime': instance.closeTime,
      'rejectTime': instance.rejectTime,
      'sort': instance.sort,
      'isExtensionSwitch': instance.isExtensionSwitch,
      'countdownTime': instance.countdownTime,
    };
