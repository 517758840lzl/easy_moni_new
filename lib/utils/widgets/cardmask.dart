import 'package:flutter/material.dart';

class IdCardCameraLayout {
  const IdCardCameraLayout._();

  static const double _designHeight = 375;
  static const double _cardWidth = 371;
  static const double _cardAspectRatio = 339 / 218;
  static const double _maxCardWidthRatio = 0.52;

  static Rect cardRect(Size size) {
    final scale = size.shortestSide / _designHeight;
    final width = (_cardWidth * scale).clamp(
      0.0,
      size.width * _maxCardWidthRatio,
    );
    final height = width / _cardAspectRatio;

    const edgePadding = 16.0;
    const topBarReserve = 48.0;

    final left = ((size.width - width) / 2).clamp(
      edgePadding,
      size.width - width - edgePadding,
    );
    final top = (topBarReserve + (size.height - topBarReserve - height) / 2)
        .clamp(
      topBarReserve,
      size.height - height - edgePadding,
    );

    return Rect.fromLTWH(left, top, width, height);
  }
}

class CardMaskPainter extends CustomPainter {
  const CardMaskPainter({required this.cardRect});

  final Rect cardRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cardRect = RRect.fromRectAndRadius(
      this.cardRect,
      const Radius.circular(16),
    );

    final cardPath = Path()..addRRect(cardRect);

    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cardPath,
    );

    canvas.drawPath(combinedPath, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cardRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CardMaskPainter oldDelegate) {
    return oldDelegate.cardRect != cardRect;
  }
}
