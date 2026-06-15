/// 路由路径常量，集中维护页面跳转使用的 path，避免页面中散落字符串。
class AppRoutePaths {
  static const String root = '/';
  static const String login = '/login';
  static const String customerService = '/customer-service';
  static const String home = '/home';
  static const String idCamera = '/idcamera';
  static const String orderDetail = '/order-detail';
  static const String repayEntry = '/repay-entry';
  static const String repayDetail = '/repay-detail';
  static const String repayMultiDetail = '/repay-multi-detail';
  static const String extensionApply = '/extension-apply';
  static const String payment = '/payment';
  static const String loanConfirm = '/loan-confirm';
  static const String loanReviewing = '/loan-reviewing';
  static const String contactInfo = '/contact-info';
  static const String personalInfo = '/personal-info';
  static const String identityVerify = '/identity-verify';
  static const String faceVerify = '/face-verify';
  static const String questionnaire = '/questionnaire';
  static const String mine = '/mine';
  static const String orderHistory = '/order-history';
  static const String detail = '/detail/:id';

  const AppRoutePaths._();

  static String detailWithId(String id) => '/detail/$id';
}

/// 路由名称常量，供 GoRouter 的 name 和后续 goNamed/pushNamed 统一复用。
class AppRouteNames {
  static const String home = 'home';
  static const String login = 'login';
  static const String customerService = 'customerService';
  static const String homeShell = 'homeShell';
  static const String idCamera = 'idcamera';
  static const String orderDetail = 'orderDetail';
  static const String repayEntry = 'repayEntry';
  static const String repayDetail = 'repayDetail';
  static const String repayMultiDetail = 'repayMultiDetail';
  static const String extensionApply = 'extensionApply';
  static const String payment = 'payment';
  static const String loanConfirm = 'loanConfirm';
  static const String loanReviewing = 'loanReviewing';
  static const String contactInfo = 'contactInfo';
  static const String personalInfo = 'personalInfo';
  static const String identityVerify = 'identityVerify';
  static const String faceVerify = 'faceVerify';
  static const String questionnaire = 'questionnaire';
  static const String mine = 'mine';
  static const String orderHistory = 'orderHistory';
  static const String detail = 'detail';

  const AppRouteNames._();
}
