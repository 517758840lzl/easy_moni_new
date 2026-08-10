/// 应用级常量，AppsFlyer 等跨模块配置集中在此。
abstract final class AppConstants {
  static const packageName = 'com.easy_moni';

  /// MethodChannel 前缀，需与原生侧保持一致。
  static String get methodChannelPrefix => packageName;

  /// AppsFlyer ID 兜底值（原生 UID 尚未就绪时使用）。
  static const defaultAfid = '';

  /// AppsFlyer Dev Key — Android / iOS 共用。
  static const afDevKey = 'PFfRT77vnCVpKaZuU3Pghg';

  /// iOS App Store Apple ID（纯数字 8–11 位，不要 `id` 前缀）。
  /// 发版前填写，或通过 `--dart-define=AF_APPLE_APP_ID=1234567890` 注入。
  static const _afAppleAppIdEnv = String.fromEnvironment('AF_APPLE_APP_ID');
  static const _afAppleAppIdFallback = '';

  static String get afAppleAppId {
    final fromEnv = _afAppleAppIdEnv.trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    return _afAppleAppIdFallback.trim();
  }
}
