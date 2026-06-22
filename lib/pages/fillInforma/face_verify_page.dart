import 'dart:async';
import 'dart:io';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'package:camera/camera.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/entities/startup_config_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/home/homesell.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:easy_moni/utils/widgets/informationBottomButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../utils/widgets/limit_toast.dart';

class FaceVerifyPage extends ConsumerStatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  ConsumerState<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

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
  StepInfo? _stepInfo;
  int? _processId;
  StartupConfigResp? _startupConfig;
  List<_FaceLivenessStep> _livenessSteps = const [];

  Uint8List? _faceImage;
  String? _faceImageUrl;

  bool _isLoading = true;
  bool _isCameraReady = false;
  bool _isSubmitting = false;
  bool _isUploading = false;
  bool _isProcessingImage = false;
  bool _hasCapturedFinalImage = false;

  int _currentStepIndex = 0;
  int _stableMatchCount = 0;
  int _stableFrontCount = 0;
  bool _blinkClosedDetected = false;
  String? _cameraError;
  String? _hintText;

  bool get _canContinue => _faceImageUrl?.isNotEmpty == true;
  bool get _allActionsCompleted => _currentStepIndex >= _livenessSteps.length;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    unawaited(_cameraController?.dispose());
    unawaited(_faceDetector.close());
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final results = await Future.wait([
        ref.read(acpElementInfoProvider).call(5),
        ref.read(startupConfigProvider).call(),
      ]);
      if (!mounted) return;

      final stepResult = results[0] as dynamic;
      final configResult = results[1] as dynamic;

      if (stepResult.isSuccess && stepResult.data != null) {
        _processId = stepResult.data.processId as int?;
        _stepInfo = stepResult.data.stepInfoList.isNotEmpty
            ? stepResult.data.stepInfoList.first
            : null;
      }

      if (configResult.isSuccess && configResult.data != null) {
        _startupConfig = configResult.data as StartupConfigResp;
        AppLogger.debug(
          'Face config from backend: faceStep=${_startupConfig?.faceStep}, '
          'faceLiveStep=${_startupConfig?.faceLiveStep}',
        );
      }

      _livenessSteps = _buildLivenessSteps(_startupConfig);
      _hintText = _livenessSteps.isNotEmpty
          ? _livenessSteps.first.description
          : 'Please face the camera';

      await _initializeCamera();
    } catch (e) {
      _cameraError = '相机初始化失败: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<_FaceLivenessStep> _buildLivenessSteps(StartupConfigResp? config) {
    final stepsFromConfig =
        config?.faceStep
            ?.map(
              (step) => _FaceLivenessStep.fromBackend(
                key: step.key,
                description: step.description,
              ),
            )
            .whereType<_FaceLivenessStep>()
            .toList() ??
        <_FaceLivenessStep>[];
    if (stepsFromConfig.isNotEmpty) {
      return stepsFromConfig;
    }

    final stepsFromKeys =
        config?.faceLiveStep
            ?.map((key) => _FaceLivenessStep.fromBackend(key: key))
            .whereType<_FaceLivenessStep>()
            .toList() ??
        <_FaceLivenessStep>[];
    if (stepsFromKeys.isNotEmpty) {
      return stepsFromKeys;
    }

    return const [
      _FaceLivenessStep(
        action: _FaceAction.lookStraight,
        description: 'Please look straight at the camera',
      ),
      _FaceLivenessStep(
        action: _FaceAction.turnLeft,
        description: 'Please turn your head left',
      ),
      _FaceLivenessStep(
        action: _FaceAction.turnRight,
        description: 'Please turn your head right',
      ),
      _FaceLivenessStep(
        action: _FaceAction.blink,
        description: 'Please blink your eyes',
      ),
    ];
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      _cameraError = '暂不支持 Web 端活体识别，请使用 Android 真机测试';
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
      _cameraError = '未找到可用相机';
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
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted ||
        _isProcessingImage ||
        _isUploading ||
        _hasCapturedFinalImage ||
        _cameraController == null) {
      return;
    }

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _isProcessingImage = true;
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted || faces.isEmpty) {
        _stableMatchCount = 0;
        _stableFrontCount = 0;
        _blinkClosedDetected = false;
        return;
      }

      final face = faces.first;
      if (faces.length != 1 || !_isFaceCentered(face)) {
        _stableMatchCount = 0;
        _stableFrontCount = 0;
        return;
      }

      if (!_allActionsCompleted) {
        final currentStep = _livenessSteps[_currentStepIndex];
        final matched = _matchesStep(face, currentStep);
        if (matched) {
          _stableMatchCount += 1;
          if (_stableMatchCount >= 3) {
            _completeCurrentStep();
          }
        } else {
          _stableMatchCount = 0;
        }
        return;
      }

      if (_isFrontalFace(face)) {
        _stableFrontCount += 1;
        if (_stableFrontCount >= 4) {
          await _captureFinalFacePhoto();
        }
      } else {
        _stableFrontCount = 0;
        if (_hintText != 'Please look straight at the camera') {
          setState(() => _hintText = 'Please look straight at the camera');
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

  bool _matchesStep(Face face, _FaceLivenessStep step) {
    switch (step.action) {
      case _FaceAction.lookStraight:
        return _isFrontalFace(face);
      case _FaceAction.turnLeft:
        return (face.headEulerAngleY ?? 0) > 12;
      case _FaceAction.turnRight:
        return (face.headEulerAngleY ?? 0) < -12;
      case _FaceAction.lookUp:
        return (face.headEulerAngleX ?? 0) > 10;
      case _FaceAction.lookDown:
        return (face.headEulerAngleX ?? 0) < -10;
      case _FaceAction.blink:
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
      case _FaceAction.smile:
        return (face.smilingProbability ?? 0) > 0.2;
    }
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
      _stableMatchCount = 0;
      _blinkClosedDetected = false;
      _hintText = _currentStepIndex < _livenessSteps.length
          ? _livenessSteps[_currentStepIndex].description
          : 'Please look straight at the camera';
    });
  }

  Future<void> _captureFinalFacePhoto() async {
    if (_hasCapturedFinalImage || _isUploading) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _hasCapturedFinalImage = true;
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

      if (uploadResult.isSuccess) {
        setState(() {
          _faceImageUrl = uploadResult.data;
          _hintText = 'Face capture completed';
        });
      } else {
        _hasCapturedFinalImage = false;
        setState(() {
          _hintText = uploadResult.message ?? '上传失败，请重试';
        });
      }
    } catch (e) {
      _hasCapturedFinalImage = false;
      if (mounted) {
        setState(() => _hintText = '拍照失败，请重试');
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

  Future<void> _retakeFace() async {
    final controller = _cameraController;
    if (controller == null) return;

    setState(() {
      _faceImage = null;
      _faceImageUrl = null;
      _hasCapturedFinalImage = false;
      _stableFrontCount = 0;
      _hintText = 'Please look straight at the camera';
    });

    if (!controller.value.isStreamingImages) {
      await controller.startImageStream(_processCameraImage);
    }
  }

  Future<void> _onContinue() async {
    if (!_canContinue ||
        _isSubmitting ||
        _stepInfo == null ||
        _processId == null) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      String? key;
      for (final entry in _stepInfo!.entries) {
        final text = '${entry.showContent} ${entry.defaultText}'.toLowerCase();
        if (text.contains('face')) {
          key = entry.key;
          break;
        }
      }
      key ??= _stepInfo!.entries.isNotEmpty
          ? _stepInfo!.entries.first.key
          : null;
      if (key == null) {
        throw Exception('face verify field missing');
      }

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: [
              {'key': key, 'value': _faceImageUrl!},
            ],
          );

      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeShell()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '提交失败')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('提交失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          buildInformationHeader(
            context: context,
            title: '人脸验证',
            activeStep: InformationStep.face,
            onBack: () => FundingLimitDialog.showRetainDialog(context),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 18),
                          Expanded(child: _buildCameraArea()),
                          const SizedBox(height: 18),
                          _buildStepList(),
                        ],
                      ),
                    ),
            ),
          ),
          BottomContinueButton(
            isEnabled: _canContinue && !_isSubmitting && !_isUploading,
            onTap: _onContinue,
            text: _isSubmitting ? '保存中...' : '继续',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4EEE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liveness Detection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hintText ?? 'Please face the camera',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
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

        final maxPreviewWidth = constraints.maxWidth.clamp(0.0, 320.0);
        final maxPreviewHeight = constraints.maxHeight;

        if (_faceImage != null) {
          const actionAreaHeight = 54.0;
          const spacing = 14.0;
          final availableImageHeight =
              (maxPreviewHeight - actionAreaHeight - spacing).clamp(
                120.0,
                maxPreviewHeight,
              );
          final previewWidth = (availableImageHeight * 3 / 4).clamp(
            0.0,
            maxPreviewWidth,
          );

          return Center(
            child: SizedBox(
              width: previewWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFCCE7DE),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: MemoryImage(_faceImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _isUploading ? null : _retakeFace,
                    child: const Text('重新拍摄'),
                  ),
                ],
              ),
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
        final previewWidth = (maxPreviewHeight * 3 / 4).clamp(
          0.0,
          maxPreviewWidth,
        );

        return Center(
          child: SizedBox(
            width: previewWidth,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
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
                    Container(color: Colors.black.withValues(alpha: 0.08)),
                    Center(
                      child: Container(
                        width: previewWidth * 0.72,
                        height: previewWidth * 0.72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 20,
                              spreadRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isUploading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepList() {
    if (_livenessSteps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var index = 0; index < _livenessSteps.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == _livenessSteps.length - 1 ? 0 : 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: index < _currentStepIndex
                        ? const Color(0xFF0E8C6F)
                        : index == _currentStepIndex
                        ? const Color(0xFFDBF5EC)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: index < _currentStepIndex
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: index == _currentStepIndex
                                  ? const Color(0xFF0E8C6F)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _livenessSteps[index].description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: index == _currentStepIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: index <= _currentStepIndex
                          ? const Color(0xFF111827)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_allActionsCompleted && _faceImage == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              '动作已完成，请正视镜头，系统将自动抓拍正脸照片',
              style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ),
      ],
    );
  }
}

enum _FaceAction {
  lookStraight,
  turnLeft,
  turnRight,
  lookUp,
  lookDown,
  blink,
  smile,
}

class _FaceLivenessStep {
  final _FaceAction action;
  final String description;

  const _FaceLivenessStep({required this.action, required this.description});

  static _FaceLivenessStep? fromBackend({String? key, String? description}) {
    final normalizedKey = (key ?? '').trim();
    if (normalizedKey.isEmpty) return null;

    switch (normalizedKey) {
      case 'frontFaceStep':
        return _FaceLivenessStep(
          action: _FaceAction.lookStraight,
          description: description ?? 'Please look straight at the camera',
        );
      case 'smileStep':
        return _FaceLivenessStep(
          action: _FaceAction.smile,
          description: description ?? 'Please smile',
        );
      // todo: 上下点头，左右摇头，眨眼，正面，张嘴
    }

    AppLogger.debug('Unknown face liveness key from backend: $normalizedKey');
    return null;
  }
}
