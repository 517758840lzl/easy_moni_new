import 'dart:convert';
import 'package:flutter/foundation.dart';

class SignOutResp {
  const SignOutResp();

  factory SignOutResp.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else if (json is String) {
        map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      } else {
        debugPrint('SignOutResp.fromJson: 未知类型 ${json.runtimeType}');
        return const SignOutResp();
      }

      return const SignOutResp();
    } catch (e, stack) {
      debugPrint('SignOutResp.fromJson 异常: $e\n$stack');
      return const SignOutResp();
    }
  }

  @override
  String toString() {
    return 'SignOutResp()';
  }
}
