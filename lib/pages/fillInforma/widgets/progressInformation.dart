import 'package:flutter/material.dart';
import 'package:easy_moni/gen/assets.gen.dart';

import '../../../utils/widgets/linepaint.dart';

enum InformationStep {
  personal,
  identity,
  face,
}

Widget buildInformationHeader({
  required BuildContext context,
  required String title,
  required InformationStep activeStep,
  VoidCallback? onBack,
}) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: Assets.images.inforamtionBgheader.provider(),
        fit: BoxFit.cover,
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          buildProgressIndicator(activeStep: activeStep),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget buildProgressIndicator({required InformationStep activeStep}) {
  final isPersonActive = activeStep == InformationStep.personal;
  final isIdActive = activeStep == InformationStep.identity;
  final isFaceActive = activeStep == InformationStep.face;

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
        icon: isIdActive?Assets.images.inforamtionIdtSelect.image():Assets.images.inforamtionIdtNormal.image(),
        label: '身份验证',
        isCompleted: isIdActive,
      ),
      _buildConnector(),
      _buildStepItem(icon: isFaceActive?Assets.images.inforamtionIdthSelect.image():Assets.images.inforamtionIdthNormal.image(), label: '人脸验证', isCompleted: isFaceActive),
    ],
  );
}

Widget _buildStepItem({
  required Widget icon,
  required String label,
  required bool isCompleted,
}) {
  return Column(
    children: [
      SizedBox(width: 36, height: 36, child: icon),
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
