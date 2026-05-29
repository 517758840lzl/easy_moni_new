import 'dart:async';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/contact_info_page.dart';
import 'package:easy_moni/pages/home/homesell.dart';
import 'package:easy_moni/pages/fillInforma/personal_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/widgets/toast.dart';
import 'providers/auth_provider.dart';

import '../mine/order_detail_page.dart';
import '../mine/order_history_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _isSendingCode = false;
  bool _isAutoSendingCode = false; // 防止自动发送验证码时重复触发

  @override
  void initState() {
    super.initState();
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

  /// 手机号输入变化监听
  void _onPhoneChanged() {
    String text = _phoneController.text;
    
    // 过滤非数字字符
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.length > 10) {
      text = text.substring(0, 10);
    }
    
    // 处理首位数字逻辑
    if (text.isNotEmpty) {
      // 如果首个数字不为0，则在前方补0
      if (text[0] != '0') {
        text = '0$text';
        // 限制补0后最多10位
        if (text.length > 10) {
          text = text.substring(0, 10);
        }
      }
    }
    
    // 更新文本（避免光标跳动）
    if (_phoneController.text != text) {
      final selection = TextSelection.collapsed(offset: text.length);
      _phoneController.value = TextEditingValue(
        text: text,
        selection: selection,
      );
    }
    
    setState(() {});
    
    // 输入10位数字后自动发送验证码
    if (text.length == 10 && !_isAutoSendingCode && _countdownSeconds == 0) {
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
    }
    
    setState(() {});
    
    // 输入4位验证码后立即校验（自动登录）
    if (text.length == 4 && _phoneController.text.length == 10) {
      _onLogin();
    }
  }

  Future<void> _autoSendCode() async {
    _isAutoSendingCode = true;
    final phone = _phoneController.text.trim();
    
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
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    if (phone.length != 10) {
      showToast('请输入10位手机号');
      return;
    }

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
    final phone = _phoneController.text.trim();
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
      final result = await ref.read(loginApiProvider).call(
        phone: '233|$phone',
        code: code,
      );

      if (!mounted) return;
      debugPrint('登录响应 - status: ${result.status}, message: ${result.message}');
      if (result.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeShell()),
        );
      } else {
        showToast(result.message ?? '登录失败，请重试');
      }
    } catch (e) {
      if (!mounted) return;
      showToast('登录失败，请重试');
      debugPrint('登录异常: $e');
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
          SafeArea(
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
                        // Logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        const Text(
                          AppStrings.wellcome,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
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
                  '${_phoneController.text.length}/10',
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
      onTap: _onLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF45F3A6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          AppStrings.login_in,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF104440),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
