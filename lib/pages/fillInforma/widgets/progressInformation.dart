import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_moni/gen/assets.gen.dart';

import '../../../utils/widgets/linepaint.dart';
Widget buildProgressIndicator({bool isPersonActive = false,bool isidActive = false,bool isMineActive = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildStepItem(
        icon: isPersonActive?Assets.images.inforamtionIdSelect.image():Assets.images.inforamtionIdNormal.image(),
        label: '个人信息',
        isCompleted: isPersonActive,
      ),
      _buildConnector(),
      _buildStepItem(
        icon: isidActive?Assets.images.inforamtionIdtSelect.image():Assets.images.inforamtionIdtNormal.image(),
        label: '身份验证',
        isCompleted: isidActive,
      ),
      _buildConnector(),
      _buildStepItem(icon: isMineActive?Assets.images.inforamtionIdthSelect.image():Assets.images.inforamtionIdthNormal.image(), label: '人脸验证', isCompleted: isMineActive),
    ],
  );
}

Widget _buildStepItem({
  required Widget icon,
  required String label,
  required bool isCompleted,
  bool isActive = false,
}) {
  // 如果是当前步骤但未完成，使用边框样式
  final bool showBorder = !isCompleted;

  return Column(
    children: [
      Container(width: 36, height: 36, child: icon),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isCompleted ? const Color(0xFF45F3A6) : Colors.white,
        ),
      ),
    ],
  );
}

Widget _buildConnector() {
  return Container(
    width: 32,
    height: 0,
    margin: const EdgeInsets.only(bottom: 30),
    child: CustomPaint(painter: DashedLinePainter()),
  );
}