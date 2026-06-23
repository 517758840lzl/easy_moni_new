import 'package:flutter/material.dart';

/// 证件拍摄页布局参数，统一遮罩、引导图和裁剪坐标。
class IdCardCameraLayout {
  const IdCardCameraLayout._();

  static const double _designWidth = 812;
  static const double _designHeight = 375;
  static const double _cardLeft = 37;
  static const double _cardTop = 99;
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
    final left = (_cardLeft * size.width / _designWidth).clamp(
      16.0,
      size.width - width - 16,
    );
    final top = (_cardTop * size.height / _designHeight).clamp(
      16.0,
      size.height - height - 16,
    );

    return Rect.fromLTWH(left, top, width, height);
  }
}

/// 身份证拍摄遮罩，露出证件框并绘制白色边框。
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

    // 使用差集实现遮罩镂空。
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
