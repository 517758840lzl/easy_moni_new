/// 隐私政策相关配置。
class PrivacyPolicyConfig {
  PrivacyPolicyConfig._();

  static const String _privacyPolicyUrl =
      'https://www.yaalexfinance.com/profile/privacy-consent/provision.html';

  static const String _termsOfServiceUrl =
      'https://www.yaalexfinance.com/profile/customer-agremment/terms.html';

  static const String _loanAgreementUrl =
      'https://www.ereekotechsolutions.com/terms/index.html';

  static String get privacyPolicyUrl => _privacyPolicyUrl;

  static String get termsOfServiceUrl => _termsOfServiceUrl;

  static String get loanAgreementUrl => _loanAgreementUrl;
}
