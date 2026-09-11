import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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

class IdCameraUiLayer extends StatelessWidget {
  const IdCameraUiLayer({
    required this.isTakingPicture,
    required this.onBack,
    required this.onTakePicture,
    super.key,
  });

  static const _captureButtonSize = 70.0;
  static const _rightPadding = 24.0;

  final bool isTakingPicture;
  final VoidCallback onBack;
  final VoidCallback onTakePicture;

  @override
  Widget build(BuildContext context) {
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
