import 'package:flutter/material.dart';

/// 借款确认页内容区顶部弧线参数与白色背景绘制。
class LoanConfirmContentShape {
  LoanConfirmContentShape._();

  static const sideHeight = 16.0;
  static const centerHeight = 30.0;

  static Path topArcPath(Size size) {
    return Path()
      ..moveTo(0, sideHeight)
      ..quadraticBezierTo(0, 0, sideHeight, 0)
      ..cubicTo(
        size.width * 0.28,
        centerHeight,
        size.width * 0.72,
        centerHeight,
        size.width - sideHeight,
        0,
      )
      ..quadraticBezierTo(size.width, 0, size.width, sideHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }
}

/// 绘制带顶部弧线的白色背景，不使用 ClipPath，避免绿色底上产生暗边。
class LoanConfirmWhiteBackground extends StatelessWidget {
  const LoanConfirmWhiteBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _LoanConfirmWhiteBackgroundPainter(),
      child: child,
    );
  }
}

class _LoanConfirmWhiteBackgroundPainter extends CustomPainter {
  const _LoanConfirmWhiteBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      LoanConfirmContentShape.topArcPath(size),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_LoanConfirmWhiteBackgroundPainter oldDelegate) => false;
}
