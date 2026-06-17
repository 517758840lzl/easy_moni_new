import 'package:flutter/material.dart';

/// 页面底部固定主操作按钮，统一处理白色背景和底部安全区。
class LoanBottomActionButton extends StatelessWidget {
  const LoanBottomActionButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.text = '',
    this.fontWeight = FontWeight.w700,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final String text;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
          child: GestureDetector(
            onTap: enabled ? onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFF268470)
                    : const Color(0xFFC2C9CE),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ).copyWith(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
