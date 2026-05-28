import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/contact_info_page.dart';
import 'package:easy_moni/pages/mine/personal_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onGetCode() {
    debugPrint('点击了获取验证码按钮');
  }

  void _onLogin() {
    final phone = _phoneController.text;
    final code = _codeController.text;
    debugPrint('点击了登录按钮 - 手机号: $phone, 验证码: $code');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ContactInfoPage()),
    );
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
                image: DecorationImage(image: Assets.images.loginBg.provider()),
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
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
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
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _onGetCode,
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
            child: const Text(
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
