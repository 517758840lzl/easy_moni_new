import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/controllers/identity_verify_form_controller.dart';
import 'package:easy_moni/pages/fillInforma/id_camera_page.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/date_picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/identity_verify_widgets.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_rounded_page.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/camera_permission_sheet.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
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
  static const double _headerTitleBarHeight = 44;
  static const double _headerTopGap = 16;
  static const double _stepIndicatorHeight = 80;
  static const double _headerBottomGap = 16;
  static const String _frontOcrType = 'FRONT';
  static const String _backOcrType = 'BACK';

  final IdentityVerifyFormController _formController =
      IdentityVerifyFormController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _entryItemKeys = {};

  StepInfo? _stepInfo;
  int? _processId;
  String? _frontImageUrl;
  String? _backImageUrl;
  Uint8List? _frontPreviewImageData;
  Uint8List? _backPreviewImageData;
  String? _frontUploadError;
  String? _backUploadError;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isOcrLoading = false;
  bool _isFrontImageProcessing = false;
  bool _isBackImageProcessing = false;
  String? _emphasizedEntryKey;

  bool get _canContinue {
    final requiredSides = _formController.requiredIdCardImageSides;
    if (requiredSides.isEmpty) {
      return _frontImageUrl != null && _backImageUrl != null;
    }
    return requiredSides.every(_isImageSideReady);
  }

  bool get _shouldShowIdentityForm => _hasUploadedImageUrl(_frontImageUrl);

  bool get _isFormComplete => _formController.areRequiredVisibleEntriesFilled;

  String get _pageTitle {
    final pageTitle = _stepInfo?.pageTitle.trim() ?? '';
    return pageTitle.isNotEmpty ? pageTitle : AppStrings.idcardVer;
  }

  bool get _isActionEnabled {
    return _canContinue &&
        _isFormComplete &&
        !_isSubmitting &&
        !_isOcrLoading &&
        !_isFrontImageProcessing &&
        !_isBackImageProcessing;
  }

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        CommonBottomSheetAction<bool>(text: AppStrings.confirm, result: true),
      ],
    );

    if (confirmed == true) {
      await _submitIdentityInfo();
      return;
    }

    if (confirmed == false) {
      final entry = _formController.recognizedIdNumberEntry;
      if (entry != null) {
        await _focusAndEmphasizeEntry(entry);
      }
    }
  }

  Future<void> _focusAndEmphasizeEntry(FormEntry entry) async {
    setState(() => _emphasizedEntryKey = entry.key);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    final itemContext = _entryItemKeys[entry.key]?.currentContext;
    if (itemContext != null && itemContext.mounted) {
      await Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }

    if (!mounted) {
      return;
    }

    final focusNode = _formController.focusNodeFor(entry);
    if (!mounted) {
      return;
    }
    focusNode.requestFocus();
  }

  GlobalKey _entryItemKeyFor(FormEntry entry) {
    return _entryItemKeys.putIfAbsent(entry.key, GlobalKey.new);
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

  /// 身份证区域点击入口：授权通过后让用户选择拍照或相册上传。
  Future<void> _openUploadMethodSheet({required FormEntry entry}) async {
    bool? shouldPickFromGallery;
    await UploadMethodSheet.show(
      context: context,
      options: entry.selectList,
      onPickFromGallery: () => shouldPickFromGallery = true,
      onTakePhoto: () => shouldPickFromGallery = false,
    );
    if (!mounted || shouldPickFromGallery == null) {
      return;
    }

    final isFront = !_formController.isBackImageEntry(entry);
    if (shouldPickFromGallery == true) {
      await _pickFromGallery(isFront: isFront);
      return;
    }

    await _takePhoto(isFront: isFront);
  }

  Future<void> _takePhoto({required bool isFront}) async {
    final canOpenCamera = await _ensureCameraPermission();
    if (!mounted || !canOpenCamera) {
      return;
    }

    final capturedImages = await _captureIdCardImages(startWithFront: isFront);
    if (!mounted) return;

    if (!capturedImages.hasAnyImage) {
      return;
    }

    await _onImagesCaptured(capturedImages);
  }

  /// 从系统相册读取用户选择的身份证图片，并按点击的证件面进入上传流程。
  Future<void> _pickFromGallery({required bool isFront}) async {
    Uint8List? imageData;
    try {
      imageData = await CameraService.pickFromGallery();
    } catch (e) {
      return;
    }
    if (!mounted) {
      return;
    }

    if (imageData == null) {
      _showSnackBar(AppStrings.identityVerifyImageNotSelected);
      return;
    }

    await _onImagesCaptured(
      _CapturedIdCardImages(
        frontImageData: isFront ? imageData : null,
        backImageData: isFront ? null : imageData,
      ),
    );
  }

  /// 按用户点击的证件面开始拍照，若另一面缺失则在同一相机页补拍另一面。
  Future<_CapturedIdCardImages> _captureIdCardImages({
    required bool startWithFront,
  }) async {
    final shouldCaptureOpposite = startWithFront
        ? !_hasUploadedImageUrl(_backImageUrl)
        : !_hasUploadedImageUrl(_frontImageUrl);

    final captureResult = await _captureIdCardImage(
      isFront: startWithFront,
      captureOppositeSide: shouldCaptureOpposite,
    );
    if (!mounted || captureResult == null) {
      return const _CapturedIdCardImages();
    }

    return _CapturedIdCardImages(
      frontImageData: captureResult.frontImageData,
      backImageData: captureResult.backImageData,
    );
  }

  /// 打开横屏拍摄页，返回裁剪后的正反面图片数据。
  Future<IdCameraCaptureResult?> _captureIdCardImage({
    required bool isFront,
    bool captureOppositeSide = false,
    String? entryToastMessage,
  }) {
    return Navigator.of(context).push<IdCameraCaptureResult>(
      MaterialPageRoute(
        builder: (context) => IdCameraScreen(
          isFront: isFront,
          captureOppositeSide: captureOppositeSide,
          entryToastMessage: entryToastMessage,
        ),
      ),
    );
  }

  /// 拍摄入口统一处理相机权限，避免进入横屏拍摄页后再触发权限弹窗。
  Future<bool> _ensureCameraPermission() async {
    final granted = await CameraPermissionSheet.ensure(context);
    if (!mounted) return false;
    if (granted) {
      return true;
    }

    _showSnackBar(AppStrings.identityVerifyCameraPermissionDenied);
    return false;
  }

  Future<void> _onImagesCaptured(_CapturedIdCardImages capturedImages) async {
    final frontImageData = capturedImages.frontImageData;
    final backImageData = capturedImages.backImageData;

    setState(() {
      if (frontImageData != null) {
        _frontImageUrl = null;
        _frontPreviewImageData = null;
        _frontUploadError = null;
        _isFrontImageProcessing = true;
        _formController.clearOcrResult();
      }
      if (backImageData != null) {
        _backImageUrl = null;
        _backPreviewImageData = null;
        _backUploadError = null;
        _isBackImageProcessing = true;
      }
      _isOcrLoading = frontImageData != null;
    });

    // _showSnackBar(
    //   frontImageData != null
    //       ? AppStrings.continueIdentifyStr
    //       : AppStrings.continueUploadPicture,
    // );

    if (frontImageData != null && backImageData != null) {
      await Future.wait([
        _recognizeFrontImage(frontImageData),
        _recognizeBackImage(backImageData, shouldUpdateLoading: false),
      ]);
      return;
    }

    if (frontImageData != null) {
      await _recognizeFrontImage(frontImageData);
      return;
    }

    await _recognizeBackImage(backImageData!, shouldUpdateLoading: false);
  }

  /// 身份证反面同样调用 OCR 接口上传，后端通过 BACK 区分证件面，但不触发表单 OCR 加载态。
  Future<void> _recognizeBackImage(
    Uint8List imageData, {
    bool shouldUpdateLoading = true,
  }) async {
    final result = await ref
        .read(ocrVerificationProvider)
        .call(
          bytes: imageData,
          filename: 'id_card_back.jpg',
          type: _backOcrType,
        );

    if (!mounted) return;

    final recognizedUrl = _uploadedImageUrlFromOcrResult(result.data);
    setState(() {
      if (result.isSuccess && recognizedUrl != null) {
        _backImageUrl = recognizedUrl;
        _backPreviewImageData = result.data?.uploadBytes ?? imageData;
        _backUploadError = null;
      } else {
        _backImageUrl = null;
        _backPreviewImageData = null;
        _backUploadError = result.message ?? AppStrings.identityVerifyOcrFailed;
      }
      _isBackImageProcessing = false;
      if (shouldUpdateLoading) {
        _isOcrLoading = false;
      }
    });

    _showSnackBar(
      result.isSuccess && recognizedUrl != null
          ? AppStrings.identityVerifyBackUploadSuccess
          : result.message ?? AppStrings.identityVerifyOcrFailed,
    );
  }

  Future<void> _recognizeFrontImage(
    Uint8List imageData, {
    bool shouldUpdateLoading = true,
  }) async {
    final result = await ref
        .read(ocrVerificationProvider)
        .call(
          bytes: imageData,
          filename: 'id_card_front.jpg',
          type: _frontOcrType,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      final recognizedUrl = _uploadedImageUrlFromOcrResult(result.data);
      if (recognizedUrl != null) {
        final previewImageData = result.data?.uploadBytes ?? imageData;
        setState(() {
          _frontImageUrl = recognizedUrl;
          _frontPreviewImageData = previewImageData;
          _frontUploadError = null;
          _isFrontImageProcessing = false;
          _formController.applyOcrResult(result.data);
          if (shouldUpdateLoading) {
            _isOcrLoading = false;
          }
        });

        _showSnackBar(AppStrings.identityVerifyOcrSuccess);
        return;
      }
    }

    setState(() {
      _frontImageUrl = null;
      _frontPreviewImageData = null;
      _frontUploadError = result.message ?? AppStrings.identityVerifyOcrFailed;
      _isFrontImageProcessing = false;
      if (shouldUpdateLoading) {
        _isOcrLoading = false;
      }
    });

    _showSnackBar(result.message ?? AppStrings.identityVerifyOcrFailed);
  }

  /// OCR 接口在不同证件面可能返回 url/backUrl，这里统一取可提交图片地址。
  String? _uploadedImageUrlFromOcrResult(OcrVerificationResp? data) {
    final imageUrl = data?.url;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return imageUrl;
    }

    final backImageUrl = data?.backUrl;
    if (backImageUrl != null && backImageUrl.trim().isNotEmpty) {
      return backImageUrl;
    }
    return null;
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

    final pickedDate = await showDatePickerBottomSheet(
      context: context,
      title: AppStrings.identityVerifyBirthdayPickerTitle,
      initialDate: initialDate,
      minimumDate: firstDate,
      maximumDate: now,
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

  bool _isImageSideReady(String side) {
    if (side == IdentityImageSide.front) {
      return _hasUploadedImageUrl(_frontImageUrl);
    }
    if (side == IdentityImageSide.back) {
      return _hasUploadedImageUrl(_backImageUrl);
    }
    return false;
  }

  Uint8List? _imageDataForEntry(FormEntry entry) {
    if (_formController.isBackImageEntry(entry)) {
      return _backPreviewImageData;
    }
    return _frontPreviewImageData;
  }

  bool _isImageProcessingForEntry(FormEntry entry) {
    if (_formController.isBackImageEntry(entry)) {
      return _isBackImageProcessing;
    }
    return _isFrontImageProcessing;
  }

  String? _imageErrorForEntry(FormEntry entry) {
    if (_formController.isBackImageEntry(entry)) {
      return _backUploadError;
    }
    return _frontUploadError;
  }

  AssetGenImage _backgroundForImageEntry(FormEntry entry) {
    if (_imageDataForEntry(entry) != null ||
        _isImageProcessingForEntry(entry)) {
      return Assets.images.idCardRectangle;
    }
    if (_formController.isBackImageEntry(entry)) {
      return Assets.images.inforamtionIdo;
    }
    return Assets.images.inforamtionIdw;
  }

  bool _hasUploadedImageUrl(String? imageUrl) {
    return imageUrl != null && imageUrl.trim().isNotEmpty;
  }

  /// 计算白色内容区起点，与资料采集流程的进度头部保持一致。
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
      child: LoanRoundedPage(
        contentTop: _contentTop,
        contentTopRadius: 12,
        backgroundColor: AppColors.primaryDark,
        header: buildInformationHeader(
          context: context,
          title: _pageTitle,
          activeStep: InformationStep.identity,
          onBack: () => FundingLimitDialog.showRetainDialog(context),
        ),
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(8),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _clearFormTextFocus,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const IdentityCheckNotice(),
                      const SizedBox(height: 16),
                      ..._formController.idCardImageEntries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: IdCardUploadItem(
                            bgImage: _backgroundForImageEntry(entry),
                            imageData: _imageDataForEntry(entry),
                            isProcessing: _isImageProcessingForEntry(entry),
                            errorText: _imageErrorForEntry(entry),
                            onTap: () => _openUploadMethodSheet(entry: entry),
                          ),
                        ),
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
                            key: _entryItemKeyFor(entry),
                            entry: entry,
                            formController: _formController,
                            emphasized: _emphasizedEntryKey == entry.key,
                            onTextChanged: (value) {
                              setState(() {
                                if (_emphasizedEntryKey == entry.key) {
                                  _emphasizedEntryKey = null;
                                }
                                _formController.updateTextValue(entry, value);
                              });
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
        bottomNavigationBar: LoanBottomActionButton(
          enabled: _isActionEnabled,
          onPressed: _isActionEnabled ? _onContinue : null,
          text: _isSubmitting
              ? AppStrings.personalInfoSaving
              : AppStrings.continueStr,
        ),
      ),
    );
  }
}

/// 本轮连续拍摄得到的身份证正反面图片。
class _CapturedIdCardImages {
  const _CapturedIdCardImages({this.frontImageData, this.backImageData});

  final Uint8List? frontImageData;
  final Uint8List? backImageData;

  bool get hasAnyImage => frontImageData != null || backImageData != null;
}

