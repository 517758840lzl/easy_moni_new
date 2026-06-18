// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repay_detail_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepayDetailResp _$RepayDetailRespFromJson(Map<String, dynamic> json) =>
    _RepayDetailResp(
      code: (json['code'] as num?)?.toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : RepayDetailRespData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepayDetailRespToJson(_RepayDetailResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

_RepayDetailRespData _$RepayDetailRespDataFromJson(Map<String, dynamic> json) =>
    _RepayDetailRespData(
      totalSureRepayAmounts: json['totalSureRepayAmounts'] as num?,
      sureRepayPeriods: (json['sureRepayPeriods'] as num?)?.toInt(),
      remainingDay: (json['remainingDay'] as num?)?.toInt(),
      extensionSwitch: json['extensionSwitch'] as bool?,
      isExtensionSwitch: json['isExtensionSwitch'] as bool?,
      loanOrderDetails: (json['loanOrderDetails'] as List<dynamic>?)
          ?.map(
            (e) => RepayDetailRespDataLoanOrderDetails.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      totalMinRepayAmounts: json['totalMinRepayAmounts'] as num?,
      waivedAmount: json['waivedAmount'] as num?,
    );

Map<String, dynamic> _$RepayDetailRespDataToJson(
  _RepayDetailRespData instance,
) => <String, dynamic>{
  'totalSureRepayAmounts': instance.totalSureRepayAmounts,
  'sureRepayPeriods': instance.sureRepayPeriods,
  'remainingDay': instance.remainingDay,
  'extensionSwitch': instance.extensionSwitch,
  'isExtensionSwitch': instance.isExtensionSwitch,
  'loanOrderDetails': instance.loanOrderDetails,
  'totalMinRepayAmounts': instance.totalMinRepayAmounts,
  'waivedAmount': instance.waivedAmount,
};

_RepayDetailRespDataLoanOrderDetails
_$RepayDetailRespDataLoanOrderDetailsFromJson(Map<String, dynamic> json) =>
    _RepayDetailRespDataLoanOrderDetails(
      appOrderId: json['appOrderId'] as String?,
      productCode: json['productCode'] as String?,
      productLogo: json['productLogo'] as String?,
      productName: json['productName'] as String?,
      loanAmount: json['loanAmount'] as num?,
      installmentId: (json['installmentId'] as num?)?.toInt(),
      term: (json['term'] as num?)?.toInt(),
      daysPerTerm: (json['daysPerTerm'] as num?)?.toInt(),
      repayDate: json['repayDate'] as String?,
      remainingDay: (json['remainingDay'] as num?)?.toInt(),
      receiptAmount: json['receiptAmount'] as num?,
      serviceFee: json['serviceFee'] as num?,
      repaymentAmount: json['repaymentAmount'] as num?,
      waivedAmount: json['waivedAmount'] as num?,
      installmentNum: (json['installmentNum'] as num?)?.toInt(),
      bankCardNo: json['bankCardNo'] as String?,
      bankAccountId: (json['bankAccountId'] as num?)?.toInt(),
      bankAccountType: json['bankAccountType'] as String?,
      bankName: json['bankName'] as String?,
      orderStatus: (json['orderStatus'] as num?)?.toInt(),
      orderStatusDesc: json['orderStatusDesc'] as String?,
      updateTime: json['updateTime'] as String?,
      acqChannel: json['acqChannel'] as String?,
      closeTime: (json['closeTime'] as num?)?.toInt(),
      rejectTime: (json['rejectTime'] as num?)?.toInt(),
      interest: json['interest'] as num?,
      overdueInterest: json['overdueInterest'] as num?,
    );

Map<String, dynamic> _$RepayDetailRespDataLoanOrderDetailsToJson(
  _RepayDetailRespDataLoanOrderDetails instance,
) => <String, dynamic>{
  'appOrderId': instance.appOrderId,
  'productCode': instance.productCode,
  'productLogo': instance.productLogo,
  'productName': instance.productName,
  'loanAmount': instance.loanAmount,
  'installmentId': instance.installmentId,
  'term': instance.term,
  'daysPerTerm': instance.daysPerTerm,
  'repayDate': instance.repayDate,
  'remainingDay': instance.remainingDay,
  'receiptAmount': instance.receiptAmount,
  'serviceFee': instance.serviceFee,
  'repaymentAmount': instance.repaymentAmount,
  'waivedAmount': instance.waivedAmount,
  'installmentNum': instance.installmentNum,
  'bankCardNo': instance.bankCardNo,
  'bankAccountId': instance.bankAccountId,
  'bankAccountType': instance.bankAccountType,
  'bankName': instance.bankName,
  'orderStatus': instance.orderStatus,
  'orderStatusDesc': instance.orderStatusDesc,
  'updateTime': instance.updateTime,
  'acqChannel': instance.acqChannel,
  'closeTime': instance.closeTime,
  'rejectTime': instance.rejectTime,
  'interest': instance.interest,
  'overdueInterest': instance.overdueInterest,
};
