import 'dart:async';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/questionnaire_provider.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 借款流程挽留弹窗，用于提示用户继续完成借款资料。
class FundingLimitDialog extends StatefulWidget {
  final VoidCallback? onGiveUp;

  const FundingLimitDialog({super.key, this.onGiveUp});

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
        unawaited(_clearAuthAndNavigateToLogin(context));
      },
    );
  }

  /// 清理本地登录态后进入登录页，确保后续请求不再携带旧 token。
  static Future<void> _clearAuthAndNavigateToLogin(BuildContext context) async {
    // 放弃资料流程时同步释放问卷状态，避免退出登录后旧请求继续重试。
    final container = ProviderScope.containerOf(context, listen: false);
    container.invalidate(questionnaireProvider);

    await HttpProvider.instance.clearAuth();
    if (!context.mounted) return;

    context.go(AppRoutePaths.login);
  }

  @override
  State<FundingLimitDialog> createState() => _FundingLimitDialogState();
}

class _FundingLimitDialogState extends State<FundingLimitDialog> {
  bool _canClose = false;

  void _closeDialog() {
    setState(() => _canClose = true);
    Navigator.pop(context);
  }

  void _giveUp() {
    _closeDialog();
    widget.onGiveUp?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _canClose,
      child: Center(
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
                  AppStrings.fundingLimitDialogDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                LoanBottomActionButton(
                  enabled: true,
                  onPressed: _closeDialog,
                  text: AppStrings.continueSallery,
                  height: 48,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  enabledColor: const Color(0xFF1E826C),
                  useSafeArea: false,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _giveUp,
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
      ),
    );
  }
}

/// 资料填写流程返回拦截器，统一让系统返回键触发挽留弹窗。
class FundingLimitPopScope extends StatelessWidget {
  final Widget child;

  const FundingLimitPopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !context.mounted) {
          return;
        }
        FundingLimitDialog.showRetainDialog(context);
      },
      child: child,
    );
  }
}
