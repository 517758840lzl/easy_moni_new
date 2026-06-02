import 'package:flutter/material.dart';

class CardMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
          .withOpacity(0.7) // 半透明遮罩颜色
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 证件框的路径 (根据 UI 比例调整大小和位置)
    // 假设在横屏下，证件框位于左侧，腾出右侧给按钮
    final cardWidth = size.width * 0.5;
    final cardHeight = cardWidth * 218 / 339.0;
    final cardLeft = size.width * 0.08;
    final cardTop = (size.height - cardHeight) / 3 * 2;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight),
      const Radius.circular(16), // 圆角
    );

    final cardPath = Path()..addRRect(cardRect);

    // ：使用 evenOdd 填充规则实现“镂空”
    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cardPath,
    );

    // 绘制遮罩层
    canvas.drawPath(combinedPath, paint);

    //绘制证件框的白色/绿色高亮边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cardRect, borderPaint);

    // // 如果需要绘制内部的绿色引导线框
    // final innerRect = RRect.fromRectAndRadius(
    //   Rect.fromLTWH(cardLeft + 8, cardTop + 8, cardWidth - 16, cardHeight - 16),
    //   const Radius.circular(12),
    // );
    // final innerBorderPaint = Paint()
    //   ..color = const Color(0xFF28503C).withOpacity(0.5)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 4.0;
    // canvas.drawRRect(innerRect, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
