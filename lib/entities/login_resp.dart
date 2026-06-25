import 'dart:convert';
import 'package:easy_moni/core/utils/app_logger.dart';

class LoginResp {
  final String? token;
  final int? cacheData;
  final int? isFirstRegister;
  final int? userId;
  final String? uuid;

  const LoginResp({
    this.token,
    this.cacheData,
    this.isFirstRegister,
    this.userId,
    this.uuid,
  });

  factory LoginResp.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else if (json is String) {
        map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      } else {
        AppLogger.debug('LoginResp.fromJson: 未知类型 ${json.runtimeType}');
        return const LoginResp();
      }

      return LoginResp(
        token: map['token'] as String?,
        cacheData: _parseInt(map['cacheData']),
        isFirstRegister: _parseInt(map['isFirstRegister']),
        userId: _parseInt(map['userId']),
        uuid: map['uuid'] as String?,
      );
    } catch (e, stack) {
      AppLogger.debug('LoginResp.fromJson 异常: $e\n$stack');
      return const LoginResp();
    }
  }

  /// cacheData 为 1 时表示审核账号，首页需要展示审核员版本。
  bool get isReviewAccount => cacheData == 1;

  /// 转换为完整登录响应结构，供加密埋点和调试日志统一使用。
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'cacheData': cacheData,
      'isFirstRegister': isFirstRegister,
      'userId': userId,
      'uuid': uuid,
    };
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
    return 'LoginResp(token: $token, cacheData: $cacheData, isFirstRegister: $isFirstRegister)';
  }
}
