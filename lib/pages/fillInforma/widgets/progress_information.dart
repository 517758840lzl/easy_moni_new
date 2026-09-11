import 'package:flutter/material.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/utils/widgets/linepaint.dart';

class InformationStep {
  const InformationStep._(this.value);

  final String value;

  static const InformationStep personal = InformationStep._('personal');
  static const InformationStep identity = InformationStep._('identity');
  static const InformationStep face = InformationStep._('face');
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
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
          // const SizedBox(height: 8),
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

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _buildStepItem(
            icon: isPersonActive
                ? Assets.images.inforamtionIdSelect.image()
                : Assets.images.inforamtionIdNormal.image(),
            label: AppStrings.informationPersonalStep,
            isCompleted: isPersonActive,
          ),
        ),
        _buildConnector(),
        Flexible(
          child: _buildStepItem(
            icon: isIdActive
                ? Assets.images.inforamtionIdtSelect.image()
                : Assets.images.inforamtionIdtNormal.image(),
            label: AppStrings.informationIdentityStep,
            isCompleted: isIdActive,
          ),
        ),
        _buildConnector(),
        Flexible(
          child: _buildStepItem(
            icon: isFaceActive
                ? Assets.images.inforamtionIdthSelect.image()
                : Assets.images.inforamtionIdthNormal.image(),
            label: AppStrings.informationFaceStep,
            isCompleted: isFaceActive,
          ),
        ),
      ],
    ),
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? const Color(0xFF45F3A6) : Colors.white,
          ),
        ),
      ),
    ],
  );
}

Widget _buildConnector() {
  return Container(
    width: 32,
    height: 0,
    margin: const EdgeInsets.only(bottom: 16),
    child: CustomPaint(painter: DashedLinePainter()),
  );
}
