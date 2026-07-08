import 'package:flutter/material.dart';

/// 页面底部固定主操作按钮，统一处理白色背景和底部安全区。
class LoanBottomActionButton extends StatelessWidget {
  const LoanBottomActionButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.text = '',
    this.fontWeight = FontWeight.w700,
    this.fontSize = 14,
    this.letterSpacing,
    this.height = 40,
    this.padding = const EdgeInsets.fromLTRB(28, 8, 28, 8),
    this.backgroundColor = Colors.white,
    this.enabledColor = const Color(0xFF268470),
    this.disabledColor = const Color(0xFFC2C9CE),
    this.useSafeArea = true,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final double? letterSpacing;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color enabledColor;
  final Color disabledColor;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    // 主按钮主体可被弹窗、底栏等不同场景复用，外层容器保持可配置。
    Widget button = Padding(
      padding: padding,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled ? enabledColor : disabledColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
                letterSpacing: letterSpacing,
              ).copyWith(fontWeight: fontWeight),
            ),
          ),
        ),
      ),
    );

    if (useSafeArea) {
      button = SafeArea(top: false, child: button);
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(bottom: 8),
      child: button,
    );
  }
}
