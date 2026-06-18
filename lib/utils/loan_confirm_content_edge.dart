import 'package:flutter/material.dart';

// 借款确认页内容区顶部阴影，和裁剪路径使用同一组曲线参数保持贴合。
class LoanConfirmContentEdge extends StatelessWidget {
  const LoanConfirmContentEdge({super.key});

  static const sideHeight = 16.0;
  static const centerHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LoanConfirmContentEdgePainter());
  }
}

class _LoanConfirmContentEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final curve = Path()
      ..moveTo(0, LoanConfirmContentEdge.sideHeight)
      ..quadraticBezierTo(0, 0, LoanConfirmContentEdge.sideHeight, 0)
      ..cubicTo(
        size.width * 0.28,
        LoanConfirmContentEdge.centerHeight,
        size.width * 0.72,
        LoanConfirmContentEdge.centerHeight,
        size.width - LoanConfirmContentEdge.sideHeight,
        0,
      )
      ..quadraticBezierTo(
        size.width,
        0,
        size.width,
        LoanConfirmContentEdge.sideHeight,
      );

    canvas.drawPath(
      curve.shift(const Offset(0, -1)),
      Paint()
        ..color = const Color(0x663D250C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_LoanConfirmContentEdgePainter oldDelegate) => false;
}
