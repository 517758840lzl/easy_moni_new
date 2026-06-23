import 'dart:math' as math;

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/widgets/id_camera_widgets.dart';
import 'package:easy_moni/utils/widgets/cardmask.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// 按相机预览中的证件框裁剪原始照片，保证 OCR 上传图与用户看到的框一致。
Future<Uint8List> cropIdentityCardBytes({
  required Uint8List imageBytes,
  required Size viewportSize,
  required Rect cardRect,
}) async {
  final decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) {
    throw Exception(AppStrings.identityVerifyImageDecodeFailed);
  }

  final originalImage = img.bakeOrientation(decodedImage);
  final scale = math.max(
    viewportSize.width / originalImage.width,
    viewportSize.height / originalImage.height,
  );
  final renderedWidth = originalImage.width * scale;
  final renderedHeight = originalImage.height * scale;
  final offsetX = (renderedWidth - viewportSize.width) / 2;
  final offsetY = (renderedHeight - viewportSize.height) / 2;

  final sourceLeft = ((cardRect.left + offsetX) / scale).round();
  final sourceTop = ((cardRect.top + offsetY) / scale).round();
  final sourceWidth = (cardRect.width / scale).round();
  final sourceHeight = (cardRect.height / scale).round();
  final sourceRect = _clampCropRect(
    sourceLeft: sourceLeft,
    sourceTop: sourceTop,
    sourceWidth: sourceWidth,
    sourceHeight: sourceHeight,
    imageWidth: originalImage.width,
    imageHeight: originalImage.height,
  );

  final croppedImage = img.copyCrop(
    originalImage,
    x: sourceRect.left,
    y: sourceRect.top,
    width: sourceRect.width,
    height: sourceRect.height,
  );

  return Uint8List.fromList(img.encodeJpg(croppedImage, quality: 92));
}

_CropRect _clampCropRect({
  required int sourceLeft,
  required int sourceTop,
  required int sourceWidth,
  required int sourceHeight,
  required int imageWidth,
  required int imageHeight,
}) {
  final left = sourceLeft.clamp(0, imageWidth - 1);
  final top = sourceTop.clamp(0, imageHeight - 1);
  final width = sourceWidth.clamp(1, imageWidth - left);
  final height = sourceHeight.clamp(1, imageHeight - top);
  return _CropRect(left: left, top: top, width: width, height: height);
}

/// 裁剪像素区域，避免在业务逻辑中传递松散的 int 参数。
class _CropRect {
  const _CropRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int left;
  final int top;
  final int width;
  final int height;
}

/// Ghana Card 横屏拍摄页，返回框内裁剪后的图片 bytes。
class IdCameraScreen extends StatefulWidget {
  const IdCameraScreen({super.key, this.camera, this.isFront = true});

  final CameraDescription? camera;

  /// true=身份证正面，false=身份证反面。
  final bool isFront;

  @override
  State<IdCameraScreen> createState() => _IdCameraScreenState();
}

class _IdCameraScreenState extends State<IdCameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String? _cameraError;
  bool _isTakingPicture = false;
  Size? _viewportSize;
  Rect? _cardRect;

  @override
  void initState() {
    super.initState();
    // 证件拍摄需要横屏，以匹配 Ghana Card 的宽版比例。
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeControllerFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      CameraDescription? camera = widget.camera;
      if (camera == null) {
        final cameras = await availableCameras();
        camera = cameras.cast<CameraDescription?>().firstWhere(
          (c) => c?.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.isNotEmpty ? cameras.first : null,
        );
      }
      if (camera == null) {
        _cameraError = AppStrings.identityVerifyImageNotCaptured;
        return;
      }
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      _controller = controller;
    } catch (e) {
      AppLogger.debug('相机初始化失败: $e');
      _cameraError = AppStrings.identityVerifyImageNotCaptured;
    }
  }

  @override
  void dispose() {
    // 离开拍摄页后恢复主流程竖屏显示。
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = constraints.biggest;
          final cardRect = IdCardCameraLayout.cardRect(viewportSize);
          _viewportSize = viewportSize;
          _cardRect = cardRect;

          return FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final controller = _controller;
              if (_cameraError != null || controller == null) {
                return _CameraUnavailableView(
                  message:
                      _cameraError ?? AppStrings.identityVerifyImageNotCaptured,
                );
              }

              return Stack(
                children: [
                  Positioned.fill(child: IdCameraPreviewCover(controller)),
                  Positioned.fromRect(
                    rect: cardRect,
                    child: Opacity(
                      opacity: 0.62,
                      child:
                          (widget.isFront
                                  ? Assets.images.inforamtionIdw
                                  : Assets.images.inforamtionIdo)
                              .image(fit: BoxFit.fill),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CardMaskPainter(cardRect: cardRect),
                    ),
                  ),
                  IdCameraUiLayer(
                    cardRect: cardRect,
                    isTakingPicture: _isTakingPicture,
                    onTakePicture: _takePicture,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// 执行拍照并裁剪证件框内容，防止重复点击导致相机状态异常。
  Future<void> _takePicture() async {
    if (_isTakingPicture) {
      return;
    }

    try {
      setState(() => _isTakingPicture = true);
      await _initializeControllerFuture;
      final controller = _controller;
      final viewportSize = _viewportSize;
      final cardRect = _cardRect;
      if (controller == null || viewportSize == null || cardRect == null) {
        return;
      }

      final image = await controller.takePicture();
      final croppedBytes = await cropIdentityCardBytes(
        imageBytes: await image.readAsBytes(),
        viewportSize: viewportSize,
        cardRect: cardRect,
      );
      if (!mounted) return;
      Navigator.of(context).pop<Uint8List>(croppedBytes);
    } catch (e) {
      AppLogger.debug('拍照出错: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.captureFailed(e))));
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }
}

class _CameraUnavailableView extends StatelessWidget {
  const _CameraUnavailableView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop<Uint8List>(),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
