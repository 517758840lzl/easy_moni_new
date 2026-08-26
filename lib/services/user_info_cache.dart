import 'dart:convert';

import 'package:easy_moni/entities/user_info_resp.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `/primecl/core/profile/snapshot` 本地缓存；登出 / 登录成功时清除。
class UserInfoCache {
  UserInfoCache._();

  static const String _key = 'cached_user_info_snapshot';

  static Future<UserInfoResp?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return UserInfoResp.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(UserInfoResp info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(info.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
