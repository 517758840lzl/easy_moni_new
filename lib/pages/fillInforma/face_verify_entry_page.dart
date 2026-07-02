import 'dart:typed_data';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/models/face_verify_capture_result.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/mine/providers/user_info_provider.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 人脸认证入口页，负责展示本人确认说明并引导进入活体识别。
class FaceVerifyEntryPage extends ConsumerStatefulWidget {
  const FaceVerifyEntryPage({super.key});

  @override
  ConsumerState<FaceVerifyEntryPage> createState() =>
      _FaceVerifyEntryPageState();
}

class _FaceVerifyEntryPageState extends ConsumerState<FaceVerifyEntryPage> {
  static const double _headerTitleBarHeight = 44;
  static const double _headerTopGap = 16;
  static const double _stepIndicatorHeight = 80;
  static const double _headerBottomGap = 16;
  static const String _faceBiometricImageKey = 'face_biometric_image';

  StepInfo? _stepInfo;
  int? _processId;
  String _userName = '';
  Uint8List? _faceImage;
  String? _faceImageUrl;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isAwaitingFaceResult = false;

  String get _pageTitle => _stepInfo?.pageTitle.trim() ?? '';
  bool get _hasCapturedFace =>
      _faceImage != null && _faceImageUrl?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _fetchPageData();
  }

  /// 拉取当前人脸步骤配置和已确认的用户姓名。
  Future<void> _fetchPageData() async {
    try {
      final faceResult = await ref.read(acpElementInfoProvider).call(5);
      if (!mounted) return;

      if (faceResult.isSuccess && faceResult.data != null) {
        _processId = faceResult.data!.processId;
        final steps = faceResult.data!.stepInfoList;
        _stepInfo = steps.isNotEmpty ? steps.first : null;
      } else if (faceResult.message?.trim().isNotEmpty == true) {
        _showSnackBar(faceResult.message!);
      }

      // 从用户信息接口获取已确认的客户姓名
      final userInfoResult = await ref.read(userInfoProvider).call();
      if (!mounted) return;

      if (userInfoResult.isSuccess && userInfoResult.data != null) {
        _userName = userInfoResult.data!.customerName ?? '';
      } else if (userInfoResult.message?.trim().isNotEmpty == true) {
        _showSnackBar(userInfoResult.message!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onContinue() async {
    if (_isLoading || _isAwaitingFaceResult) return;

    setState(() => _isAwaitingFaceResult = true);

    FaceVerifyCaptureResult? captureResult;
    try {
      captureResult = await context.push<FaceVerifyCaptureResult>(
        AppRoutePaths.faceVerifyCapture,
      );
    } finally {
      if (mounted) {
        setState(() {
          if (captureResult != null) {
            _faceImage = captureResult.imageBytes;
            _faceImageUrl = captureResult.imageUrl;
          }
          _isAwaitingFaceResult = false;
        });
      }
    }
  }

  Future<void> _onRetake() async {
    await _onContinue();
  }

  Future<void> _onConfirmPhoto() async {
    if (!_hasCapturedFace) {
      _showSnackBar(AppStrings.faceVerifyEntryNoPhoto);
      return;
    }

    if (_isSubmitting || _stepInfo == null || _processId == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: [
              {'key': _faceBiometricImageKey, 'value': _faceImageUrl!},
            ],
          );

      if (!mounted) return;
      if (result.isSuccess) {
        final submitData = result.data;
        if (submitData == null) {
          _showSnackBar(result.message ?? AppStrings.errorMessage);
          return;
        }

        final route = AcquisitionProgressRouteResolver.resolveSubmitResult(
          submitData,
        );
        context.go(route);
      } else {
        _showSnackBar(result.message ?? AppStrings.faceVerifySubmitFailed);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('${AppStrings.faceVerifySubmitFailed}: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 计算白色内容区起点
  double _contentTop(BuildContext context) {
    return MediaQuery.of(context).padding.top +
        _headerTitleBarHeight +
        _headerTopGap +
        _stepIndicatorHeight +
        _headerBottomGap;
  }

  @override
  Widget build(BuildContext context) {
    return FundingLimitPopScope(
      child: LoanRoundedPageShell(
        contentTop: _contentTop,
        contentTopRadius: 12,
        backgroundColor: AppColors.primaryDark,
        header: buildInformationHeader(
          context: context,
          title: _pageTitle,
          activeStep: InformationStep.face,
          onBack: () => FundingLimitDialog.showRetainDialog(context),
        ),
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _buildContent(),
                  if (_isAwaitingFaceResult)
                    const _FaceVerifyResultLoadingOverlay(),
                ],
              ),
        bottomNavigationBar: _hasCapturedFace
            ? _FacePhotoActionBar(
                enabled:
                    !_isLoading && !_isSubmitting && !_isAwaitingFaceResult,
                isSubmitting: _isSubmitting,
                onRetake: _onRetake,
                onConfirm: _onConfirmPhoto,
              )
            : LoanBottomActionButton(
                enabled: !_isLoading && !_isAwaitingFaceResult,
                onPressed: (_isLoading || _isAwaitingFaceResult)
                    ? null
                    : _onContinue,
                text: AppStrings.faceVerifyEntryContinue,
                fontWeight: FontWeight.w600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topSpace = (constraints.maxHeight * 0.14)
            .clamp(48.0, 73.0)
            .toDouble();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - topSpace - 24,
            ),
            child: Column(
              children: [
                if (_hasCapturedFace) ...[
                  const _FacePhotoConfirmTip(),
                  const SizedBox(height: 20),
                ],
                _FaceScanIllustration(faceImage: _faceImage),
                const SizedBox(height: 24),
                if (_hasCapturedFace)
                  _buildPhotoQualityPrompt()
                else ...[
                  Text(
                    AppStrings.faceVerifyEntryOwnerConfirm(_userName),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1B222A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    AppStrings.continueOcr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3F4950),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 照片回显后的审核风险提示。
  Widget _buildPhotoQualityPrompt() {
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
              const Flexible(
                child: Text(
                  AppStrings.faceVerifyEntryPhotoBlurRisk,
                  textAlign: TextAlign.left,
                  style: TextStyle(
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
}

/// 人脸检测页返回入口页时展示的临时等待层，避免回显结果前页面看起来无响应。
class _FaceVerifyResultLoadingOverlay extends StatelessWidget {
  const _FaceVerifyResultLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.82),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF216A4A)),
              SizedBox(height: 14),
              Text(
                AppStrings.faceVerifyEntryResultLoading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3F4950),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 照片回显后的顶部确认提示，提醒用户检查照片清晰度。
class _FacePhotoConfirmTip extends StatelessWidget {
  const _FacePhotoConfirmTip();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.images.inforamtionIdcard.image(width: 36, height: 28),
        const SizedBox(height: 12),
        const Text(
          AppStrings.faceVerifyEntryPhotoConfirmTip,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1B222A),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// 人脸扫描插画
class _FaceScanIllustration extends StatelessWidget {
  const _FaceScanIllustration({this.faceImage});

  final Uint8List? faceImage;

  @override
  Widget build(BuildContext context) {
    final image = faceImage;
    if (image != null) {
      return SizedBox(
        width: 248,
        height: 248,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(image, fit: BoxFit.cover),
              ),
            ),
            Assets.images.faceVerifyRectangle.image(fit: BoxFit.contain),
          ],
        ),
      );
    }

    return SizedBox(
      width: 202,
      height: 202,
      child: Assets.images.informationIcon.image(fit: BoxFit.contain),
    );
  }
}

/// 照片回显态底部操作区，提供重新拍摄和确认完成两个动作。
class _FacePhotoActionBar extends StatelessWidget {
  const _FacePhotoActionBar({
    required this.enabled,
    required this.isSubmitting,
    required this.onRetake,
    required this.onConfirm,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: PermissionActionButtons(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          secondaryText: AppStrings.faceVerifyEntryRetake,
          primaryText: isSubmitting
              ? AppStrings.personalInfoSaving
              : AppStrings.faceVerifyEntryConfirmPhoto,
          onSecondaryPressed: enabled ? onRetake : null,
          onPrimaryPressed: enabled ? onConfirm : null,
        ),
      ),
    );
  }
}
