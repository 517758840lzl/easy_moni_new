import 'package:shared_preferences/shared_preferences.dart';

class PermissionStorage {
  static const String _keyPrivacyAgreed = 'privacy_agreed';
  static const String _keyPermissionsAccepted = 'permissions_accepted';

  static final SharedPreferences? _prefs = null;

  static Future<bool> isPrivacyAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrivacyAgreed) ?? false;
  }

  static Future<void> setPrivacyAgreed(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyAgreed, agreed);
  }

  static Future<bool> isPermissionsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPermissionsAccepted) ?? false;
  }

  static Future<void> setPermissionsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPermissionsAccepted, accepted);
  }
}
