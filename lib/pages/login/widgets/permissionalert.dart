import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/pages/login/loginpage.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  final VoidCallback? onAgree;
  final VoidCallback? onDecline;

  const PrivacyPolicyDialog({super.key, this.onAgree, this.onDecline});

  static Future<T?> show<T>({
    required BuildContext context,
    VoidCallback? onAgree,
    VoidCallback? onDecline,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PrivacyPolicyDialog(onAgree: onAgree, onDecline: onDecline);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final String _privacyText = AppStrings.grantedData;

  void _handleAgree() {
    debugPrint('点击了 Agree & Continue 按钮');
    widget.onAgree?.call();
    // 跳转并销毁当前页面（用户登录后无法再返回到上一个页面）
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _handleDecline() {
    debugPrint('点击了 Decline 按钮');
    widget.onDecline?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(
          // 限制弹窗最高只能占屏幕高度的 60%
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent, // 设为透明，继续使用 Container 的背景色和圆角
          type: MaterialType.canvas,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 19, left: 19),
                    child: Text(
                      AppStrings.privacyData,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.6,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 19, right: 15),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Assets.images.loginClose.image(
                          width: 14,
                          height: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              // 中间区域 - 可滚动
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(19, 0, 19, 16),
                  child: Text(
                    _privacyText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 0, 19, 19),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleDecline,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF268470)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          AppStrings.declineBtn,
                          style: TextStyle(
                            color: Color(0xFF268470),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleAgree,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF268470),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          AppStrings.agreeandContinue,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
