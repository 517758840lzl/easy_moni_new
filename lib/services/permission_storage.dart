import 'package:shared_preferences/shared_preferences.dart';

class PermissionStorage {
  static const String _keyPrivacyAgreed = 'privacy_agreed';
  static const String _keyPermissionsAccepted = 'permissions_accepted';

  static SharedPreferences? _prefs;

  /// 复用 SharedPreferences 实例，避免权限页连续读取状态时重复初始化。
  static Future<SharedPreferences> _instance() async {
    final cachedPrefs = _prefs;
    if (cachedPrefs != null) return cachedPrefs;

    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  static Future<bool> isPrivacyAgreed() async {
    final prefs = await _instance();
    return prefs.getBool(_keyPrivacyAgreed) ?? false;
  }

  static Future<void> setPrivacyAgreed(bool agreed) async {
    final prefs = await _instance();
    await prefs.setBool(_keyPrivacyAgreed, agreed);
  }

  static Future<bool> isPermissionsAccepted() async {
    final prefs = await _instance();
    return prefs.getBool(_keyPermissionsAccepted) ?? false;
  }

  static Future<void> setPermissionsAccepted(bool accepted) async {
    final prefs = await _instance();
    await prefs.setBool(_keyPermissionsAccepted, accepted);
  }
}
