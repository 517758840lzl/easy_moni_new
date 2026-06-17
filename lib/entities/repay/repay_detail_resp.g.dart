// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repay_detail_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepayDetailResp _$RepayDetailRespFromJson(Map<String, dynamic> json) =>
    _RepayDetailResp(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : RepayDetailRespData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$RepayDetailRespToJson(_RepayDetailResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

_RepayDetailRespData _$RepayDetailRespDataFromJson(Map<String, dynamic> json) =>
    _RepayDetailRespData(
      extensionSwitch: json['extensionSwitch'] as bool?,
      isExtensionSwitch: json['isExtensionSwitch'] as bool?,
      loanOrderDetails: (json['loanOrderDetails'] as List<dynamic>?)
          ?.map(
            (e) => RepayDetailRespDataLoanOrderDetails.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      remainingDay: (json['remainingDay'] as num?)?.toInt(),
      sureRepayPeriods: (json['sureRepayPeriods'] as num?)?.toInt(),
      totalMinRepayAmounts: (json['totalMinRepayAmounts'] as num?)?.toInt(),
      totalSureRepayAmounts: (json['totalSureRepayAmounts'] as num?)?.toInt(),
      waivedAmount: (json['waivedAmount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RepayDetailRespDataToJson(
  _RepayDetailRespData instance,
) => <String, dynamic>{
  'extensionSwitch': instance.extensionSwitch,
  'isExtensionSwitch': instance.isExtensionSwitch,
  'loanOrderDetails': instance.loanOrderDetails,
  'remainingDay': instance.remainingDay,
  'sureRepayPeriods': instance.sureRepayPeriods,
  'totalMinRepayAmounts': instance.totalMinRepayAmounts,
  'totalSureRepayAmounts': instance.totalSureRepayAmounts,
  'waivedAmount': instance.waivedAmount,
};

_RepayDetailRespDataLoanOrderDetails
_$RepayDetailRespDataLoanOrderDetailsFromJson(Map<String, dynamic> json) =>
    _RepayDetailRespDataLoanOrderDetails(
      acqChannel: json['acqChannel'] as String?,
      appOrderId: json['appOrderId'] as String?,
      bankAccountId: (json['bankAccountId'] as num?)?.toInt(),
      bankAccountType: json['bankAccountType'] as String?,
      bankCardNo: json['bankCardNo'] as String?,
      bankName: json['bankName'] as String?,
      closeTime: (json['closeTime'] as num?)?.toInt(),
      daysPerTerm: (json['daysPerTerm'] as num?)?.toInt(),
      installmentId: (json['installmentId'] as num?)?.toInt(),
      installmentNum: (json['installmentNum'] as num?)?.toInt(),
      interest: (json['interest'] as num?)?.toInt(),
      loanAmount: (json['loanAmount'] as num?)?.toInt(),
      orderStatus: (json['orderStatus'] as num?)?.toInt(),
      orderStatusDesc: json['orderStatusDesc'] as String?,
      overdueInterest: (json['overdueInterest'] as num?)?.toInt(),
      productCode: json['productCode'] as String?,
      productLogo: json['productLogo'] as String?,
      productName: json['productName'] as String?,
      receiptAmount: (json['receiptAmount'] as num?)?.toInt(),
      rejectTime: (json['rejectTime'] as num?)?.toInt(),
      remainingDay: (json['remainingDay'] as num?)?.toInt(),
      repayDate: json['repayDate'] as String?,
      repaymentAmount: (json['repaymentAmount'] as num?)?.toInt(),
      serviceFee: (json['serviceFee'] as num?)?.toInt(),
      term: (json['term'] as num?)?.toInt(),
      updateTime: json['updateTime'] as String?,
      waivedAmount: (json['waivedAmount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RepayDetailRespDataLoanOrderDetailsToJson(
  _RepayDetailRespDataLoanOrderDetails instance,
) => <String, dynamic>{
  'acqChannel': instance.acqChannel,
  'appOrderId': instance.appOrderId,
  'bankAccountId': instance.bankAccountId,
  'bankAccountType': instance.bankAccountType,
  'bankCardNo': instance.bankCardNo,
  'bankName': instance.bankName,
  'closeTime': instance.closeTime,
  'daysPerTerm': instance.daysPerTerm,
  'installmentId': instance.installmentId,
  'installmentNum': instance.installmentNum,
  'interest': instance.interest,
  'loanAmount': instance.loanAmount,
  'orderStatus': instance.orderStatus,
  'orderStatusDesc': instance.orderStatusDesc,
  'overdueInterest': instance.overdueInterest,
  'productCode': instance.productCode,
  'productLogo': instance.productLogo,
  'productName': instance.productName,
  'receiptAmount': instance.receiptAmount,
  'rejectTime': instance.rejectTime,
  'remainingDay': instance.remainingDay,
  'repayDate': instance.repayDate,
  'repaymentAmount': instance.repaymentAmount,
  'serviceFee': instance.serviceFee,
  'term': instance.term,
  'updateTime': instance.updateTime,
  'waivedAmount': instance.waivedAmount,
};
