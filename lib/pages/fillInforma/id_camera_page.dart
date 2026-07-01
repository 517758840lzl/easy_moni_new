import 'dart:async';
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
  bool _isLeavingCameraPage = false;
  bool _hasRestoredPortraitOrientation = false;
  int _cameraInitToken = 0;
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
    _initializeControllerFuture = _prepareCameraPageAndInit();
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

  /// 先完成横屏与沉浸式布局切换，再初始化相机，降低 Activity 旋转期间抢占相机的概率。
  Future<void> _prepareCameraPageAndInit() async {
    // 证件拍摄需要横屏，以匹配 Ghana Card 的宽版比例。
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await _waitForOrientationLayoutToSettle();
    if (!mounted || _isLeavingCameraPage) {
      return;
    }
    await _initCamera();
  }

  /// 等待 Flutter 完成方向切换后的布局刷新，避免相机初始化撞上窗口尺寸变化。
  Future<void> _waitForOrientationLayoutToSettle() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _initCamera() async {
    final initToken = ++_cameraInitToken;
    CameraController? nextController;
    try {
      _cameraError = null;
      CameraDescription? camera = widget.camera;
      if (camera == null) {
        final cameras = await availableCameras();
        camera = cameras.cast<CameraDescription?>().firstWhere(
          (c) => c?.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.isNotEmpty ? cameras.first : null,
        );
      }
      if (camera == null) {
        AppLogger.warning('相机初始化失败: 未找到可用相机');
        if (_isCurrentCameraInit(initToken)) {
          _cameraError = AppStrings.identityVerifyImageNotCaptured;
        }
        return;
      }
      // 证件裁剪后再上传，medium 预览可降低不同机型初始化耗时和内存压力。
      nextController = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await nextController.initialize();
      if (!_isCurrentCameraInit(initToken)) {
        await nextController.dispose();
        return;
      }

      final oldController = _controller;
      _controller = nextController;
      nextController = null;
      await oldController?.dispose();
    } on CameraException catch (e, stackTrace) {
      AppLogger.error(
        '相机初始化失败: code=${e.code}, description=${e.description}',
        e,
        stackTrace,
      );
      if (_isCurrentCameraInit(initToken)) {
        _cameraError = AppStrings.identityVerifyImageNotCaptured;
      }
    } catch (e, stackTrace) {
      AppLogger.error('相机初始化失败: $e', e, stackTrace);
      if (_isCurrentCameraInit(initToken)) {
        _cameraError = AppStrings.identityVerifyImageNotCaptured;
      }
    } finally {
      if (nextController != null) {
        await nextController.dispose();
      }
    }
  }

  bool _isCurrentCameraInit(int initToken) {
    return mounted && !_isLeavingCameraPage && initToken == _cameraInitToken;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive) {
      _cameraInitToken++;
      if (controller == null || !controller.value.isInitialized) {
        return;
      }
      controller.dispose();
      _controller = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_isLeavingCameraPage) {
        return;
      }
      if (controller != null && controller.value.isInitialized) {
        return;
      }
      _initializeControllerFuture = _prepareCameraPageAndInit();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraInitToken++;
    if (!_hasRestoredPortraitOrientation) {
      unawaited(_restorePortraitOrientation());
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<IdCameraCaptureResult>(
      canPop: _isLeavingCameraPage,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        unawaited(_popWithoutResult());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            final cardRect = IdCardCameraLayout.cardRect(viewportSize);
            _viewportSize = viewportSize;
            _cardRect = cardRect;

            if (_isLeavingCameraPage) {
              return _CameraExitLoadingView(
                cardRect: cardRect,
                isFront: _currentIsFront,
              );
            }

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
                        _cameraError ??
                        AppStrings.identityVerifyImageNotCaptured,
                    onCancel: _popWithoutResult,
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

      await _popWithResult(
        result: IdCameraCaptureResult(
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
      if (mounted && !_isLeavingCameraPage) {
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

  Future<void> _popWithoutResult() async {
    await _popWithResult();
  }

  /// 退出拍照页前先恢复竖屏，避免上一页短暂暴露在横屏状态。
  Future<void> _popWithResult({IdCameraCaptureResult? result}) async {
    if (_isLeavingCameraPage) {
      return;
    }

    _cameraInitToken++;
    if (mounted) {
      setState(() {
        _isLeavingCameraPage = true;
        _isTakingPicture = true;
        _isProcessingCapturedImage = false;
      });
    }

    final controller = _controller;
    _controller = null;
    await controller?.dispose();
    await _restorePortraitOrientation();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop<IdCameraCaptureResult>(result);
  }

  Future<void> _restorePortraitOrientation() async {
    if (_hasRestoredPortraitOrientation) {
      return;
    }

    // 离开完整拍摄流程后恢复主流程竖屏显示。
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _waitForOrientationLayoutToSettle();
    _hasRestoredPortraitOrientation = true;
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

/// 退出相机页时保留证件框界面并展示加载态，避免释放相机后继续依赖预览纹理。
class _CameraExitLoadingView extends StatelessWidget {
  const _CameraExitLoadingView({required this.cardRect, required this.isFront});

  final Rect cardRect;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: _CapturedImageProcessingOverlay(
            message: AppStrings.identityVerifyCameraReturning,
          ),
        ),
      ],
    );
  }
}

/// 拍照完成后的处理遮罩，避免用户误以为仍需要继续保持拍摄姿势。
class _CapturedImageProcessingOverlay extends StatelessWidget {
  const _CapturedImageProcessingOverlay({
    this.message = AppStrings.identityVerifyPhotoProcessing,
  });

  final String message;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  message,
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
  const _CameraUnavailableView({required this.message, required this.onCancel});

  final String message;
  final VoidCallback onCancel;

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
              onPressed: onCancel,
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
