import 'dart:async';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/acquisition_progress_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/acquisition_progress_provider.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:easy_moni/services/saved_session_route_service.dart';
import 'package:easy_moni/services/upload_data/upload_data_sync_service.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:easy_moni/utils/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const Color _backgroundFallbackColor = Color(0xFF20754F);
  static const int _verifyCodeLength = 4;

  late final TextEditingController _phoneController;
  late final TextEditingController _codeController;
  late final FocusNode _codeFocusNode;
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _isSendingCode = false;
  bool _isLoggingIn = false;
  bool _isCheckingSavedSession = true;
  bool _hasPrecachedBackground = false;
  String? _lastAutoCodePhone;

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController();
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
    _phoneController.addListener(_onPhoneChanged);
    _codeController.addListener(_onCodeChanged);
    unawaited(_routeBySavedSession());
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _codeController.removeListener(_onCodeChanged);
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPrecachedBackground) return;

    _hasPrecachedBackground = true;
    // 提前解码登录背景图，减少首帧露出底色的时间。
    precacheImage(Assets.images.loginBg.provider(), context);
  }

  String _normalizedPhone() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  bool _isValidPhoneInput(String digits) {
    final phoneDigits = digits.replaceAll(RegExp(r'[^0-9]'), '');
    return phoneDigits.length == 10 && phoneDigits.startsWith('0');
  }

  /// 判断登录必填输入是否完整，用于控制按钮是否可提交。
  bool _hasRequiredLoginInput() {
    return _normalizedPhone().isNotEmpty &&
        _codeController.text.trim().isNotEmpty;
  }

  void _navigateByProgress(AcquisitionProgressResp progressData) {
    final route = AcquisitionProgressRouteResolver.resolve(progressData);
    AppLogger.debug('登录态分流目标: $route');
    context.go(route);
  }

  /// 登录页启动时检查本地 token，token 有效则按 KYC 进度进入对应页面。
  Future<void> _routeBySavedSession() async {
    final route = await ref
        .read(savedSessionRouteServiceProvider)
        .resolveSavedSessionRoute();
    if (!mounted) return;

    if (route != null) {
      AppLogger.debug('登录态分流目标: $route');
      context.go(route);
      return;
    }

    setState(() => _isCheckingSavedSession = false);
  }

  /// 登录失败时弹出后端提示，验证码错误（如 code=50000）会透传到 message。
  void _showLoginErrorToast(String? message) {
    final errorMessage = message?.trim();
    if (errorMessage == null || errorMessage.isEmpty) {
      showToast(AppStrings.loginFailed, context: context);
      return;
    }

    showToast(errorMessage, context: context);
  }

  /// 手机号输入变化监听
  void _onPhoneChanged() {
    String text = _phoneController.text;

    // 手机号只保留数字；首位不是 0 时按加纳本地号码格式自动补 0。
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isNotEmpty && !text.startsWith('0')) {
      text = '0$text';
    }

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // 更新文本（避免光标跳动）
    if (_phoneController.text != text) {
      final selection = TextSelection.collapsed(offset: text.length);
      _phoneController.value = TextEditingValue(
        text: text,
        selection: selection,
      );
      // 文本更新后会再次触发 listener，直接返回避免重复处理
      return;
    }

    if (text.length < 10) {
      _lastAutoCodePhone = null;
    }

    setState(() {});

    if (text.length == 10) {
      _sendCodeAfterPhoneCompleted(text);
    }
  }

  /// 手机号达到 10 位后自动发送验证码，并避免同一号码重复触发。
  void _sendCodeAfterPhoneCompleted(String phoneText) {
    if (_lastAutoCodePhone == phoneText ||
        _isSendingCode ||
        _countdownSeconds > 0) {
      return;
    }

    _lastAutoCodePhone = phoneText;
    unawaited(_onGetCode());
  }

  /// 验证码输入变化监听
  void _onCodeChanged() {
    String text = _codeController.text;

    // 过滤非数字字符
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > _verifyCodeLength) {
      text = text.substring(0, _verifyCodeLength);
    }

    // 更新文本
    if (_codeController.text != text) {
      final selection = TextSelection.collapsed(offset: text.length);
      _codeController.value = TextEditingValue(
        text: text,
        selection: selection,
      );
      // 文本更新后会再次触发 listener，直接返回避免重复处理
      return;
    }

    setState(() {});
    if (text.length == _verifyCodeLength) {
      _submitLoginAfterCodeCompleted();
    }
  }

  /// 验证码达到当前长度后自动提交登录，复用登录入口的校验与防重复提交逻辑。
  void _submitLoginAfterCodeCompleted() {
    if (_isLoggingIn) {
      return;
    }

    FocusScope.of(context).unfocus();
    unawaited(_onLogin());
  }

  void _startCountdown() {
    _countdownSeconds = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onGetCode() async {
    if (_isSendingCode || _countdownSeconds > 0) {
      return;
    }

    final phone = _normalizedPhone();
    if (phone.isEmpty) {
      showToast(AppStrings.loginPhoneRequired);
      return;
    }
    if (!_isValidPhoneInput(_phoneController.text)) {
      showToast(AppStrings.loginPhoneInvalid);
      return;
    }
    // 触发发送验证码后，立即引导用户输入验证码。
    _codeFocusNode.requestFocus();
    try {
      setState(() => _isSendingCode = true);

      final result = await ref.read(sendVerifyCodeProvider).call('233|$phone');

      if (!mounted) return;
      if (result.isSuccess) {
        showToast(AppStrings.loginCodeSent);
        _startCountdown();
      } else {
        showToast(result.message ?? AppStrings.loginSendCodeFailed);
      }
    } catch (e) {
      if (!mounted) return;
      await AppsFlyerTracker.logAppsFlyerActionEvent(
        AppsFlyerEventNames.registerErr,
        msg: {'message': 'send code failed', 'error': e.toString()},
      );
      showToast(AppStrings.loginSendCodeFailed);
      AppLogger.debug('发送验证码异常: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _onLogin() async {
    if (_isLoggingIn) {
      return;
    }

    final phone = _normalizedPhone();
    final code = _codeController.text.trim();
    if (phone.isEmpty) {
      showToast(AppStrings.loginPhoneRequired);
      return;
    }
    if (!_isValidPhoneInput(_phoneController.text)) {
      showToast(AppStrings.loginPhoneInvalid);
      return;
    }
    if (code.isEmpty) {
      showToast(AppStrings.loginCodeRequired);
      return;
    }

    final maskedPhone = phone.length > 4
        ? '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}'
        : '****';
    AppLogger.debug('登录请求 - 手机号: 233|$maskedPhone, 验证码: ****');

    try {
      setState(() => _isLoggingIn = true);

      final result = await ref
          .read(loginApiProvider)
          .call(phone: '233|$phone', code: code);

      if (!mounted) return;
      AppLogger.debug(
        '登录响应 - status: ${result.status}, message: ${result.message}',
      );
      AppLogger.debug('登录响应数据是否为空: ${result.data == null}');
      if (result.isSuccess) {
        final loginData = result.data;
        AppLogger.debug(
          'loginData.isFirstRegister: ${loginData?.isFirstRegister}',
        );
        AppLogger.debug('loginData.cacheData: ${loginData?.cacheData}');

        final authenticatedLoginData = loginData;
        if (authenticatedLoginData != null &&
            authenticatedLoginData.token != null) {
          if (authenticatedLoginData.isFirstRegister == 1) {
            await AppsFlyerTracker.logAppsFlyerActionEvent(
              AppsFlyerEventNames.registerSuccess,
              msg: authenticatedLoginData.toJson(),
            );
          }
          await HttpProvider.instance.setToken(authenticatedLoginData.token);
          await AuthStorage.saveReviewAccountFlag(
            authenticatedLoginData.isReviewAccount,
          );
          AppLogger.debug('登录成功，Token 已保存');

          // 登录后请求 startup/config 接口
          try {
            final configResult = await ref.read(startupConfigProvider).call();
            if (!mounted) return;

            if (configResult.isSuccess) {
              AppLogger.debug('startupConfig 成功: ${configResult.data}');
            } else {
              AppLogger.debug('startupConfig 失败: ${configResult.message}');
            }
          } catch (e) {
            if (!mounted) return;
            AppLogger.debug('startupConfig 请求异常: $e');
          }

          // 登录后请求 checkUploadDataValid 接口
          try {
            final checkDataResult = await ref
                .read(checkUploadDataValidProvider)
                .call();
            if (!mounted) return;

            if (checkDataResult.isSuccess) {
              AppLogger.debug(
                'checkUploadDataValid 成功: ${checkDataResult.data}',
              );
              ref
                  .read(uploadDataSyncServiceProvider)
                  .handleCheckResult(checkDataResult.data);
            } else {
              AppLogger.debug(
                'checkUploadDataValid 失败: ${checkDataResult.message}',
              );
            }
          } catch (e) {
            if (!mounted) return;
            AppLogger.debug('checkUploadDataValid 请求异常: $e');
          }

          final progressResult = await ref
              .read(acquisitionProgressProvider)
              .call();
          if (!mounted) return;

          AppLogger.debug('进度查询响应: ${progressResult.data}');
          AppLogger.debug('进度查询 isSuccess: ${progressResult.isSuccess}');
          if (progressResult.isSuccess && progressResult.data != null) {
            final progressData = progressResult.data!;
            final filledStep = progressData.filledStep ?? 0;
            AppLogger.debug(
              '用户进度: filledStep=$filledStep, totalStep=${progressData.totalStep}',
            );
            AppLogger.debug('hasCompletedKyc: ${progressData.hasCompletedKyc}');
            AppLogger.debug(
              'processSteps: ${progressData.processSteps?.map((s) => 'step=${s.step}, pageType=${s.pageType}, pageTitle=${s.pageTitle}').join(', ')}',
            );
            AppLogger.debug('根据后端进度决定跳转页面');
            _navigateByProgress(progressData);
          } else {
            AppLogger.debug('进度查询失败，默认跳转个人信息');
            context.go(AppRoutePaths.personalInfo);
          }
        } else {
          AppLogger.debug('Token为空!');
          showToast(AppStrings.loginTokenMissing);
        }
      } else {
        AppLogger.debug('登录失败: ${result.message}');
        _showLoginErrorToast(result.message);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      showToast(AppStrings.errorMessage);
      AppLogger.debug('登录异常: $e');
      AppLogger.debug('堆栈: $stackTrace');
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundFallbackColor,
      body: Stack(
        children: [
          // 背景色底部图片
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundFallbackColor,
                image: DecorationImage(
                  image: Assets.images.loginBg.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_isCheckingSavedSession)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            // Main content
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildLoginContent()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建顶部客服入口
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutePaths.customerService),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Assets.images.customer.image(width: 31, height: 31),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 登录页主体
  Widget _buildLoginContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topSpacing = (constraints.maxHeight * 0.13).clamp(54.0, 100.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                _buildLogoSection(),
                const SizedBox(height: 50),
                _buildPhoneInput(),
                const SizedBox(height: 24),
                _buildCodeInput(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Assets.images.starIcon.image(width: 103, height: 103),
        const Text(
          AppStrings.wellcome,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          width: 320,
          child: Text(
            AppStrings.wellcomedeailData,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white, height: 1.5),
          ),
        ),
      ],
    );
  }

  /// 手机号输入区域展示本地号码格式，完整输入后会自动触发验证码发送。
  Widget _buildPhoneInput() {
    return SizedBox(
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFF8F8F8).withValues(alpha: 0.55),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '+233',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: AppStrings.phoneStr,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Text(
              '${_phoneController.text.length}/10',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 验证码输入区域
  Widget _buildCodeInput() {
    final isCountingDown = _countdownSeconds > 0;
    final isSendButtonDisabled = _isSendingCode || isCountingDown;

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFF8F8F8).withValues(alpha: 0.55),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppStrings.codestr,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (isCountingDown) ...[
                    const SizedBox(width: 12),
                    // 倒计时属于输入框状态
                    Text(
                      '${_countdownSeconds}s',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        height: 20 / 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isCountingDown) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isSendButtonDisabled ? null : _onGetCode,
              child: Container(
                height: 40,
                constraints: const BoxConstraints(minWidth: 102),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF45F3A6)),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: _isSendingCode
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF45F3A6),
                        ),
                      )
                    : const Text(
                        AppStrings.gainCode,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF45F3A6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 登录按钮展示 loading 态，并在登录中阻止重复提交。
  Widget _buildLoginButton() {
    final isLoginButtonDisabled = _isLoggingIn || !_hasRequiredLoginInput();

    return GestureDetector(
      onTap: isLoginButtonDisabled ? null : _onLogin,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: isLoginButtonDisabled
              ? const Color(0xFFbdbdbd)
              : const Color(0xFF45F3A6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: _isLoggingIn
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF104440),
                  ),
                )
              : isLoginButtonDisabled
              ? const Text(
                  AppStrings.login,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : const Text(
                  AppStrings.login,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF104440),
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
