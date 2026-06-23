import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/controllers/identity_verify_form_controller.dart';
import 'package:easy_moni/pages/fillInforma/id_camera_page.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/identity_verify_widgets.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class IdentityVerifyPage extends ConsumerStatefulWidget {
  const IdentityVerifyPage({super.key});

  @override
  ConsumerState<IdentityVerifyPage> createState() => _IdentityVerifyPageState();
}

class _IdentityVerifyPageState extends ConsumerState<IdentityVerifyPage> {
  final IdentityVerifyFormController _formController =
      IdentityVerifyFormController();

  StepInfo? _stepInfo;
  int? _processId;
  Uint8List? _idCardFrontData;
  Uint8List? _idCardBackData;
  String? _frontImageUrl;
  String? _backImageUrl;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isOcrLoading = false;

  bool get _canContinue =>
      _idCardFrontData != null &&
      _idCardBackData != null &&
      _frontImageUrl != null &&
      _backImageUrl != null;

  bool get _shouldShowIdentityForm => _idCardFrontData != null;

  bool get _isFormComplete => _formController.areRequiredVisibleEntriesFilled;

  String get _pageTitle {
    final pageTitle = _stepInfo?.pageTitle.trim() ?? '';
    return pageTitle.isNotEmpty ? pageTitle : AppStrings.idcardVer;
  }

  bool get _isActionEnabled {
    return _canContinue && _isFormComplete && !_isSubmitting && !_isOcrLoading;
  }

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _fetchStepInfo() async {
    try {
      final result = await ref.read(acpElementInfoProvider).call(4);
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        _processId = result.data!.processId;
        _stepInfo = result.data!.stepInfoList.firstOrNull;
        _formController.applyEntries(_stepInfo?.entries ?? []);
      } else {
        _showSnackBar(result.message ?? AppStrings.errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onContinue() async {
    if (!_isActionEnabled) {
      return;
    }

    if (_stepInfo == null || _processId == null) {
      return;
    }

    await _showConfirmIdNumberSheet();
  }

  Future<void> _showConfirmIdNumberSheet() async {
    final idNumber = _formController.recognizedIdNumber;
    if (idNumber.isEmpty) {
      _showSnackBar(AppStrings.identityVerifyConfirmRequired);
      return;
    }

    final confirmed = await CommonBottomSheet.show<bool>(
      context: context,
      title: idNumber,
      description: AppStrings.identityVerifyConfirmIdNumber,
      image: Assets.images.inforamtionWarn.image(width: 123, height: 123),
      actions: const [
        CommonBottomSheetAction<bool>(
          text: AppStrings.identityVerifyEdit,
          result: false,
          isPrimary: false,
        ),
        CommonBottomSheetAction<bool>(
          text: AppStrings.personalInfoPickerConfirm,
          result: true,
        ),
      ],
    );

    if (confirmed == true) {
      await _submitIdentityInfo();
    }
  }

  Future<void> _submitIdentityInfo() async {
    if (!_canContinue ||
        _isSubmitting ||
        _stepInfo == null ||
        _processId == null) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final jsonParam = _formController.buildSubmitParams(
        frontImageUrl: _frontImageUrl,
        backImageUrl: _backImageUrl,
      );

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
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
        if (route == AppRoutePaths.home) {
          context.go(route);
        } else {
          context.push(route);
        }
      } else {
        _showSnackBar(result.message ?? AppStrings.identityVerifySaveFailed);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('${AppStrings.identityVerifySaveFailed}: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showUploadOptions({required bool isFront}) {
    UploadMethodSheet.show(
      context: context,
      onPickFromGallery: () => _pickFromGallery(isFront: isFront),
      onTakePhoto: () => _takePhoto(isFront: isFront),
    );
  }

  Future<void> _pickFromGallery({required bool isFront}) async {
    AppLogger.debug('开始选择身份证图片, isFront=$isFront, isWeb=$kIsWeb');
    final imageData = await CameraService.pickFromGallery();
    if (!mounted) return;

    if (imageData == null) {
      AppLogger.debug('未拿到图片数据, isFront=$isFront');
      _showSnackBar(AppStrings.identityVerifyImageNotSelected);
      return;
    }

    AppLogger.debug('已拿到图片数据, bytes=${imageData.length}, isFront=$isFront');
    await _onImageSelected(imageData, isFront: isFront);
  }

  Future<void> _takePhoto({required bool isFront}) async {
    final canOpenCamera = await _ensureCameraPermission();
    if (!mounted || !canOpenCamera) {
      return;
    }

    final imageData = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (context) => IdCameraScreen(isFront: isFront)),
    );
    if (!mounted) return;

    if (imageData == null) {
      _showSnackBar(AppStrings.identityVerifyImageNotCaptured);
      return;
    }

    await _onImageSelected(imageData, isFront: isFront);
  }

  /// 拍摄入口统一处理相机权限，避免进入横屏拍摄页后再触发权限弹窗。
  Future<bool> _ensureCameraPermission() async {
    final hasPermission = await CameraService.checkPermission();
    if (!mounted) return false;

    if (hasPermission) {
      return true;
    }

    final shouldRequestPermission = await _showCameraPermissionSheet();
    if (!mounted || !shouldRequestPermission) {
      return false;
    }

    // final granted = await CameraService.requestPermission();
    // if (!mounted) return false;

    // if (granted) {
    //   return true;
    // }

    await CameraService.openAppSettings();
    if (!mounted) return false;

    _showSnackBar(AppStrings.identityVerifyCameraPermissionDenied);
    return false;
  }

  Future<bool> _showCameraPermissionSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.paddingOf(context).bottom;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Material(
            color: const Color(0xFFFDFEFF),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.images.permissionCamera3d.image(
                            width: 115,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.needsCamera,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101314),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.idcardMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3F4950),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: PermissionActionButtons(
                          secondaryText: AppStrings.cancel,
                          primaryText: AppStrings.goSettings,
                          onSecondaryPressed: () =>
                              Navigator.of(context).pop(false),
                          onPrimaryPressed: () =>
                              Navigator.of(context).pop(true),
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(child: _CameraPermissionDragHandle()),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _onImageSelected(
    Uint8List imageData, {
    required bool isFront,
  }) async {
    AppLogger.debug('准备处理身份证图片, isFront=$isFront, bytes=${imageData.length}');
    setState(() {
      if (isFront) {
        _idCardFrontData = imageData;
        _frontImageUrl = null;
      } else {
        _idCardBackData = imageData;
        _backImageUrl = null;
      }
      _isOcrLoading = true;
    });

    _showSnackBar(
      isFront
          ? AppStrings.continueIdentifyStr
          : AppStrings.continueUploadPicture,
    );

    if (isFront) {
      await _recognizeFrontImage(imageData);
    } else {
      await _uploadBackImage(imageData);
    }
  }

  Future<void> _uploadBackImage(Uint8List imageData) async {
    final uploadResult = await ref
        .read(uploadFileProvider)
        .call(bytes: imageData, filename: 'id_card_back.jpg');

    if (!mounted) return;

    setState(() {
      if (uploadResult.isSuccess) {
        _backImageUrl = uploadResult.data;
      }
      _isOcrLoading = false;
    });

    _showSnackBar(
      uploadResult.isSuccess
          ? AppStrings.identityVerifyBackUploadSuccess
          : uploadResult.message ?? AppStrings.identityVerifyUploadFailed,
    );
  }

  Future<void> _recognizeFrontImage(Uint8List imageData) async {
    final result = await ref
        .read(ocrVerificationProvider)
        .call(bytes: imageData, filename: 'id_card_front.jpg', type: 'FRONT');

    AppLogger.debug(
      'OCR 接口返回: isSuccess=${result.isSuccess}, message=${result.message}, data=${result.data}',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final recognizedUrl = result.data?.url;
      if (recognizedUrl == null || recognizedUrl.isEmpty) {
        await _uploadFrontImageAfterOcrFailed(
          imageData,
          fallbackMessage: AppStrings.identityVerifyUploadFailed,
        );
        return;
      }

      setState(() {
        _frontImageUrl = recognizedUrl;
        _formController.applyOcrResult(result.data);
        _isOcrLoading = false;
      });

      _showSnackBar(AppStrings.identityVerifyOcrSuccess);
      return;
    }

    await _uploadFrontImageAfterOcrFailed(
      imageData,
      fallbackMessage: result.message ?? AppStrings.identityVerifyOcrFailed,
    );
  }

  /// OCR 失败时仍上传身份证正面图片，保留手动填写与后续提交能力。
  Future<void> _uploadFrontImageAfterOcrFailed(
    Uint8List imageData, {
    required String fallbackMessage,
  }) async {
    final uploadResult = await ref
        .read(uploadFileProvider)
        .call(bytes: imageData, filename: 'id_card_front.jpg');

    if (!mounted) return;

    setState(() {
      if (uploadResult.isSuccess) {
        _frontImageUrl = uploadResult.data;
      }
      _isOcrLoading = false;
    });

    _showSnackBar(
      uploadResult.isSuccess
          ? fallbackMessage
          : uploadResult.message ?? AppStrings.identityVerifyUploadFailed,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPickerForEntry(FormEntry entry) async {
    final options = entry.selectList;
    if (options == null || options.isEmpty) {
      return;
    }

    await _focusPickerEntry(entry);
    if (!mounted) {
      return;
    }
    var isConfirmed = false;
    await PickerBottomSheet.show(
      context: context,
      title: entry.showContent,
      options: options
          .map((item) => PickerBottomSheetOption(label: item.value))
          .toList(),
      selectedIndex: _formController.selectedIndexFor(entry),
      onConfirm: (index) {
        isConfirmed = true;
        setState(() => _formController.updatePickerValue(entry, index));
      },
    );
    if (!mounted || !isConfirmed) {
      return;
    }

    await _focusNextVisibleEntryAfter(entry);
  }

  Future<void> _openBirthdayPickerForEntry(FormEntry entry) async {
    await _focusPickerEntry(entry);
    if (!mounted) {
      return;
    }
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100, now.month, now.day);
    final selectedDate = _formController.dateValueFor(entry);
    final initialDate = _safeInitialBirthdayDate(
      selectedDate: selectedDate,
      firstDate: firstDate,
      lastDate: now,
    );

    // 生日字段由系统日期选择器录入，避免用户手输造成日期格式不统一。
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: entry.showContent,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.personalInfoPickerConfirm,
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() => _formController.updateBirthdayValue(entry, pickedDate));
    await _focusNextVisibleEntryAfter(entry);
  }

  /// 选择类字段确认后按后端表单顺序推进，保证性别后优先进入生日选择器。
  Future<void> _focusNextVisibleEntryAfter(FormEntry entry) async {
    final nextEntry = _formController.nextVisibleEntryAfter(entry);
    if (nextEntry == null) {
      await _clearFormTextFocus();
      return;
    }

    if (_formController.isTextEntry(nextEntry)) {
      FocusScope.of(
        context,
      ).requestFocus(_formController.focusNodeFor(nextEntry));
      return;
    }

    await _focusPickerEntry(nextEntry);
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_formController.isBirthdayPickerEntry(nextEntry)) {
        _openBirthdayPickerForEntry(nextEntry);
        return;
      }
      _openPickerForEntry(nextEntry);
    });
  }

  /// 将选择类表单项纳入页面焦点链，并在打开弹窗前稳定收起系统键盘。
  Future<void> _focusPickerEntry(FormEntry entry) async {
    FocusScope.of(context).requestFocus(_formController.focusNodeFor(entry));
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  /// 彻底释放页面文本焦点并收起系统键盘，避免弹窗切换时与日期选择器重叠。
  Future<void> _clearFormTextFocus() async {
    FocusManager.instance.primaryFocus?.unfocus(
      disposition: UnfocusDisposition.scope,
    );
    _formController.unfocusTextInputs();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  DateTime _safeInitialBirthdayDate({
    required DateTime? selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    if (selectedDate == null) {
      return DateTime(lastDate.year - 18, lastDate.month, lastDate.day);
    }
    if (selectedDate.isBefore(firstDate)) {
      return firstDate;
    }
    if (selectedDate.isAfter(lastDate)) {
      return lastDate;
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          buildInformationHeader(
            context: context,
            title: _pageTitle,
            activeStep: InformationStep.identity,
            onBack: () => FundingLimitDialog.showRetainDialog(context),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                color: Colors.white,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            const IdentityCheckNotice(),
                            const SizedBox(height: 16),
                            IdCardUploadItem(
                              bgImage: _idCardFrontData == null
                                  ? Assets.images.inforamtionIdw
                                  : Assets.images.idCardRectangle,
                              imageData: _idCardFrontData,
                              onTap: () => _showUploadOptions(isFront: true),
                            ),
                            const SizedBox(height: 16),
                            IdCardUploadItem(
                              bgImage: _idCardBackData == null
                                  ? Assets.images.inforamtionIdo
                                  : Assets.images.idCardRectangle,
                              imageData: _idCardBackData,
                              onTap: () => _showUploadOptions(isFront: false),
                            ),
                            if (_isOcrLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(),
                              ),
                            if (_shouldShowIdentityForm) ...[
                              const SizedBox(height: 8),
                              ..._formController.visibleEntries.map(
                                (entry) => IdentityFormEntryItem(
                                  entry: entry,
                                  formController: _formController,
                                  onTextChanged: (value) {
                                    setState(
                                      () => _formController.updateTextValue(
                                        entry,
                                        value,
                                      ),
                                    );
                                  },
                                  onTextSubmitted: (entry) =>
                                      _focusNextVisibleEntryAfter(entry),
                                  onPickerTap: _openPickerForEntry,
                                  onDatePickerTap: _openBirthdayPickerForEntry,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          LoanBottomActionButton(
            enabled: _isActionEnabled,
            onPressed: _isActionEnabled ? _onContinue : null,
            text: _isSubmitting
                ? AppStrings.personalInfoSaving
                : AppStrings.continueStr,
          ),
        ],
      ),
    );
  }
}

/// 相机权限说明弹窗的顶部拖拽提示条。
class _CameraPermissionDragHandle extends StatelessWidget {
  const _CameraPermissionDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
