import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserInfoResp {
  final int? clientType;
  final int? customerName;
  final int? id;
  final int? idCardNumber;
  final int? level;
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
    this.id,
    this.idCardNumber,
    this.level,
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
        debugPrint('UserInfoResp.fromJson: 未知类型 ${json.runtimeType}');
        return const UserInfoResp();
      }

      return UserInfoResp(
        clientType: _parseInt(map['clientType']),
        customerName: _parseInt(map['customerName']),
        id: _parseInt(map['id']),
        idCardNumber: _parseInt(map['idCardNumber']),
        level: _parseInt(map['level']),
        nickName: map['nickName'] as String?,
        phone: _parseInt(map['phone']),
        sex: _parseInt(map['sex']),
        showBankAccountPage: _parseInt(map['showBankAccountPage']),
        showPersonInfoPage: _parseInt(map['showPersonInfoPage']),
        status: _parseInt(map['status']),
        totalOrderNum: _parseInt(map['totalOrderNum']),
        userId: _parseInt(map['userId']),
        userName: map['userName'] as String?,
      );
    } catch (e, stack) {
      debugPrint('UserInfoResp.fromJson 异常: $e\n$stack');
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

  @override
  String toString() {
    return 'UserInfoResp(nickName: $nickName, userName: $userName, phone: $phone, userId: $userId)';
  }
}
