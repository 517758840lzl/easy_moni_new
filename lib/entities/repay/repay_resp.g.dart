// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repay_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepayResp _$RepayRespFromJson(Map<String, dynamic> json) => _RepayResp(
  acqChannel: json['acqChannel'] as String?,
  appOrderId: json['appOrderId'] as String?,
  bankCardName: json['bankCardName'] as String?,
  bankCardNo: json['bankCardNo'] as String?,
  bankCardType: json['bankCardType'] as String?,
  closeTime: (json['closeTime'] as num?)?.toInt(),
  countdownTime: (json['countdownTime'] as num?)?.toInt(),
  createTime: json['createTime'] as String?,
  interest: json['interest'] as num?,
  isExtensionSwitch: json['isExtensionSwitch'] as bool?,
  loanAmount: json['loanAmount'] as num?,
  orderStatus: (json['orderStatus'] as num?)?.toInt(),
  orderStatusStr: json['orderStatusStr'] as String?,
  productLevel: (json['productLevel'] as num?)?.toInt(),
  productLogo: json['productLogo'] as String?,
  productName: json['productName'] as String?,
  productSetCode: json['productSetCode'] as String?,
  receiptAmount: json['receiptAmount'] as num?,
  rejectTime: (json['rejectTime'] as num?)?.toInt(),
  remainingDays: (json['remainingDays'] as num?)?.toInt(),
  repaidAmount: json['repaidAmount'] as num?,
  repayAmount: json['repayAmount'] as num?,
  repayDate: json['repayDate'] as String?,
  repayDateStr: json['repayDateStr'] as String?,
  sort: (json['sort'] as num?)?.toInt(),
  term: (json['term'] as num?)?.toInt(),
  totalServiceDays: (json['totalServiceDays'] as num?)?.toInt(),
  updateTime: json['updateTime'] as String?,
);

Map<String, dynamic> _$RepayRespToJson(_RepayResp instance) =>
    <String, dynamic>{
      'acqChannel': instance.acqChannel,
      'appOrderId': instance.appOrderId,
      'bankCardName': instance.bankCardName,
      'bankCardNo': instance.bankCardNo,
      'bankCardType': instance.bankCardType,
      'closeTime': instance.closeTime,
      'countdownTime': instance.countdownTime,
      'createTime': instance.createTime,
      'interest': instance.interest,
      'isExtensionSwitch': instance.isExtensionSwitch,
      'loanAmount': instance.loanAmount,
      'orderStatus': instance.orderStatus,
      'orderStatusStr': instance.orderStatusStr,
      'productLevel': instance.productLevel,
      'productLogo': instance.productLogo,
      'productName': instance.productName,
      'productSetCode': instance.productSetCode,
      'receiptAmount': instance.receiptAmount,
      'rejectTime': instance.rejectTime,
      'remainingDays': instance.remainingDays,
      'repaidAmount': instance.repaidAmount,
      'repayAmount': instance.repayAmount,
      'repayDate': instance.repayDate,
      'repayDateStr': instance.repayDateStr,
      'sort': instance.sort,
      'term': instance.term,
      'totalServiceDays': instance.totalServiceDays,
      'updateTime': instance.updateTime,
    };
