/// 隐私政策相关配置。
class PrivacyPolicyConfig {
  PrivacyPolicyConfig._();

  static const String _privacyPolicyUrl =
      'https://www.ereekotechsolutions.com/privacy/index.html';

  static const String _termsOfServiceUrl =
      'https://www.ereekotechsolutions.com/terms/index.html';

  /// 借款合同 H5/PDF 地址，后台下发链接时可替换此处或页面内传入。
  static const String _loanAgreementUrl =
      'https://www.ereekotechsolutions.com/terms/index.html';

  /// 获取隐私政策 H5 地址。
  static String get privacyPolicyUrl => _privacyPolicyUrl;

  /// 获取服务条款 H5 地址。
  static String get termsOfServiceUrl => _termsOfServiceUrl;

  /// 获取借款合同 H5/PDF 地址。
  static String get loanAgreementUrl => _loanAgreementUrl;
}
