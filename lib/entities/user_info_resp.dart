import 'dart:convert';
import 'package:easy_moni/core/utils/app_logger.dart';

class UserInfoResp {
  final int? clientType;
  final String? customerName;
  final String? firstName;
  final int? id;
  final int? idCardNumber;
  final String? lastName;
  final int? level;
  final String? middleName;
  final String? nickName;
  final int? phone;
  final int? sex;
  final int? showBankAccountPage;
  final int? showPersonInfoPage;
  final int? status;
  final int? totalOrderNum;
  final int? userId;
  final String? userName;

  const UserInfoResp({
    this.clientType,
    this.customerName,
    this.firstName,
    this.id,
    this.idCardNumber,
    this.lastName,
    this.level,
    this.middleName,
    this.nickName,
    this.phone,
    this.sex,
    this.showBankAccountPage,
    this.showPersonInfoPage,
    this.status,
    this.totalOrderNum,
    this.userId,
    this.userName,
  });

  factory UserInfoResp.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else if (json is String) {
        map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      } else {
        AppLogger.debug('UserInfoResp.fromJson: 未知类型 ${json.runtimeType}');
        return const UserInfoResp();
      }

      return UserInfoResp(
        clientType: _parseInt(map['clientType']),
        customerName: _parseString(map['customerName']),
        firstName: _parseString(map['firstName']),
        id: _parseInt(map['id']),
        idCardNumber: _parseInt(map['idCardNumber']),
        lastName: _parseString(map['lastName']),
        level: _parseInt(map['level']),
        middleName: _parseString(map['middleName']),
        nickName: _parseString(map['nickName']),
        phone: _parseInt(map['phone']),
        sex: _parseInt(map['sex']),
        showBankAccountPage: _parseInt(map['showBankAccountPage']),
        showPersonInfoPage: _parseInt(map['showPersonInfoPage']),
        status: _parseInt(map['status']),
        totalOrderNum: _parseInt(map['totalOrderNum']),
        userId: _parseInt(map['userId']),
        userName: _parseString(map['userName']),
      );
    } catch (e, stack) {
      AppLogger.debug('UserInfoResp.fromJson 异常: $e\n$stack');
      return const UserInfoResp();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  Map<String, dynamic> toJson() {
    return {
      'clientType': clientType,
      'customerName': customerName,
      'firstName': firstName,
      'id': id,
      'idCardNumber': idCardNumber,
      'lastName': lastName,
      'level': level,
      'middleName': middleName,
      'nickName': nickName,
      'phone': phone,
      'sex': sex,
      'showBankAccountPage': showBankAccountPage,
      'showPersonInfoPage': showPersonInfoPage,
      'status': status,
      'totalOrderNum': totalOrderNum,
      'userId': userId,
      'userName': userName,
    };
  }

  @override
  String toString() {
    return 'UserInfoResp(customerName: $customerName, nickName: $nickName, userName: $userName, phone: $phone, userId: $userId)';
  }
}
