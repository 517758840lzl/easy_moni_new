import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// 相机预览以 cover 方式铺满页面，和裁剪坐标换算保持同一规则。
class IdCameraPreviewCover extends StatelessWidget {
  const IdCameraPreviewCover(this.controller, {super.key});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final orientation = MediaQuery.orientationOf(context);
    final previewWidth = orientation == Orientation.landscape
        ? previewSize.width
        : previewSize.height;
    final previewHeight = orientation == Orientation.landscape
        ? previewSize.height
        : previewSize.width;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

/// 拍摄页覆盖 UI：顶部提示、右侧拍摄示例和快门按钮。
class IdCameraUiLayer extends StatelessWidget {
  const IdCameraUiLayer({
    required this.cardRect,
    required this.isTakingPicture,
    required this.onTakePicture,
    super.key,
  });

  final Rect cardRect;
  final bool isTakingPicture;
  final VoidCallback onTakePicture;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const rightPadding = 24.0;
          const captureButtonSize = 48.0;
          const guideButtonGap = 24.0;
          final guideRight = rightPadding + captureButtonSize + guideButtonGap;
          final availableGuideWidth = constraints.maxWidth - guideRight - 24.0;
          final preferredGuideWidth = (constraints.maxWidth * 0.34).clamp(
            260.0,
            320.0,
          );
          final sideWidth = availableGuideWidth <= 0
              ? 0.0
              : preferredGuideWidth.clamp(0.0, availableGuideWidth);

          return Stack(
            children: [
              const Positioned(
                top: 24,
                left: 0,
                right: 56,
                child: Center(child: _CameraTip()),
              ),
              // 示例图组按证件框中心线定位，确保引导区和拍摄框视觉对齐。
              Positioned(
                right: guideRight,
                top: cardRect.center.dy,
                width: sideWidth,
                child: const FractionalTranslation(
                  translation: Offset(0, -0.5),
                  child: _PhotoGuideGrid(),
                ),
              ),
              // 按钮单独居中展示
              Positioned(
                right: rightPadding,
                top: 0,
                bottom: 0,
                child: _CaptureButton(
                  isTakingPicture: isTakingPicture,
                  onPressed: onTakePicture,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CameraTip extends StatelessWidget {
  const _CameraTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              AppStrings.takeOcrPictures,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGuideGrid extends StatelessWidget {
  const _PhotoGuideGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhotoGuideItem(
              image: Assets.images.inforamtionF.image(fit: BoxFit.contain),
              label: AppStrings.standard,
            ),
            const SizedBox(width: 16),
            _PhotoGuideItem(
              image: Assets.images.inforamtionO.image(fit: BoxFit.contain),
              label: AppStrings.toolBright,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhotoGuideItem(
              image: Assets.images.inforamtionTh.image(fit: BoxFit.contain),
              label: AppStrings.incompletePhoto,
            ),
            const SizedBox(width: 16),
            _PhotoGuideItem(
              image: Assets.images.inforamtionT.image(fit: BoxFit.contain),
              label: AppStrings.blueryPhoto,
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoGuideItem extends StatelessWidget {
  const _PhotoGuideItem({required this.image, required this.label});

  final Widget image;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 90, height: 67.2, child: image),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.isTakingPicture,
    required this.onPressed,
  });

  final bool isTakingPicture;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: GestureDetector(
        onTap: isTakingPicture ? null : onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isTakingPicture ? 0.6 : 1,
              child: Assets.images.cameraButton.image(
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            if (isTakingPicture)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
          ),
    );
  }
}
