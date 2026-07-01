import 'dart:math' as math;

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/widgets/id_camera_widgets.dart';
import 'package:easy_moni/utils/widgets/cardmask.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// 按相机预览中的证件框裁剪原始照片，保证 OCR 上传图与用户看到的框一致。
Future<Uint8List> cropIdentityCardBytes({
  required Uint8List imageBytes,
  required Size viewportSize,
  required Rect cardRect,
}) async {
  return compute(
    _cropIdentityCardBytesInBackground,
    _CropIdentityCardRequest(
      imageBytes: imageBytes,
      viewportWidth: viewportSize.width,
      viewportHeight: viewportSize.height,
      cardLeft: cardRect.left,
      cardTop: cardRect.top,
      cardWidth: cardRect.width,
      cardHeight: cardRect.height,
    ),
  );
}

Uint8List _cropIdentityCardBytesInBackground(_CropIdentityCardRequest request) {
  final decodedImage = img.decodeImage(request.imageBytes);
  if (decodedImage == null) {
    throw Exception(AppStrings.identityVerifyImageDecodeFailed);
  }

  final originalImage = img.bakeOrientation(decodedImage);
  final scale = math.max(
    request.viewportWidth / originalImage.width,
    request.viewportHeight / originalImage.height,
  );
  final renderedWidth = originalImage.width * scale;
  final renderedHeight = originalImage.height * scale;
  final offsetX = (renderedWidth - request.viewportWidth) / 2;
  final offsetY = (renderedHeight - request.viewportHeight) / 2;

  final sourceLeft = ((request.cardLeft + offsetX) / scale).round();
  final sourceTop = ((request.cardTop + offsetY) / scale).round();
  final sourceWidth = (request.cardWidth / scale).round();
  final sourceHeight = (request.cardHeight / scale).round();
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

/// 后台裁剪参数，避免把 Rect/Size 等 UI 对象跨 isolate 传递。
class _CropIdentityCardRequest {
  const _CropIdentityCardRequest({
    required this.imageBytes,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.cardLeft,
    required this.cardTop,
    required this.cardWidth,
    required this.cardHeight,
  });

  final Uint8List imageBytes;
  final double viewportWidth;
  final double viewportHeight;
  final double cardLeft;
  final double cardTop;
  final double cardWidth;
  final double cardHeight;
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
  const IdCameraScreen({
    super.key,
    this.camera,
    this.isFront = true,
    this.captureOppositeSide = false,
    this.entryToastMessage,
  });

  final CameraDescription? camera;

  /// true=身份证正面，false=身份证反面。
  final bool isFront;

  /// true 时在当前相机页内连续拍摄另一面，避免频繁释放和重建相机。
  final bool captureOppositeSide;

  /// 进入拍摄页后展示的一次性提示文案。
  final String? entryToastMessage;

  @override
  State<IdCameraScreen> createState() => _IdCameraScreenState();
}

/// 身份证拍摄结果，调用方按字段继续走 OCR 与上传接口。
class IdCameraCaptureResult {
  const IdCameraCaptureResult({this.frontImageData, this.backImageData});

  final Uint8List? frontImageData;
  final Uint8List? backImageData;

  bool get hasAnyImage => frontImageData != null || backImageData != null;
}

class _IdCameraScreenState extends State<IdCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String? _cameraError;
  bool _isTakingPicture = false;
  bool _isProcessingCapturedImage = false;
  late bool _currentIsFront;
  Uint8List? _frontImageData;
  Uint8List? _backImageData;
  Size? _viewportSize;
  Rect? _cardRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIsFront = widget.isFront;
    // 证件拍摄需要横屏，以匹配 Ghana Card 的宽版比例。
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeControllerFuture = _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = widget.entryToastMessage?.trim();
      if (!mounted || message == null || message.isEmpty) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
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
      // 证件裁剪后再上传，medium 预览可降低不同机型初始化耗时和内存压力。
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
    } catch (e) {
      AppLogger.debug('相机初始化失败: $e');
      _cameraError = AppStrings.identityVerifyImageNotCaptured;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive) {
      if (controller == null || !controller.value.isInitialized) {
        return;
      }
      controller.dispose();
      _controller = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (controller != null && controller.value.isInitialized) {
        return;
      }
      _initializeControllerFuture = _initCamera();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 离开完整拍摄流程后恢复主流程竖屏显示。
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
                          (_currentIsFront
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
                  if (_isProcessingCapturedImage)
                    const Positioned.fill(
                      child: _CapturedImageProcessingOverlay(),
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

    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
      if (!mounted) return;
      setState(() => _isProcessingCapturedImage = true);
      await _pausePreviewForProcessing(controller);

      final croppedBytes = await cropIdentityCardBytes(
        imageBytes: await image.readAsBytes(),
        viewportSize: viewportSize,
        cardRect: cardRect,
      );
      if (!mounted) return;
      _saveCapturedImage(croppedBytes);
      if (_shouldContinueWithOppositeSide) {
        await _resumePreviewForNextCapture(controller);
        if (!mounted) return;
        setState(() {
          _currentIsFront = !_currentIsFront;
          _isTakingPicture = false;
          _isProcessingCapturedImage = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.identityVerifyFlipCardAndContinue),
          ),
        );
        return;
      }

      Navigator.of(context).pop<IdCameraCaptureResult>(
        IdCameraCaptureResult(
          frontImageData: _frontImageData,
          backImageData: _backImageData,
        ),
      );
    } catch (e) {
      AppLogger.debug('拍照出错: $e');
      if (!mounted) return;
      await _resumePreviewForNextCapture(_controller);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(AppStrings.captureFailed(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
          _isProcessingCapturedImage = false;
        });
      }
    }
  }

  bool get _shouldContinueWithOppositeSide {
    if (!widget.captureOppositeSide) {
      return false;
    }
    return _frontImageData == null || _backImageData == null;
  }

  void _saveCapturedImage(Uint8List imageData) {
    if (_currentIsFront) {
      _frontImageData = imageData;
    } else {
      _backImageData = imageData;
    }
  }

  /// 拍照成功后冻结取景画面，让用户明确知道照片已经定格。
  Future<void> _pausePreviewForProcessing(CameraController controller) async {
    try {
      await controller.pausePreview();
    } catch (e) {
      AppLogger.debug('暂停相机预览失败: $e');
    }
  }

  /// 继续拍摄下一面或失败重试时恢复实时取景。
  Future<void> _resumePreviewForNextCapture(
    CameraController? controller,
  ) async {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.resumePreview();
    } catch (e) {
      AppLogger.debug('恢复相机预览失败: $e');
    }
  }
}

/// 拍照完成后的处理遮罩，避免用户误以为仍需要继续保持拍摄姿势。
class _CapturedImageProcessingOverlay extends StatelessWidget {
  const _CapturedImageProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black45,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  AppStrings.identityVerifyPhotoProcessing,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              onPressed: () =>
                  Navigator.of(context).pop<IdCameraCaptureResult>(),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
