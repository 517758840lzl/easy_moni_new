import 'dart:async';
import 'dart:io';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'package:camera/camera.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/startup_config_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/models/face_verify_action_config.dart';
import 'package:easy_moni/pages/fillInforma/models/face_verify_capture_result.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// 人脸活体采集页，负责相机预览、动作识别和最终照片上传。
class FaceVerifyPage extends ConsumerStatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  ConsumerState<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

/// 维护相机、MLKit 检测和页面展示状态。
class _FaceVerifyPageState extends ConsumerState<FaceVerifyPage> {
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );

  CameraController? _cameraController;
  StartupConfigResp? _startupConfig;
  List<FaceLivenessStep> _livenessSteps = const [];

  Uint8List? _faceImage;

  bool _isLoading = true;
  bool _isCameraReady = false;
  bool _isUploading = false;
  bool _isProcessingImage = false;
  bool _hasCapturedFinalImage = false;
  bool _hasActionTimedOut = false;

  int _currentStepIndex = 0;
  int _stableMatchCount = 0;
  int _stableFrontCount = 0;
  int _actionTimeoutToken = 0;
  Timer? _actionTimeoutTimer;
  bool _blinkClosedDetected = false;
  int _nodStartDirection = 0;
  int _shakeStartDirection = 0;
  String? _cameraError;
  String? _hintText;

  bool get _allActionsCompleted => _currentStepIndex >= _livenessSteps.length;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _cancelActionTimeout();
    unawaited(_cameraController?.dispose());
    unawaited(_faceDetector.close());
    super.dispose();
  }

  /// 初始化后端活体配置和前置摄像头。
  Future<void> _initialize() async {
    try {
      final configResult = await ref.read(startupConfigProvider).call();
      if (!mounted) return;

      if (configResult.isSuccess && configResult.data != null) {
        _startupConfig = configResult.data as StartupConfigResp;
        AppLogger.debug(
          'Face config from backend: faceStep=${_startupConfig?.faceStep}, '
          'faceLiveStep=${_startupConfig?.faceLiveStep}',
        );
      }

      _livenessSteps = _buildLivenessSteps();
      _hintText = _livenessSteps.isNotEmpty
          ? _livenessSteps.first.description
          : FaceVerifyActionConfig.finalCaptureStep.description;

      await _initializeCamera();
    } catch (e) {
      _cameraError = AppStrings.faceVerifyCameraInitFailed(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FaceLivenessStep> _buildLivenessSteps() {
    // TODO: 当前模拟后端动作配置，后续改为读取接口下发的 2-3 个 action。
    return FaceVerifyActionConfig.mockBackendSteps();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      _cameraError = AppStrings.faceVerifyUnsupportedWeb;
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.cast<CameraDescription?>().firstWhere(
      (camera) => camera?.lensDirection == CameraLensDirection.front,
      orElse: () => null,
    );
    final targetCamera =
        frontCamera ?? (cameras.isNotEmpty ? cameras.first : null);
    if (targetCamera == null) {
      _cameraError = AppStrings.faceVerifyNoCamera;
      return;
    }

    final imageFormatGroup = Platform.isIOS
        ? ImageFormatGroup.bgra8888
        : ImageFormatGroup.nv21;

    final controller = CameraController(
      targetCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );

    await controller.initialize();
    await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    await controller.startImageStream(_processCameraImage);

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _cameraController = controller;
      _isCameraReady = true;
    });
    _startCurrentActionTimeout();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted ||
        _isProcessingImage ||
        _isUploading ||
        _hasCapturedFinalImage ||
        _hasActionTimedOut ||
        _cameraController == null) {
      return;
    }

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _isProcessingImage = true;
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted || _hasActionTimedOut || faces.isEmpty) {
        _resetActionProgress();
        return;
      }

      final face = faces.first;
      if (faces.length != 1 || !_isFaceCentered(face)) {
        _resetActionProgress();
        return;
      }

      if (!_allActionsCompleted) {
        final currentStep = _livenessSteps[_currentStepIndex];
        final matched = _matchesStep(face, currentStep);
        if (matched) {
          _stableMatchCount += 1;
          if (_stableMatchCount >= currentStep.stableFrameThreshold) {
            _logFaceActionPassed(
              face: face,
              step: currentStep,
              stepIndex: _currentStepIndex,
            );
            _completeCurrentStep();
          }
        } else {
          _stableMatchCount = 0;
        }
        return;
      }

      final finalCaptureStep = FaceVerifyActionConfig.finalCaptureStep;
      if (_matchesStep(face, finalCaptureStep)) {
        _stableFrontCount += 1;
        if (_stableFrontCount >=
            FaceVerifyActionConfig.finalCaptureStableFrameThreshold) {
          _logFaceActionPassed(
            face: face,
            step: finalCaptureStep,
            stepIndex: _currentStepIndex,
            isFinalCapture: true,
          );
          await _captureFinalFacePhoto();
        }
      } else {
        _stableFrontCount = 0;
        if (_hintText != finalCaptureStep.description) {
          setState(() => _hintText = finalCaptureStep.description);
        }
      }
    } catch (e) {
      AppLogger.debug('人脸识别处理失败: $e');
    } finally {
      _isProcessingImage = false;
    }
  }

  bool _isFaceCentered(Face face) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return false;
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return true;

    final centerX = face.boundingBox.center.dx / previewSize.height;
    final centerY = face.boundingBox.center.dy / previewSize.width;

    return centerX > 0.25 && centerX < 0.75 && centerY > 0.2 && centerY < 0.8;
  }

  bool _matchesStep(Face face, FaceLivenessStep step) {
    if (step.action == FaceAction.faceFront) {
      return _isFrontalFace(face);
    }
    if (step.action == FaceAction.nodHead) {
      return _matchesHeadMovement(
        angle: face.headEulerAngleX ?? 0,
        startDirection: _nodStartDirection,
        saveStartDirection: (direction) => _nodStartDirection = direction,
      );
    }
    if (step.action == FaceAction.shakeHead) {
      return _matchesHeadMovement(
        angle: face.headEulerAngleY ?? 0,
        startDirection: _shakeStartDirection,
        saveStartDirection: (direction) => _shakeStartDirection = direction,
      );
    }
    if (step.action == FaceAction.blink) {
      final left = face.leftEyeOpenProbability ?? 1;
      final right = face.rightEyeOpenProbability ?? 1;
      if (left < 0.35 && right < 0.35) {
        _blinkClosedDetected = true;
      }
      if (_blinkClosedDetected && left > 0.75 && right > 0.75) {
        _blinkClosedDetected = false;
        return true;
      }
      return false;
    }
    if (step.action == FaceAction.openMouth) {
      return _isMouthOpen(face);
    }
    return false;
  }

  /// TODO 动作通过时打印 Google MLKit 返回的人脸关键数据，便于调试动作识别阈值。正式环境删除
  void _logFaceActionPassed({
    required Face face,
    required FaceLivenessStep step,
    required int stepIndex,
    bool isFinalCapture = false,
  }) {
    AppLogger.debug({
      'event': 'google_face_action_passed',
      'action': step.action,
      'description': step.description,
      'stepIndex': stepIndex,
      'isFinalCapture': isFinalCapture,
      'stableFrameThreshold': step.stableFrameThreshold,
      'face': _faceDebugInfo(face),
    });
  }

  /// 整理 Google MLKit Face 对象中的调试信息，避免日志里出现不可读对象。
  Map<String, Object?> _faceDebugInfo(Face face) {
    return {
      'trackingId': face.trackingId,
      'boundingBox': {
        'left': face.boundingBox.left,
        'top': face.boundingBox.top,
        'right': face.boundingBox.right,
        'bottom': face.boundingBox.bottom,
        'width': face.boundingBox.width,
        'height': face.boundingBox.height,
      },
      'headEulerAngleX': face.headEulerAngleX,
      'headEulerAngleY': face.headEulerAngleY,
      'headEulerAngleZ': face.headEulerAngleZ,
      'leftEyeOpenProbability': face.leftEyeOpenProbability,
      'rightEyeOpenProbability': face.rightEyeOpenProbability,
      'smilingProbability': face.smilingProbability,
      'landmarks': {
        'leftEye': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.leftEye],
        ),
        'rightEye': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.rightEye],
        ),
        'leftMouth': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.leftMouth],
        ),
        'rightMouth': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.rightMouth],
        ),
        'bottomMouth': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.bottomMouth],
        ),
        'noseBase': _landmarkDebugInfo(
          face.landmarks[FaceLandmarkType.noseBase],
        ),
      },
    };
  }

  Map<String, int>? _landmarkDebugInfo(FaceLandmark? landmark) {
    if (landmark == null) return null;
    return {
      'x': landmark.position.x,
      'y': landmark.position.y,
    };
  }

  /// 检测需要往返动作的头部动作，例如点头和摇头。
  bool _matchesHeadMovement({
    required double angle,
    required int startDirection,
    required ValueChanged<int> saveStartDirection,
  }) {
    const startThreshold = 7.0;
    const oppositeThreshold = 5.0;

    if (angle.abs() < startThreshold && startDirection == 0) {
      return false;
    }

    final direction = angle > 0 ? 1 : -1;
    if (startDirection == 0) {
      saveStartDirection(direction);
      return false;
    }

    return direction != startDirection && angle.abs() > oppositeThreshold;
  }

  /// 根据嘴部关键点比例判断是否张嘴。
  bool _isMouthOpen(Face face) {
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;
    final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
    if (leftMouth == null || rightMouth == null || bottomMouth == null) {
      return false;
    }

    final mouthWidth = (rightMouth.x - leftMouth.x).abs();
    if (mouthWidth == 0) return false;

    final mouthCenterY = (leftMouth.y + rightMouth.y) / 2;
    final mouthHeight = (bottomMouth.y - mouthCenterY).abs();
    return mouthHeight / mouthWidth > 0.26;
  }

  void _resetActionProgress() {
    _stableMatchCount = 0;
    _stableFrontCount = 0;
    _blinkClosedDetected = false;
    _nodStartDirection = 0;
    _shakeStartDirection = 0;
  }

  bool _isFrontalFace(Face face) {
    final x = (face.headEulerAngleX ?? 0).abs();
    final y = (face.headEulerAngleY ?? 0).abs();
    final z = (face.headEulerAngleZ ?? 0).abs();
    final left = face.leftEyeOpenProbability ?? 1;
    final right = face.rightEyeOpenProbability ?? 1;
    return x < 8 && y < 8 && z < 8 && left > 0.55 && right > 0.55;
  }

  void _completeCurrentStep() {
    if (_currentStepIndex >= _livenessSteps.length) return;
    setState(() {
      _currentStepIndex += 1;
      _resetActionProgress();
      _hintText = _currentStepIndex < _livenessSteps.length
          ? _livenessSteps[_currentStepIndex].description
          : FaceVerifyActionConfig.finalCaptureStep.description;
    });
    _startCurrentActionTimeout();
  }

  /// 为当前动作启动超时计时，动作切换或页面退出时会重置。
  void _startCurrentActionTimeout() {
    if (!mounted ||
        !_isCameraReady ||
        _cameraError != null ||
        _isUploading ||
        _hasCapturedFinalImage ||
        _hasActionTimedOut) {
      return;
    }

    _cancelActionTimeout();
    final timeoutToken = ++_actionTimeoutToken;
    final timeout = _allActionsCompleted
        ? FaceVerifyActionConfig.finalCaptureStep.timeout
        : _livenessSteps[_currentStepIndex].timeout;

    _actionTimeoutTimer = Timer(timeout, () {
      if (timeoutToken != _actionTimeoutToken) return;
      unawaited(_handleActionTimeout());
    });
  }

  void _cancelActionTimeout() {
    _actionTimeoutTimer?.cancel();
    _actionTimeoutTimer = null;
    _actionTimeoutToken += 1;
  }

  /// 当前动作长时间未通过时提示用户，并退回入口页重新开始检测。
  Future<void> _handleActionTimeout() async {
    if (!mounted || _hasActionTimedOut || _hasCapturedFinalImage) return;

    _hasActionTimedOut = true;
    _cancelActionTimeout();
    _resetActionProgress();

    setState(() => _hintText = AppStrings.faceVerifyActionTimeout);

    final controller = _cameraController;
    try {
      if (controller?.value.isStreamingImages == true) {
        await controller!.stopImageStream();
      }
    } catch (e) {
      AppLogger.debug('动作检测超时后停止相机流失败: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.faceVerifyActionTimeout)),
    );
    Navigator.of(context).pop();
  }

  // TODO 最后一步抓拍由后端下发action：face_front ，根据这个action拍照，整体用户无感。暂时由前端模拟，后续再接入接口
  Future<void> _captureFinalFacePhoto() async {
    if (_hasCapturedFinalImage || _isUploading) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _hasCapturedFinalImage = true;
    _cancelActionTimeout();
    setState(() => _isUploading = true);

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() {
        _faceImage = bytes;
      });

      final uploadResult = await ref
          .read(uploadFileProvider)
          .call(bytes: bytes, filename: 'face_verify.jpg');
      if (!mounted) return;

      final uploadedUrl = uploadResult.data?.trim() ?? '';
      if (uploadResult.isSuccess && uploadedUrl.isNotEmpty) {
        setState(() {
          _hintText = AppStrings.faceVerifyCaptureCompleted;
        });
        Navigator.of(context).pop(
          FaceVerifyCaptureResult(imageBytes: bytes, imageUrl: uploadedUrl),
        );
      } else {
        _hasCapturedFinalImage = false;
        setState(() {
          _hintText = uploadResult.message ?? AppStrings.faceVerifyUploadFailed;
        });
      }
    } catch (e) {
      _hasCapturedFinalImage = false;
      if (mounted) {
        setState(() => _hintText = AppStrings.faceVerifyCaptureFailedRetry);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _cameraController;
    if (controller == null) return null;

    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoanRoundedPageShell(
      contentTop: (context) => MediaQuery.of(context).padding.top + 51,
      contentTopRadius: 0,
      backgroundColor: AppColors.primaryDark,
      backgroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF216A4A), Color(0xFF288572)],
        ),
      ),
      header: const _FaceVerifyHeader(),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: [
                  _buildStatusTitle(),
                  const SizedBox(height: 9),
                  _buildActionPrompt(),
                  const SizedBox(height: 42),
                  _buildCameraArea(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusTitle() {
    return const Text(
      AppStrings.faceVerifyGuideTitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1B222A),
        height: 21 / 14,
      ),
    );
  }

  Widget _buildActionPrompt() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: const Color(0xFF216A4A)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.dangerCircle.image(width: 30, height: 30),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _hintText ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF216A4A),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_cameraError != null) {
          return Center(
            child: Text(
              _cameraError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
          );
        }

        final circleSize = constraints.biggest.shortestSide.clamp(0.0, 303.0);

        if (_faceImage != null) {
          return Center(
            child: _CircularCameraFrame(
              size: circleSize,
              child: Image.memory(_faceImage!, fit: BoxFit.cover),
            ),
          );
        }

        final controller = _cameraController;
        if (!_isCameraReady ||
            controller == null ||
            !controller.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize = controller.value.previewSize;
        return Center(
          child: _CircularCameraFrame(
            size: circleSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (previewSize != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewSize.height,
                      height: previewSize.width,
                      child: CameraPreview(controller),
                    ),
                  )
                else
                  CameraPreview(controller),
                if (_isUploading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 深绿色顶部导航，只保留返回键和居中标题。
class _FaceVerifyHeader extends StatelessWidget {
  const _FaceVerifyHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const Text(
              AppStrings.faceVerifyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 20 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆形摄像头区域，统一处理裁剪、背景和设计稿圆形描边素材。
class _CircularCameraFrame extends StatelessWidget {
  const _CircularCameraFrame({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF216A4A)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(child: child),
            ),
          ),
          IgnorePointer(
            child: Assets.images.faceVerifyCircle.image(fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
