import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

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
    AppLogger.debug('点击了 Agree & Continue 按钮');
    if (widget.onAgree != null) {
      widget.onAgree!.call();
      return;
    }

    Navigator.of(context).pop();
  }

  void _handleDecline() {
    AppLogger.debug('点击了 Decline 按钮');
    // 拒绝时仅关闭隐私弹窗，不触发外部退出应用逻辑。
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(
          // 限制弹窗最高只能占屏幕高度的 60%
          maxHeight: MediaQuery.of(context).size.height * 0.7,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: PermissionActionButtons(
                  secondaryText: AppStrings.decline,
                  primaryText: AppStrings.agreeandContinue,
                  onSecondaryPressed: _handleDecline,
                  onPrimaryPressed: _handleAgree,
                  padding: const EdgeInsets.fromLTRB(19, 10, 19, 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
