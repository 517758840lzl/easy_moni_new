import 'package:shared_preferences/shared_preferences.dart';

abstract final class AttributionStore {
  static const _firstOpenKey = 'tracking_first_open_done';
  static const _afidKey = 'tracking_afid';
  static const _mediaSourceKey = 'tracking_media_source';
  static const _referrerKey = 'tracking_install_referrer';
  static const _gaidKey = 'tracking_gaid';

  static Future<bool> isFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstOpenKey) ?? false);
  }

  static Future<void> markFirstOpenReported() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstOpenKey, true);
  }

  static Future<String> getAfid([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return p.getString(_afidKey) ?? '';
  }

  static Future<void> setAfid(String afid) async {
    if (afid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_afidKey, afid);
  }

  static Future<String> getMediaSource([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return p.getString(_mediaSourceKey) ?? '';
  }

  static Future<void> setMediaSource(String mediaSource) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mediaSourceKey, mediaSource);
  }

  static Future<String> getReferrer([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return p.getString(_referrerKey) ?? '';
  }

  static Future<void> setReferrer(String referrer) async {
    if (referrer.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_referrerKey) ?? '';
    if (existing.isNotEmpty) return;
    await prefs.setString(_referrerKey, referrer);
  }

  static Future<String> getGaid([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return p.getString(_gaidKey) ?? '';
  }

  static Future<void> setGaid(String gaid) async {
    if (gaid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gaidKey, gaid);
  }
}
