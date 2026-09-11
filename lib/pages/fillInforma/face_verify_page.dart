import 'dart:async';
import 'dart:io';
import 'package:easy_moni/core/constants/app_strings.dart';

import 'package:camera/camera.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/startup_config_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/face_capture/face_detection_service.dart';
import 'package:easy_moni/pages/fillInforma/models/face_verify_action_config.dart';
import 'package:easy_moni/pages/fillInforma/models/face_verify_capture_result.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/loan/components/loan_rounded_page.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class FaceVerifyPage extends ConsumerStatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  ConsumerState<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

class _FaceVerifyPageState extends ConsumerState<FaceVerifyPage> {
  static const int _maxCameraInitAttempts = 3;
  static const Duration _cameraInitTimeout = Duration(seconds: 10);
  static const Duration _cameraInitRetryDelay = Duration(milliseconds: 350);

  final FaceDetectionService _faceDetectionService = FaceDetectionService.create();

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
  Timer? _androidPollTimer;
  bool _blinkClosedDetected = false;
  int _nodStartDirection = 0;
  double? _shakeFirstYawSign;
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
    _androidPollTimer?.cancel();
    unawaited(_releaseCameraController());
    unawaited(_faceDetectionService.dispose());
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _faceDetectionService.init();

      final configResult = await ref.read(startupConfigProvider).call();
      if (!mounted) return;

      if (configResult.isSuccess && configResult.data != null) {
        _startupConfig = configResult.data as StartupConfigResp;
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
    final legacyFaceSteps = _startupConfig?.faceStep;
    if (legacyFaceSteps == null || legacyFaceSteps.isEmpty) {
      return FaceVerifyActionConfig.mockBackendSteps();
    }

    final steps = legacyFaceSteps
        .map(_buildStepFromLegacyFaceStep)
        .whereType<FaceLivenessStep>()
        .toList(growable: false);

    return steps.isNotEmpty ? steps : FaceVerifyActionConfig.mockBackendSteps();
  }

  FaceLivenessStep? _buildStepFromLegacyFaceStep(FaceStep step) {
    return FaceLivenessStep.fromAction(
      _legacyFaceActionFor(step.key),
      description: step.description,
    );
  }

  String _legacyFaceActionFor(String? key) {
    final normalizedKey = key?.trim();
    if (normalizedKey == 'frontFaceStep') {
      return FaceAction.faceFront;
    }
    if (normalizedKey == 'sideFaceStep') {
      return FaceAction.shakeHead;
    }
    if (normalizedKey == 'blinkStep') {
      return FaceAction.blink;
    }
    if (normalizedKey == 'nodHeadStep') {
      return FaceAction.nodHead;
    }
    if (normalizedKey == 'mouthOpenStep') {
      return FaceAction.openMouth;
    }

    return FaceAction.openMouth;
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      _cameraError = AppStrings.faceVerifyUnsupportedWeb;
      return;
    }

    if (!await CameraService.ensureReadyForCapture()) {
      _cameraError = AppStrings.identityVerifyCameraPermissionDenied;
      return;
    }

    await CameraService.settleAfterRecentPermissionGrant();

    for (var attempt = 0; attempt < _maxCameraInitAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(_cameraInitRetryDelay);
        if (!mounted) return;
      }

      try {
        final initialized = await _tryInitializeCameraOnce();
        if (initialized) {
          return;
        }
      } on TimeoutException catch (e) {
        if (attempt == _maxCameraInitAttempts - 1) {
          _cameraError = AppStrings.faceVerifyCameraInitFailed(e);
        }
      } on CameraException catch (e) {
        if (attempt == _maxCameraInitAttempts - 1) {
          _cameraError = AppStrings.faceVerifyCameraInitFailed(e);
        }
      } catch (e) {
        if (attempt == _maxCameraInitAttempts - 1) {
          _cameraError = AppStrings.faceVerifyCameraInitFailed(e);
        }
      }
    }

    _cameraError ??= AppStrings.identityVerifyCameraError;
  }

  Future<bool> _tryInitializeCameraOnce() async {
    CameraController? controller;
    try {
      final cameras = await availableCameras().timeout(_cameraInitTimeout);
      final frontCamera = cameras.cast<CameraDescription?>().firstWhere(
        (camera) => camera?.lensDirection == CameraLensDirection.front,
        orElse: () => null,
      );
      final targetCamera =
          frontCamera ?? (cameras.isNotEmpty ? cameras.first : null);
      if (targetCamera == null) {
        _cameraError = AppStrings.faceVerifyNoCamera;
        return false;
      }

      final imageFormatGroup = Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.nv21;

      controller = CameraController(
        targetCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: imageFormatGroup,
      );

      await controller.initialize().timeout(_cameraInitTimeout);
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted) {
        return false;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
      });
      controller = null;

      final activeController = _cameraController!;
      if (Platform.isIOS) {
        await activeController.startImageStream(_processCameraImage);
      } else {
        _startAndroidFramePolling();
      }
      _startCurrentActionTimeout();
      return true;
    } finally {
      if (controller != null) {
        await controller.dispose();
      }
    }
  }

  void _startAndroidFramePolling() {
    _androidPollTimer?.cancel();
    _androidPollTimer = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) => unawaited(_pollAndroidFrame()),
    );
  }

  Future<void> _pollAndroidFrame() async {
    if (!mounted ||
        _isProcessingImage ||
        _isUploading ||
        _hasCapturedFinalImage ||
        _hasActionTimedOut ||
        _cameraController == null) {
      return;
    }

    _isProcessingImage = true;
    try {
      final photo = await _cameraController!.takePicture();
      final faces = await _faceDetectionService.processImageFile(photo.path);
      await File(photo.path).delete();
      if (!mounted || _hasActionTimedOut) {
        return;
      }
      _handleDetectedFaces(faces);
    } catch (_) {
      return;
    } finally {
      _isProcessingImage = false;
    }
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

    _isProcessingImage = true;
    try {
      final faces = await _faceDetectionService.processCameraImage(
        image,
        _cameraController!.description,
      );
      if (!mounted || _hasActionTimedOut) {
        return;
      }
      _handleDetectedFaces(faces);
    } catch (e) {
      return;
    } finally {
      _isProcessingImage = false;
    }
  }

  void _handleDetectedFaces(List<DetectedFace> faces) {
    if (faces.isEmpty || faces.length != 1) {
      _resetActionProgress();
      return;
    }

    final face = faces.first;

    if (!_allActionsCompleted) {
      final currentStep = _livenessSteps[_currentStepIndex];
      final matched = _matchesStep(face, currentStep);
      if (matched) {
        _stableMatchCount += 1;
        if (_stableMatchCount >= currentStep.stableFrameThreshold) {
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
        unawaited(_captureFinalFacePhoto());
      }
    } else {
      _stableFrontCount = 0;
      if (_hintText != finalCaptureStep.description) {
        setState(() => _hintText = finalCaptureStep.description);
      }
    }
  }

  bool _matchesStep(DetectedFace face, FaceLivenessStep step) {
    if (step.action == FaceAction.faceFront) {
      return _isStrictFrontalFace(face);
    }
    if (step.action == FaceAction.nodHead) {
      return _matchesHeadMovement(
        angle: face.headPitch ?? 0,
        startDirection: _nodStartDirection,
        saveStartDirection: (direction) => _nodStartDirection = direction,
      );
    }
    if (step.action == FaceAction.shakeHead) {
      final turnThreshold = FaceVerifyActionConfig.shakeHeadTurnThreshold;
      if (_shakeFirstYawSign == null) {
        final yaw = face.headYaw;
        if (yaw != null &&
            FaceDetectionService.isHeadTurnedAway(
              face,
              angleThreshold: turnThreshold,
            )) {
          _shakeFirstYawSign = yaw > 0 ? 1.0 : -1.0;
        }
        return false;
      }
      return FaceDetectionService.isHeadTurnedOpposite(
        face,
        firstYawSign: _shakeFirstYawSign!,
        angleThreshold: turnThreshold,
      );
    }
    if (step.action == FaceAction.blink) {
      final left = face.leftEyeOpen ?? 1;
      final right = face.rightEyeOpen ?? 1;
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

  bool _isStrictFrontalFace(DetectedFace face) {
    return FaceDetectionService.isHeadFacingForward(
      face,
      angleThreshold: FaceVerifyActionConfig.frontFaceYawThreshold,
      eyeOpenThreshold: FaceVerifyActionConfig.frontFaceEyeOpenThreshold,
    );
  }

  bool _matchesHeadMovement({
    required double angle,
    required int startDirection,
    required ValueChanged<int> saveStartDirection,
  }) {
    const startThreshold = 5.0;
    const oppositeThreshold = 3.0;

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

  bool _isMouthOpen(DetectedFace face) {
    final opening = face.normalizedLipOpening;
    if (opening == null) return false;
    return opening > 0.26;
  }

  void _resetActionProgress() {
    _stableMatchCount = 0;
    _stableFrontCount = 0;
    _blinkClosedDetected = false;
    _nodStartDirection = 0;
    _shakeFirstYawSign = null;
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

  Future<void> _releaseCameraController() async {
    _androidPollTimer?.cancel();
    _androidPollTimer = null;
    final controller = _cameraController;
    _cameraController = null;
    _isCameraReady = false;
    if (controller == null) {
      return;
    }

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (e) {
      return;
    }

    try {
      await controller.dispose();
    } catch (e) {
      return;
    }
  }

  Future<void> _popWithoutResult() async {
    await _releaseCameraController();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleActionTimeout() async {
    if (!mounted || _hasActionTimedOut || _hasCapturedFinalImage) return;

    _hasActionTimedOut = true;
    _cancelActionTimeout();
    _resetActionProgress();

    setState(() => _hintText = AppStrings.faceVerifyActionTimeout);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.faceVerifyActionTimeout)),
    );
    await _popWithoutResult();
  }

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
        await _releaseCameraController();
        if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return LoanRoundedPage(
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
      header: _FaceVerifyHeader(onBack: _popWithoutResult),
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

class _FaceVerifyHeader extends StatelessWidget {
  const _FaceVerifyHeader({required this.onBack});

  final Future<void> Function() onBack;

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
                onPressed: () => unawaited(onBack()),
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
