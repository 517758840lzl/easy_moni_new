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
  static const int _maxCameraRecoveryAttempts = 1;
  static const int _maxCameraInitRaceRetryAttempts = 2;
  static const Duration _cameraInitRaceRetryDelay = Duration(milliseconds: 300);
  static const List<ResolutionPreset> _cameraResolutionFallbacks = [
    ResolutionPreset.veryHigh,
    ResolutionPreset.high,
    ResolutionPreset.medium,
    ResolutionPreset.low,
  ];

  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  CameraDescription? _activeCameraDescription;
  Future<void> _pendingCameraDispose = Future<void>.value();
  String? _cameraError;
  bool _isTakingPicture = false;
  bool _isProcessingCapturedImage = false;
  bool _showFlipCardHint = false;
  bool _isLeavingCameraPage = false;
  bool _hasRestoredPortraitOrientation = false;
  bool _isRecoveringCamera = false;
  int _cameraInitToken = 0;
  int _cameraRecoveryAttempts = 0;
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

  Future<void> _initCamera({int initRaceRetryAttempts = 0}) async {
    final initToken = ++_cameraInitToken;
    CameraController? nextController;
    try {
      _cameraError = null;
      CameraDescription? camera = widget.camera ?? _activeCameraDescription;
      if (camera == null) {
        final cameras = await availableCameras();
        camera = cameras.cast<CameraDescription?>().firstWhere(
          (c) => c?.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.isNotEmpty ? cameras.first : null,
        );
      }
      if (camera == null) {
        if (_isCurrentCameraInit(initToken)) {
          _cameraError = AppStrings.identityVerifyCameraError;
        }
        return;
      }
      _activeCameraDescription = camera;

      // CameraX 释放旧用例是异步过程，先解绑旧 controller 再绑定新用例。
      final oldController = _controller;
      _controller = null;
      await _disposeCameraControllerSerially(oldController);
      if (!_isCurrentCameraInit(initToken)) {
        return;
      }

      for (final resolutionPreset in _cameraResolutionFallbacks) {
        try {
          // 证件裁剪后再上传，优先 high 保留 OCR 清晰度，失败时向下兼容设备能力。
          nextController = CameraController(
            camera,
            resolutionPreset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );
          nextController.addListener(_onCameraControllerChanged);
          await nextController.initialize();
          if (!_isCurrentCameraInit(initToken)) {
            await _disposeCameraControllerSerially(nextController);
            return;
          }

          _controller = nextController;
          nextController = null;
          _cameraRecoveryAttempts = 0;
          return;
        } on CameraException catch (e) {
          await _disposeCameraControllerSerially(nextController);
          nextController = null;

          if (!_isCurrentCameraInit(initToken)) {
            return;
          }
          if (await _retryCameraInitAfterPreviewRace(
            initToken: initToken,
            initRaceRetryAttempts: initRaceRetryAttempts,
            error: e,
            pendingController: null,
          )) {
            return;
          }
          if (!_shouldRetryWithLowerResolution(e, resolutionPreset)) {
            _cameraError = AppStrings.identityVerifyCameraError;
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
      }

      if (_isCurrentCameraInit(initToken)) {
        _cameraError = AppStrings.identityVerifyCameraError;
      }
    } on CameraException catch (e) {
      if (_isCurrentCameraInit(initToken)) {
        if (await _retryCameraInitAfterPreviewRace(
          initToken: initToken,
          initRaceRetryAttempts: initRaceRetryAttempts,
          error: e,
          pendingController: nextController,
        )) {
          nextController = null;
          return;
        }
        _cameraError = AppStrings.identityVerifyCameraError;
      }
    } catch (e) {
      if (_isCurrentCameraInit(initToken)) {
        if (await _retryCameraInitAfterPreviewRace(
          initToken: initToken,
          initRaceRetryAttempts: initRaceRetryAttempts,
          error: e,
          pendingController: nextController,
        )) {
          nextController = null;
          return;
        }
        _cameraError = AppStrings.identityVerifyCameraError;
      }
    } finally {
      if (nextController != null) {
        await _disposeCameraControllerSerially(nextController);
      }
    }
  }

  /// CameraX 预览 Surface 尚未稳定时，延迟释放并重建相机，避免低概率初始化空指针直接暴露给用户。
  Future<bool> _retryCameraInitAfterPreviewRace({
    required int initToken,
    required int initRaceRetryAttempts,
    required Object error,
    required CameraController? pendingController,
  }) async {
    if (!_shouldRetryAfterCameraInitRace(error, initRaceRetryAttempts)) {
      return false;
    }
    await _disposeCameraControllerSerially(pendingController);
    await Future<void>.delayed(_cameraInitRaceRetryDelay);
    if (!_isCurrentCameraInit(initToken)) {
      return true;
    }

    await _initCamera(initRaceRetryAttempts: initRaceRetryAttempts + 1);
    return true;
  }

  bool _shouldRetryAfterCameraInitRace(
    Object error,
    int initRaceRetryAttempts,
  ) {
    if (initRaceRetryAttempts >= _maxCameraInitRaceRetryAttempts) {
      return false;
    }

    final errorMessage = error.toString();
    return errorMessage.contains('Null check operator used on a null value') ||
        errorMessage.contains('getResolutionInfo') ||
        errorMessage.contains('flutterSurfaceProducer') ||
        errorMessage.contains(
          'releaseFlutterSurfaceTexture() cannot be called',
        );
  }

  bool _shouldRetryWithLowerResolution(
    CameraException exception,
    ResolutionPreset currentPreset,
  ) {
    final currentIndex = _cameraResolutionFallbacks.indexOf(currentPreset);
    if (currentIndex < 0 ||
        currentIndex >= _cameraResolutionFallbacks.length - 1) {
      return false;
    }

    final description = exception.description ?? '';
    return exception.code == 'IllegalArgumentException' &&
        (description.contains('No supported surface combination') ||
            description.contains('CameraUseCaseAdapter'));
  }

  Future<void> _disposeCameraControllerSerially(CameraController? controller) {
    if (controller == null) {
      return _pendingCameraDispose;
    }

    final disposeFuture = _pendingCameraDispose.then(
      (_) => _disposeCameraController(controller),
    );
    _pendingCameraDispose = disposeFuture;
    return disposeFuture;
  }

  bool _isCurrentCameraInit(int initToken) {
    return mounted && !_isLeavingCameraPage && initToken == _cameraInitToken;
  }

  /// 监听 CameraX 运行期错误，避免初始化完成但预览 Surface 后续绑定失败时页面停在黑屏。
  void _onCameraControllerChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (!controller.value.hasError) {
      return;
    }

    final errorDescription = controller.value.errorDescription;

    unawaited(_recoverFromCameraError(errorDescription));
  }

  /// CameraX 预览/拍照链路异常时主动释放并重建一次，失败后再展示不可用态。
  Future<void> _recoverFromCameraError(String? errorDescription) async {
    if (_isRecoveringCamera || _isLeavingCameraPage || !mounted) {
      return;
    }

    _isRecoveringCamera = true;
    _cameraInitToken++;
    final failedController = _controller;
    _controller = null;
    if (mounted) {
      setState(() => _cameraError = null);
    }
    await _disposeCameraControllerSerially(failedController);

    try {
      if (!mounted || _isLeavingCameraPage) {
        return;
      }

      if (_cameraRecoveryAttempts >= _maxCameraRecoveryAttempts) {
        setState(() {
          _cameraError = AppStrings.identityVerifyCameraError;
        });
        return;
      }

      _cameraRecoveryAttempts++;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted || _isLeavingCameraPage) {
        return;
      }

      final recoveryFuture = _prepareCameraPageAndInit();
      _initializeControllerFuture = recoveryFuture;
      setState(() {});
      await recoveryFuture;
    } finally {
      _isRecoveringCamera = false;
      if (mounted && !_isLeavingCameraPage) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cameraInitToken++;
      if (controller == null) {
        return;
      }
      _controller = null;
      unawaited(_disposeCameraControllerSerially(controller));
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_isLeavingCameraPage) {
        return;
      }
      if (controller != null && controller.value.isInitialized) {
        return;
      }
      _cameraRecoveryAttempts = 0;
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
    final controller = _controller;
    _controller = null;
    unawaited(_disposeCameraControllerSerially(controller));
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

                if (_isRecoveringCamera) {
                  return const Center(child: CircularProgressIndicator());
                }

                final controller = _controller;
                if (_cameraError != null || controller == null) {
                  return _CameraUnavailableView(
                    message:
                        _cameraError ?? AppStrings.identityVerifyCameraError,
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
                      onBack: _popWithoutResult,
                      onTakePicture: _takePicture,
                    ),
                    if (_isProcessingCapturedImage)
                      const Positioned.fill(
                        child: _CapturedImageProcessingOverlay(),
                      ),
                    if (_showFlipCardHint)
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: _CapturedImageProcessingOverlay(
                            message:
                                AppStrings.identityVerifyFlipCardAndContinue,
                            showProgress: false,
                          ),
                        ),
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
      setState(() {
        _isTakingPicture = true;
        _showFlipCardHint = false;
      });
      await _initializeControllerFuture;
      final controller = _controller;
      final viewportSize = _viewportSize;
      final cardRect = _cardRect;
      if (controller == null ||
          !controller.value.isInitialized ||
          controller.value.isTakingPicture ||
          viewportSize == null ||
          cardRect == null) {
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
          _showFlipCardHint = true;
        });
        unawaited(_hideFlipCardHintAfterDelay());
        return;
      }

      await _popWithResult(
        result: IdCameraCaptureResult(
          frontImageData: _frontImageData,
          backImageData: _backImageData,
        ),
      );
    } catch (e) {
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

  /// 翻面提示短暂居中展示，避免用户误以为流程已结束。
  Future<void> _hideFlipCardHintAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || _isLeavingCameraPage) {
      return;
    }
    setState(() => _showFlipCardHint = false);
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
        _showFlipCardHint = false;
      });
    }

    final controller = _controller;
    _controller = null;
    await _disposeCameraControllerSerially(controller);
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
    } catch (_) {
      return;
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
    } catch (_) {
      return;
    }
  }

  /// 安全释放相机控制器，兼容 CameraX 预览 Surface 尚未完成绑定时的释放竞态。
  Future<void> _disposeCameraController(CameraController? controller) async {
    if (controller == null) {
      return;
    }

    try {
      controller.removeListener(_onCameraControllerChanged);
      await controller.dispose();
    } on PlatformException catch (e) {
      if (_isCameraXPreviewReleaseRace(e)) {
        return;
      }
    } catch (e) {
      return;
    }
  }

  bool _isCameraXPreviewReleaseRace(PlatformException exception) {
    return exception.code == 'IllegalStateException' &&
        (exception.message?.contains(
              'releaseFlutterSurfaceTexture() cannot be called',
            ) ??
            false);
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
    this.showProgress = true,
  });

  final String message;
  final bool showProgress;

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
                if (showProgress) ...[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.62,
                  ),
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: showProgress ? 14 : 16,
                      fontWeight: showProgress
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
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
