class PrivacyPolicyConfig {
  PrivacyPolicyConfig._();

  static const String _privacyPolicyUrl =
      'https://www.bluebirdfintech.com/profile/privacy-consent/provision.html';

  static const String _termsOfServiceUrl =
      'https://www.bluebirdfintech.com/profile/customer-agremment/terms.html';

  static const String _loanAgreementUrl =
      'https://www.bluebirdfintech.com/profile/customer-contract/contract.html';

  static String get privacyPolicyUrl => _privacyPolicyUrl;

  static String get termsOfServiceUrl => _termsOfServiceUrl;

  static String get loanAgreementUrl => _loanAgreementUrl;

  static String buildLoanAgreementUrl(Map<String, String> queryParameters) {
    final entries = queryParameters.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.trim())}',
        );
    final query = entries.join('&');
    if (query.isEmpty) return loanAgreementUrl;
    return '$loanAgreementUrl?$query';
  }
}
