import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyIsReviewAccount = 'auth_is_review_account';
  static SharedPreferences? _prefs;

  /// 复用 SharedPreferences 实例，减少启动和页面分流阶段的重复平台通道初始化。
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

  static Future<bool> isReviewAccount() async {
    final prefs = await _instance();
    return prefs.getBool(_keyIsReviewAccount) ?? false;
  }

  /// 保存登录账号类型，供首页容器恢复时选择普通首页或审核员首页。
  static Future<void> saveReviewAccountFlag(bool isReviewAccount) async {
    final prefs = await _instance();
    await prefs.setBool(_keyIsReviewAccount, isReviewAccount);
  }

  static Future<void> clearToken() async {
    final prefs = await _instance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyIsReviewAccount);
  }
}
