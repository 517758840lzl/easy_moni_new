import 'dart:async';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../entities/acquisition_progress_resp.dart';
import '../../utils/widgets/toast.dart';
import '../fillInforma/providers/acquisition_progress_provider.dart';
import 'providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const String _defaultPhone = '504684567';
  static const String _defaultCode = '1234';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _isLoggingIn = false;
  bool _isAutoSendingCode = false; // 防止自动发送验证码时重复触发

  @override
  void initState() {
    super.initState();
    _phoneController.text = _defaultPhone;
    _codeController.text = _defaultCode;
    _phoneController.addListener(_onPhoneChanged);
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _codeController.removeListener(_onCodeChanged);
    _phoneController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _normalizedPhone() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  String _routeByProgress(AcquisitionProgressResp progressData) {
    final steps = progressData.processSteps ?? const [];
    final filledStep = progressData.filledStep ?? 0;

    if (progressData.hasCompletedKyc) {
      return '/home';
    }

    if (steps.isEmpty) {
      return '/personal-info';
    }

    ProcessStep? nextStep;
    for (final step in steps) {
      if ((step.step ?? 0) > filledStep) {
        nextStep = step;
        break;
      }
    }

    nextStep ??= steps.isNotEmpty ? steps.first : null;

    switch (filledStep + 1) {
      case 1:
        return '/personal-info';
      case 2:
        return '/contact-info';
      case 4:
        return '/identity-verify';
      case 5:
        return '/face-verify';
      case 6:
        return '/questionnaire';
      default:
        return '/home';
    }
  }

  void _navigateByProgress(AcquisitionProgressResp progressData) {
    final route = _routeByProgress(progressData);
    debugPrint('登录后跳转目标: $route');
    context.go(route);
  }

  /// 手机号输入变化监听
  void _onPhoneChanged() {
    String text = _phoneController.text;

    // 过滤非数字字符
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.startsWith('0')) {
      text = text.substring(1);
    }

    if (text.length > 9) {
      text = text.substring(0, 9);
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

    setState(() {});

    // 输入9位数字后自动发送验证码
    if (text.length == 9 && !_isAutoSendingCode && _countdownSeconds == 0) {
      _autoSendCode();
    }
  }

  /// 验证码输入变化监听
  void _onCodeChanged() {
    String text = _codeController.text;

    // 过滤非数字字符
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
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

    // 输入4位验证码后立即校验（自动登录）
    if (text.length == 4 && _phoneController.text.length > 1) {
      _onLogin();
    }
  }

  Future<void> _autoSendCode() async {
    _isAutoSendingCode = true;
    final phone = _normalizedPhone();

    try {
      final result = await ref.read(sendVerifyCodeProvider).call('233|$phone');

      if (!mounted) return;
      if (result.isSuccess) {
        showToast('验证码已发送');
        _startCountdown();
      } else {
        showToast(result.message ?? '发送失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      showToast('发送失败，请重试');
      debugPrint('发送验证码异常: $e');
    } finally {
      _isAutoSendingCode = false;
    }
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
    final phone = _normalizedPhone();
    if (phone.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    // if (phone.length != 9) {
    //   showToast('请输入9位手机号');
    //   return;
    // }

    try {
      final result = await ref.read(sendVerifyCodeProvider).call('233|$phone');

      if (!mounted) return;
      if (result.isSuccess) {
        showToast('验证码已发送');
        _startCountdown();
      } else {
        showToast(result.message ?? '发送失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      showToast('发送失败，请重试');
      debugPrint('发送验证码异常: $e');
    }
  }

  Future<void> _onLogin() async {
    if (_isLoggingIn) {
      return;
    }

    final phone = _normalizedPhone();
    final code = _codeController.text.trim();
    if (phone.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    if (code.isEmpty) {
      showToast('请输入验证码');
      return;
    }

    debugPrint('登录请求 - 手机号: 233|$phone, 验证码: $code');

    try {
      setState(() => _isLoggingIn = true);

      final result = await ref
          .read(loginApiProvider)
          .call(phone: '233|$phone', code: code);

      if (!mounted) return;
      debugPrint('登录响应 - status: ${result.status}, message: ${result.message}');
      debugPrint('登录响应数据: ${result.data}');
      if (result.data?.isFirstRegister == 1) {
      } else {}
      if (result.isSuccess) {
        final loginData = result.data;
        debugPrint('loginData: $loginData');
        debugPrint('loginData.token: ${loginData?.token}');

        if (loginData?.token != null) {
          await HttpProvider.instance.setToken(loginData!.token);
          debugPrint('登录成功，Token: ${loginData.token}');

          // 登录后请求 startup/config 接口
          try {
            final configResult = await ref
                .read(startupConfigProvider)
                .call();
            if (!mounted) return;

            if (configResult.isSuccess) {
              debugPrint('startupConfig 成功: ${configResult.data}');
            } else {
              debugPrint('startupConfig 失败: ${configResult.message}');
            }
          } catch (e) {
            if (!mounted) return;
            debugPrint('startupConfig 请求异常: $e');
          }

          // 登录后请求 checkUploadDataValid 接口
          try {
            final checkDataResult = await ref
                .read(checkUploadDataValidProvider)
                .call();
            if (!mounted) return;

            if (checkDataResult.isSuccess) {
              debugPrint('checkUploadDataValid 成功: ${checkDataResult.data}');
            } else {
              debugPrint('checkUploadDataValid 失败: ${checkDataResult.message}');
            }
          } catch (e) {
            if (!mounted) return;
            debugPrint('checkUploadDataValid 请求异常: $e');
          }

          //查询检查必要数据是否过期，CheckUploadDataValidApi
          final checkData = await ref.read(checkUploadDataValidProvider).call();
          if (!mounted) return;
          debugPrint('checkData: $checkData');

          final progressResult = await ref
              .read(acquisitionProgressProvider)
              .call();
          if (!mounted) return;

          debugPrint('进度查询响应: ${progressResult.data}');
          debugPrint('进度查询 isSuccess: ${progressResult.isSuccess}');
          if (progressResult.isSuccess && progressResult.data != null) {
            final progressData = progressResult.data!;
            final filledStep = progressData.filledStep ?? 0;
            debugPrint(
              '用户进度: filledStep=$filledStep, totalStep=${progressData.totalStep}',
            );
            debugPrint('hasCompletedKyc: ${progressData.hasCompletedKyc}');
            debugPrint(
              'processSteps: ${progressData.processSteps?.map((s) => 'step=${s.step}, pageType=${s.pageType}, pageTitle=${s.pageTitle}').join(', ')}',
            );
            debugPrint('根据后端进度决定跳转页面');
            _navigateByProgress(progressData);
          } else {
            debugPrint('进度查询失败，默认跳转个人信息');
            context.go('/personal-info');
          }
        } else {
          debugPrint('Token为空!');
          showToast('登录失败，Token获取异常');
        }
      } else {
        debugPrint('登录失败: ${result.message}');
        showToast(result.message ?? '登录失败，请重试');
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      showToast('登录失败，请重试');
      debugPrint('登录异常: $e');
      debugPrint('堆栈: $stackTrace');
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // 背景色底部图片
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.loginBg.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Main content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // 顶部区域
                  _header(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Assets.images.starIcon.image(width: 83,height: 83),
                          const SizedBox(height: 30),
                          const Text(
                            AppStrings.wellcome,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.wellcomedeailData,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 50),
                          _buildPhoneInput(),
                          const SizedBox(height: 24),
                          _buildCodeInput(),
                          const SizedBox(height: 24),
                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            const Spacer(),
            Assets.images.customer.image(width: 28, height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF8F8F8).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '+233',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: AppStrings.phoneStr,
                hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 8),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_phoneController.text.length}/9',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: AppStrings.codestr,
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: (_countdownSeconds > 0) ? null : _onGetCode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            child: Text(
              _countdownSeconds > 0
                  ? '${_countdownSeconds}s'
                  : AppStrings.gainCode,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF45F3A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoggingIn ? null : _onLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF45F3A6),
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
              : const Text(
                  AppStrings.login_in,
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
