/// AppsFlyer 埋点事件名称，集中维护业务漏斗事件名。
class AppsFlyerEventNames {
  AppsFlyerEventNames._();

  /// 首次打开应用
  static const String easFirstOpen = 'first_open';

  /// 注册/验证码申请
  static const String easRegisterApply = 'register_apply';

  /// 注册/验证码申请结果
  static const String easRegisterApplyResult =
      'register_apply_result';

  /// 注册/验证码阶段错误
  static const String easRegisterErr = 'register_err';

  /// OTP 登录申请
  static const String easOtpApply = 'otp_apply';

  /// OTP 登录申请结果
  static const String easOtpApplyResult = 'otp_apply_result';

  /// 首次注册成功
  static const String easRegisterSuccess = 'register_success';

  /// KYC 完成后自动下单漏斗节点
  static const String easAutoOrder = 'auto_order';

  /// 确认借款成功
  static const String easWithdrawSuccess = 'withdraw_success';
}
