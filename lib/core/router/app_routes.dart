/// 路由路径常量，集中维护页面跳转使用的 path，避免页面中散落字符串。
class AppRoutePaths {
  static const String root = '/';
  static const String permission = '/permission';
  static const String login = '/login';
  static const String customerService = '/customer-service';
  static const String home = '/home';
  static const String idCamera = '/idcamera';
  static const String repayEntry = '/repay-entry';
  static const String repayOrderDetail = '/repay-order-detail';
  static const String repayMultiOrderDetail = '/repay-multi-order-detail';
  static const String extensionApply = '/extension-apply';
  static const String payment = '/payment';
  static const String loanConfirm = '/loan-confirm';
  static const String loanOrderDetail = '/loan-order-detail';
  static const String loanReviewing = '/loan-reviewing';
  static const String contactInfo = '/contact-info';
  static const String personalInfo = '/personal-info';
  static const String identityVerify = '/identity-verify';
  static const String faceVerify = '/face-verify';
  static const String faceVerifyCapture = '/face-verify/capture';
  static const String questionnaire = '/questionnaire';
  static const String mine = '/mine';
  static const String orderHistory = '/order-history';
  static const String privacyPolicy = '/privacy-policy';
  static const String settings = '/settings';
  static const String detail = '/detail/:id';
  static const String repayExtension = '/repay-extension';

  const AppRoutePaths._();

  static String detailWithId(String id) => '/detail/$id';

  /// 构建首页容器路径，明确指定底部导航需要展示的 tab。
  static String homeWithTab(String tab, {bool refreshLoanHome = false}) {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    return _withQuery(home, {
      'tab': tab,
      'tabRequestId': requestId,
      if (refreshLoanHome) 'loanHomeRefreshRequestId': requestId,
    });
  }

  /// 构建单笔还款详情路径，使用 query 参数承载订单号以支持页面恢复。
  static String repayOrderDetailWithIds(Iterable<String?> appOrderIds) {
    return _withQuery(repayOrderDetail, {'appOrderIds': _join(appOrderIds)});
  }

  /// 构建多笔还款详情路径，使用 query 参数承载订单号列表以支持页面恢复。
  static String repayMultiOrderDetailWithIds(Iterable<String?> appOrderIds) {
    return _withQuery(repayMultiOrderDetail, {
      'appOrderIds': _join(appOrderIds),
    });
  }

  /// 构建展期申请路径，使用 query 参数承载展期接口和优惠券所需参数。
  static String repayExtensionWithParams({
    required String? appOrderId,
    required String? productCode,
    required int? installmentId,
  }) {
    return _withQuery(repayExtension, {
      'appOrderId': appOrderId?.trim() ?? '',
      'productCode': productCode?.trim() ?? '',
      'installmentId': installmentId?.toString() ?? '',
    });
  }

  static String _withQuery(String path, Map<String, String> queryParameters) {
    final cleaned = Map<String, String>.fromEntries(
      queryParameters.entries.where((entry) => entry.value.trim().isNotEmpty),
    );
    return Uri(path: path, queryParameters: cleaned).toString();
  }

  static String _join(Iterable<String?> values) {
    return values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(',');
  }
}

/// 首页底部导航 tab 标识，避免跨页面跳转时依赖 HomeShell 的历史状态。
class AppHomeTabs {
  static const String loan = 'loan';
  static const String repay = 'repay';
  static const String mine = 'mine';

  const AppHomeTabs._();
}

/// 路由名称常量，供 GoRouter 的 name 和后续 goNamed/pushNamed 统一复用。
class AppRouteNames {
  static const String splash = 'splash';
  static const String permission = 'permission';
  static const String login = 'login';
  static const String customerService = 'customerService';
  static const String homeShell = 'homeShell';
  static const String idCamera = 'idcamera';
  static const String orderDetail = 'orderDetail';
  static const String repayEntry = 'repayEntry';
  static const String repayOrderDetail = 'repayOrderDetail';
  static const String repayMultiOrderDetail = 'repayMultiOrderDetail';
  static const String extensionApply = 'extensionApply';
  static const String payment = 'payment';
  static const String loanConfirm = 'loanConfirm';
  static const String loanOrderDetail = 'loanOrderDetail';
  static const String loanReviewing = 'loanReviewing';
  static const String contactInfo = 'contactInfo';
  static const String personalInfo = 'personalInfo';
  static const String identityVerify = 'identityVerify';
  static const String faceVerify = 'faceVerify';
  static const String faceVerifyCapture = 'faceVerifyCapture';
  static const String questionnaire = 'questionnaire';
  static const String mine = 'mine';
  static const String orderHistory = 'orderHistory';
  static const String privacyPolicy = 'privacyPolicy';
  static const String settings = 'settings';
  static const String detail = 'detail';
  static const String repayExtension = 'repayExtension';

  const AppRouteNames._();
}
