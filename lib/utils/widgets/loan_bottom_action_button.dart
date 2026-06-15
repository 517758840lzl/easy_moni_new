import 'package:flutter/material.dart';

enum LoanBottomActionButtonMode { fixed, inline }

class LoanBottomActionButton extends StatelessWidget {
  const LoanBottomActionButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.text = '确认借款',
    this.mode = LoanBottomActionButtonMode.fixed,
    this.fontWeight = FontWeight.w700,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final String text;
  final LoanBottomActionButtonMode mode;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final button = Padding(
      padding: _padding,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF268470) : const Color(0xFFC2C9CE),
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
    );

    if (mode == LoanBottomActionButtonMode.inline) {
      return button;
    }

    return Container(
      color: Colors.white,
      child: SafeArea(top: false, child: button),
    );
  }

  EdgeInsets get _padding {
    switch (mode) {
      case LoanBottomActionButtonMode.fixed:
        return const EdgeInsets.fromLTRB(28, 8, 28, 8);
      case LoanBottomActionButtonMode.inline:
        return EdgeInsets.zero;
    }
  }
}
