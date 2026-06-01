import 'dart:convert';
import 'package:flutter/foundation.dart';

class CheckUploadDataValidResp {
  final int? appTrackId;
  final int? isValid;
  final int? isValidDeviceInfo;//是否有可用设备信息 1:有效 0：无效
  final int? isValidContacts;
  final int? isValidAppList;//是否有可用应用列表 1:有效 0：无效
  final int? isValidSmsRecord;//是否有可用短信记录 1:有效 0：无效
  final int? isValidCallLog;

  const CheckUploadDataValidResp({
    this.appTrackId,
    this.isValid,
    this.isValidDeviceInfo,
    this.isValidContacts,
    this.isValidAppList,
    this.isValidSmsRecord,
    this.isValidCallLog,
  });

  factory CheckUploadDataValidResp.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else if (json is String) {
        map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      } else {
        debugPrint('CheckUploadDataValidResp.fromJson: 未知类型 ${json.runtimeType}');
        return const CheckUploadDataValidResp();
      }

      return CheckUploadDataValidResp(
        appTrackId: _parseInt(map['appTrackId']),
        isValid: _parseInt(map['isValid']),
        isValidDeviceInfo: _parseInt(map['isValidDeviceInfo']),
        isValidContacts: _parseInt(map['isValidContacts']),
        isValidAppList: _parseInt(map['isValidAppList']),
        isValidSmsRecord: _parseInt(map['isValidSmsRecord']),
        isValidCallLog: _parseInt(map['isValidCallLog']),
      );
    } catch (e, stack) {
      debugPrint('CheckUploadDataValidResp.fromJson 异常: $e\n$stack');
      return const CheckUploadDataValidResp();
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
    return 'CheckUploadDataValidResp(appTrackId: $appTrackId, isValid: $isValid, isValidDeviceInfo: $isValidDeviceInfo, isValidContacts: $isValidContacts, isValidAppList: $isValidAppList, isValidSmsRecord: $isValidSmsRecord, isValidCallLog: $isValidCallLog)';
  }
}
