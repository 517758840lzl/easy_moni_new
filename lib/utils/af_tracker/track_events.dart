/// AppsFlyer 埋点事件名称，集中维护业务漏斗事件名。
class AppsFlyerEventNames {
  AppsFlyerEventNames._();

  /// 首次打开应用
  static const String firstOpen = 'easy_moni_af_first_open';

  /// 注册/验证码申请
  static const String registerApply = 'easy_moni_af_register_apply';

  /// 注册/验证码申请结果
  static const String registerApplyResult =
      'easy_moni_af_register_apply_result';

  /// 注册/验证码阶段错误
  static const String registerErr = 'easy_moni_af_register_err';

  /// OTP 登录申请
  static const String otpApply = 'easy_moni_af_otp_apply';

  /// OTP 登录申请结果
  static const String otpApplyResult = 'easy_moni_af_otp_apply_result';

  /// 首次注册成功
  static const String registerSuccess = 'easy_moni_af_register_success';

  /// KYC 完成后自动下单漏斗节点
  static const String autoOrder = 'easy_moni_af_auto_order';

  /// 确认借款成功
  static const String withdrawSuccess = 'easy_moni_af_withdraw_success';
}
