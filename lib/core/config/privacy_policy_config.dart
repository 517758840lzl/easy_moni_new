/// 隐私政策相关配置。
class PrivacyPolicyConfig {
  PrivacyPolicyConfig._();

  static const String _privacyPolicyUrl =
      'https://www.ereekotechsolutions.com/privacy/index.html';

  static const String _termsOfServiceUrl =
      'https://www.ereekotechsolutions.com/terms/index.html';

  /// 获取隐私政策 H5 地址。
  static String get privacyPolicyUrl => _privacyPolicyUrl;

  /// 获取服务条款 H5 地址。
  static String get termsOfServiceUrl => _termsOfServiceUrl;
}
