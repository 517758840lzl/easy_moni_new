import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/login/loginpage.dart';
import 'package:flutter/material.dart';

class FundingLimitDialog extends StatelessWidget {
  final VoidCallback? onGiveUp;

  const FundingLimitDialog({Key? key, this.onGiveUp}) : super(key: key);

  static void show(BuildContext context, {VoidCallback? onGiveUp}) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不消失
      builder: (context) => FundingLimitDialog(onGiveUp: onGiveUp),
    );
  }

  /// 公共挽留弹窗：点击"放弃"时自动跳转 LoginPage 并清空导航栈
  static void showRetainDialog(BuildContext context) {
    show(
      context,
      onGiveUp: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: Assets.images.informationBg.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 紧凑包裹内容
            children: [
              SizedBox(
                height: 120,
                child: Center(
                  child: Assets.images.informationIconLimit.image(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "离成功只差一步，完成借款即可快速到账，解决您的资金需求。",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E826C), // 深绿色主按钮
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    AppStrings.continueSallery,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onGiveUp?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    AppStrings.looseSallery,
                    style: TextStyle(
                      color: Color(0xFF7A8B99),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
