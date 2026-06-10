import 'package:flutter/material.dart';

enum LoanBottomActionButtonMode {
  fixed,
  inline,
}

class LoanBottomActionButton extends StatelessWidget {
  const LoanBottomActionButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.text = '\u6211\u8981\u501F\u6B3E',
    this.mode = LoanBottomActionButtonMode.fixed,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final String text;
  final LoanBottomActionButtonMode mode;

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
            color: enabled
                ? const Color(0xFF268470)
                : const Color(0xFFC2C9CE),
            borderRadius: BorderRadius.circular(100),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x332E8F75),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
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
