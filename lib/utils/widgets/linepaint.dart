import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1;

    const double dashWidth = 2; // 每段虚线的长度
    const double dashSpace = 2; // 虚线之间的空白间距

    double startX = 0;
    final double y = size.height / 2; // Y 轴居中

    // 从左到右循环绘制小线段
    while (startX < size.width) {
      // 确保最后一截虚线不会超出画布的总宽度
      final double endX = (startX + dashWidth) > size.width
          ? size.width
          : (startX + dashWidth);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

      // 步进：移动到下一段虚线的起点（当前起点 + 线段长 + 空白长）
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // 如果是纯静态线条，设为 false 节省重绘性能
  }
}
