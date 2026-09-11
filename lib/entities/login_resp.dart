import 'dart:convert';

class LoginResp {
  final String? token;
  final int? isFirstRegister;
  final int? userId;
  final String? uuid;

  const LoginResp({
    this.token,
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
        return const LoginResp();
      }

      return LoginResp(
        token: map['token'] as String?,
        isFirstRegister: _parseInt(map['isFirstRegister']),
        userId: _parseInt(map['userId']),
        uuid: map['uuid'] as String?,
      );
    } catch (e) {
      return const LoginResp();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
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
    return 'LoginResp(token: $token, isFirstRegister: $isFirstRegister)';
  }
}
