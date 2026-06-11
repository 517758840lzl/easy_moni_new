// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_confirm_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoanConfirmResp _$LoanConfirmRespFromJson(Map<String, dynamic> json) =>
    _LoanConfirmResp(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : LoanConfirmData.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$LoanConfirmRespToJson(_LoanConfirmResp instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };

_LoanConfirmData _$LoanConfirmDataFromJson(Map<String, dynamic> json) =>
    _LoanConfirmData(
      actualToAccountMoney: json['actualToAccountMoney'] as num?,
      autoConfirmTips: json['autoConfirmTips'] as String?,
      autoLoan: (json['autoLoan'] as num?)?.toInt(),
      bankCardId: (json['bankCardId'] as num?)?.toInt(),
      bankCardName: json['bankCardName'] as String?,
      bankCardNo: json['bankCardNo'] as String?,
      bankCardType: json['bankCardType'] as String?,
      cancelAutoConfirmSwitch: (json['cancelAutoConfirmSwitch'] as num?)
          ?.toInt(),
      countDownTime: (json['countDownTime'] as num?)?.toInt(),
      isPopUpConfirmAutoLoan: (json['isPopUpConfirmAutoLoan'] as num?)?.toInt(),
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => LoanConfirmOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      loanAmount: json['loanAmount'] as num?,
      payDate: json['payDate'] as String?,
      rent: json['rent'] as num?,
      repayDate: json['repayDate'] as String?,
      serviceFee: json['serviceFee'] as num?,
    );

Map<String, dynamic> _$LoanConfirmDataToJson(_LoanConfirmData instance) =>
    <String, dynamic>{
      'actualToAccountMoney': instance.actualToAccountMoney,
      'autoConfirmTips': instance.autoConfirmTips,
      'autoLoan': instance.autoLoan,
      'bankCardId': instance.bankCardId,
      'bankCardName': instance.bankCardName,
      'bankCardNo': instance.bankCardNo,
      'bankCardType': instance.bankCardType,
      'cancelAutoConfirmSwitch': instance.cancelAutoConfirmSwitch,
      'countDownTime': instance.countDownTime,
      'isPopUpConfirmAutoLoan': instance.isPopUpConfirmAutoLoan,
      'list': instance.list,
      'loanAmount': instance.loanAmount,
      'payDate': instance.payDate,
      'rent': instance.rent,
      'repayDate': instance.repayDate,
      'serviceFee': instance.serviceFee,
    };

_LoanConfirmOrder _$LoanConfirmOrderFromJson(Map<String, dynamic> json) =>
    _LoanConfirmOrder(
      actualToAccount: json['actualToAccount'] as num?,
      appOrderId: (json['appOrderId'] as num?)?.toInt(),
      appOrderIdStr: json['appOrderIdStr'] as String?,
      appOrderStatus: (json['appOrderStatus'] as num?)?.toInt(),
      bankCardName: json['bankCardName'] as String?,
      bankCardNo: json['bankCardNo'] as String?,
      bankCardType: json['bankCardType'] as String?,
      borrowRetryDate: json['borrowRetryDate'] as String?,
      customerLevelUnlock: (json['customerLevelUnlock'] as num?)?.toInt(),
      dailyInterestRateFrom: json['dailyInterestRateFrom'] as num?,
      dailyInterestRateTo: json['dailyInterestRateTo'] as num?,
      daysPerTermFrom: (json['daysPerTermFrom'] as num?)?.toInt(),
      daysPerTermTo: (json['daysPerTermTo'] as num?)?.toInt(),
      dueDate: json['dueDate'] as String?,
      interest: json['interest'] as num?,
      isExtensionSwitch: json['isExtensionSwitch'] as bool?,
      loanAmount: json['loanAmount'] as num?,
      loanLimitFrom: json['loanLimitFrom'] as num?,
      loanLimitTo: json['loanLimitTo'] as num?,
      productAccount: json['productAccount'] as num?,
      productCode: json['productCode'] as String?,
      productInterest: json['productInterest'] as num?,
      productLevel: (json['productLevel'] as num?)?.toInt(),
      productLogo: json['productLogo'] as String?,
      productName: json['productName'] as String?,
      productStatus: (json['productStatus'] as num?)?.toInt(),
      receiptAmount: json['receiptAmount'] as num?,
      remainingDays: (json['remainingDays'] as num?)?.toInt(),
      repaidAmount: json['repaidAmount'] as num?,
      repayAmount: json['repayAmount'] as num?,
      repayDate: json['repayDate'] as String?,
      repayDateStr: json['repayDateStr'] as String?,
      serviceFee: json['serviceFee'] as num?,
      term: (json['term'] as num?)?.toInt(),
      totalServiceDays: (json['totalServiceDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LoanConfirmOrderToJson(_LoanConfirmOrder instance) =>
    <String, dynamic>{
      'actualToAccount': instance.actualToAccount,
      'appOrderId': instance.appOrderId,
      'appOrderIdStr': instance.appOrderIdStr,
      'appOrderStatus': instance.appOrderStatus,
      'bankCardName': instance.bankCardName,
      'bankCardNo': instance.bankCardNo,
      'bankCardType': instance.bankCardType,
      'borrowRetryDate': instance.borrowRetryDate,
      'customerLevelUnlock': instance.customerLevelUnlock,
      'dailyInterestRateFrom': instance.dailyInterestRateFrom,
      'dailyInterestRateTo': instance.dailyInterestRateTo,
      'daysPerTermFrom': instance.daysPerTermFrom,
      'daysPerTermTo': instance.daysPerTermTo,
      'dueDate': instance.dueDate,
      'interest': instance.interest,
      'isExtensionSwitch': instance.isExtensionSwitch,
      'loanAmount': instance.loanAmount,
      'loanLimitFrom': instance.loanLimitFrom,
      'loanLimitTo': instance.loanLimitTo,
      'productAccount': instance.productAccount,
      'productCode': instance.productCode,
      'productInterest': instance.productInterest,
      'productLevel': instance.productLevel,
      'productLogo': instance.productLogo,
      'productName': instance.productName,
      'productStatus': instance.productStatus,
      'receiptAmount': instance.receiptAmount,
      'remainingDays': instance.remainingDays,
      'repaidAmount': instance.repaidAmount,
      'repayAmount': instance.repayAmount,
      'repayDate': instance.repayDate,
      'repayDateStr': instance.repayDateStr,
      'serviceFee': instance.serviceFee,
      'term': instance.term,
      'totalServiceDays': instance.totalServiceDays,
    };
