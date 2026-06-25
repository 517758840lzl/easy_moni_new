/// AppsFlyer 埋点事件常量，集中维护业务漏斗事件名。
class TrackEvents {
  TrackEvents._();

  /// 首次打开应用
  static const String firstOpen = 'first_open';

  /// 注册/验证码申请
  static const String registerApply = 'register_apply';

  /// 注册/验证码申请结果
  static const String registerApplyResult = 'register_apply_result';

  /// 注册/验证码阶段错误
  static const String registerErr = 'register_err';

  /// OTP 登录申请
  static const String otpApply = 'otp_apply';

  /// OTP 登录申请结果
  static const String otpApplyResult = 'otp_apply_result';

  /// 首次注册成功
  static const String registerSuccess = 'register_success';

  /// KYC 完成后自动下单漏斗节点
  static const String autoOrder = 'auto_order';

  /// 确认借款成功
  static const String withdrawSuccess = 'withdraw_success';
}
