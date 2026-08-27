import 'dart:convert';

import 'package:easy_moni/entities/user_info_resp.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `/primecl/core/profile/snapshot` 本地缓存；登出 / 登录成功时清除。
class UserInfoCache {
  UserInfoCache._();

  static const String _key = 'cached_user_info_snapshot';
  static UserInfoResp? _memory;

  static Future<UserInfoResp?> load() async {
    if (_memory != null) {
      return _memory;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final cached = UserInfoResp.fromJson(jsonDecode(raw));
      _memory = cached;
      return cached;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(UserInfoResp info) async {
    _memory = info;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(info.toJson()));
  }

  static Future<void> clear() async {
    _memory = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// debug 下区分 profile 缓存命中与真实网络请求（NetworkLog 只打 HTTP）。
void logUserInfoCacheHit() {
  if (kReleaseMode) return;
  // ignore: avoid_print
  print('[Profile] snapshot from cache (skip network)');
}
