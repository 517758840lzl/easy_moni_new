import 'package:shared_preferences/shared_preferences.dart';

class PermissionStorage {
  static const String _keyPrivacyAgreed = 'privacy_agreed';

  static SharedPreferences? _prefs;

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
}
