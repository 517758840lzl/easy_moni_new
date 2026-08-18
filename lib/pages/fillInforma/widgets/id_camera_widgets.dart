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
    required this.onBack,
    required this.onTakePicture,
    super.key,
  });

  static const _captureButtonSize = 70.0;
  static const _rightPadding = 24.0;
  static const _guideToButtonGap = 20.0;
  static const _guideGridWidth = 196.0;

  final Rect cardRect;
  final bool isTakingPicture;
  final VoidCallback onBack;
  final VoidCallback onTakePicture;

  @override
  Widget build(BuildContext context) {
    final guideRight = _rightPadding + _captureButtonSize + _guideToButtonGap;

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 4,
            child: _CameraBackButton(onPressed: onBack),
          ),
          Positioned(
            top: 12,
            left: 52,
            right: 16,
            child: const Center(child: _CameraTip()),
          ),
          Positioned(
            right: guideRight,
            top: cardRect.center.dy,
            width: _guideGridWidth,
            child: const FractionalTranslation(
              translation: Offset(0, -0.5),
              child: _PhotoGuideGrid(),
            ),
          ),
          Positioned(
            right: _rightPadding,
            top: 0,
            bottom: 0,
            child: _CaptureButton(
              isTakingPicture: isTakingPicture,
              onPressed: onTakePicture,
            ),
          ),
        ],
      ),
    );
  }
}

/// 拍摄页返回按钮，复用设计切图并交给页面处理退出流程。
class _CameraBackButton extends StatelessWidget {
  const _CameraBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: AppStrings.back,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      icon: Assets.images.idBackArrowIcon.image(
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _CameraTip extends StatelessWidget {
  const _CameraTip();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              maxLines: 2,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.25,
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
        const SizedBox(height: 12),
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
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 90, height: 67.2, child: image),
          const SizedBox(height: 4.8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
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
      width: IdCameraUiLayer._captureButtonSize,
      height: IdCameraUiLayer._captureButtonSize,
      child: GestureDetector(
        onTap: isTakingPicture ? null : onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isTakingPicture ? 0.6 : 1,
              child: Assets.images.cameraButton.image(
                width: IdCameraUiLayer._captureButtonSize,
                height: IdCameraUiLayer._captureButtonSize,
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
