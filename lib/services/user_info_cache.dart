import 'dart:convert';

import 'package:easy_moni/entities/user_info_resp.dart';
import 'package:easy_moni/services/upload_data/upload_track_id_store.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    UploadTrackIdStore.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

void logUserInfoCacheHit() {
  if (kReleaseMode) return;
  // ignore: avoid_print
  print('[Profile] snapshot from cache (skip network)');
}
