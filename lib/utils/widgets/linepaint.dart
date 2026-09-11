import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1;

    const double dashWidth = 2;
    const double dashSpace = 2;

    double startX = 0;
    final double y = size.height / 2;

    while (startX < size.width) {
      final double endX = (startX + dashWidth) > size.width
          ? size.width
          : (startX + dashWidth);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
