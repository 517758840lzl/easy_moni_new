import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';

/// 权限授权场景的双操作按钮，统一拒绝/接受按钮的尺寸、间距和文字样式。
class PermissionActionButtons extends StatelessWidget {
  const PermissionActionButtons({
    super.key,
    required this.secondaryText,
    required this.primaryText,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  final String secondaryText;
  final String primaryText;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPrimaryPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: _PermissionSecondaryButton(
              text: secondaryText,
              onPressed: onSecondaryPressed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: LoanBottomActionButton(
              enabled: onPrimaryPressed != null,
              onPressed: onPrimaryPressed,
              text: primaryText,
              mode: LoanBottomActionButtonMode.inline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionSecondaryButton extends StatelessWidget {
  const _PermissionSecondaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primaryDark),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}
