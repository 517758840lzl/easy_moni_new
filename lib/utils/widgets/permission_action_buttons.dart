import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 权限授权场景的双操作按钮，统一拒绝/接受按钮的尺寸、间距和文字样式。
class PermissionActionButtons extends StatelessWidget {
  const PermissionActionButtons({
    super.key,
    required this.secondaryText,
    required this.primaryText,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: _PermissionPrimaryButton(
              onPressed: onPrimaryPressed,
              text: primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPrimaryButton extends StatelessWidget {
  const _PermissionPrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryDark : const Color(0xFFC2C9CE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
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
