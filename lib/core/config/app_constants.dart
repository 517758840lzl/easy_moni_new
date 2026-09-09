abstract final class AppConstants {
  static const packageName = 'com.easy_moni';

  static String get methodChannelPrefix => packageName;

  static const defaultAfid = '';

  static const afDevKey = 'PFfRT77vnCVpKaZuU3Pghg';

  static const _afAppleAppIdEnv = '';
  static const _afAppleAppIdFallback = '';

  static String get afAppleAppId {
    final fromEnv = _afAppleAppIdEnv.trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    return _afAppleAppIdFallback.trim();
  }
}
