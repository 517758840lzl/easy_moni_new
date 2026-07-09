import 'package:easy_moni/core/config/privacy_policy_config.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(PrivacyPolicyConfig.privacyPolicyUrl));
  }

  void _handleAgree() {
    if (widget.onAgree != null) {
      widget.onAgree!.call();
      return;
    }

    Navigator.of(context).pop();
  }

  void _handleDecline() {
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
          color: Colors.transparent,
          type: MaterialType.canvas,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ],
              ),
              const SizedBox(height: 8),
              // 中间区域承载隐私政策 H5 内容，并优先响应页面滚动手势。
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        WebViewWidget(
                          controller: _controller,
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                              EagerGestureRecognizer.new,
                            ),
                          },
                        ),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
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
