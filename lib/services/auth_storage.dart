import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _keyToken = 'auth_token';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _instance() async {
    final cachedPrefs = _prefs;
    if (cachedPrefs != null) return cachedPrefs;

    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  static Future<String?> getToken() async {
    final prefs = await _instance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _instance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> clearToken() async {
    final prefs = await _instance();
    await prefs.remove(_keyToken);
  }
}
