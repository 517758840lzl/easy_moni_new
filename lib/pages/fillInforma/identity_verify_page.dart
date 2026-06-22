import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/id_camera_page.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

import '../../gen/assets.gen.dart';
import '../../services/platform_service.dart';
import '../../utils/widgets/informationBottomButton.dart';
import '../../utils/widgets/limit_toast.dart';

class IdentityVerifyPage extends ConsumerStatefulWidget {
  const IdentityVerifyPage({super.key});

  @override
  ConsumerState<IdentityVerifyPage> createState() => _IdentityVerifyPageState();
}

class _IdentityVerifyPageState extends ConsumerState<IdentityVerifyPage> {
  StepInfo? _stepInfo;
  int? _processId;
  Uint8List? _idCardFrontData;
  Uint8List? _idCardBackData;
  OcrVerificationResp? _frontOcr;
  String? _backImageUrl;
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNamesController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  String? _genderSubmitValue;
  String? _birthdaySubmitValue;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isOcrLoading = false;

  bool get _canContinue =>
      _idCardFrontData != null &&
      _idCardBackData != null &&
      _frontOcr?.url != null &&
      _backImageUrl != null;

  bool get _allowContinueForFaceTest => true;

  bool get _hasRecognizedIdentityInfo =>
      (_frontOcr?.idCardNumber?.isNotEmpty ?? false) ||
      (_frontOcr?.lastName?.isNotEmpty ?? false) ||
      (_frontOcr?.firstNames?.isNotEmpty ?? false) ||
      (_frontOcr?.gender?.isNotEmpty ?? false) ||
      (_frontOcr?.birthday?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _lastNameController.dispose();
    _firstNamesController.dispose();
    _genderController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _fetchStepInfo() async {
    try {
      final result = await ref.read(acpElementInfoProvider).call(4);
      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        _processId = result.data!.processId;
        _stepInfo = result.data!.stepInfoList.isNotEmpty
            ? result.data!.stepInfoList.first
            : null;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '加载失败')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onContinue() async {
    if (_isSubmitting || _isOcrLoading) {
      return;
    }

    if (!_canContinue) {
      if (!_allowContinueForFaceTest) {
        return;
      }
      context.push(AppRoutePaths.faceVerify);
      return;
    }

    if (_stepInfo == null || _processId == null) {
      return;
    }

    await _showConfirmIdNumberSheet();
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
      final jsonParam = <Map<String, dynamic>>[];

      for (final entry in _stepInfo!.entries) {
        final value = _identitySubmitValueForEntry(entry);
        if (value != null && value.isNotEmpty) {
          jsonParam.add({'key': entry.key, 'value': value});
        }
      }

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;
      if (result.isSuccess) {
        context.push(AppRoutePaths.faceVerify);
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

  String _entryIdentityText(FormEntry entry) {
    return '${entry.key} ${entry.code} ${entry.showContent} ${entry.defaultText}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  bool _hasIdentityToken(String text, String token) {
    return text == token ||
        text.startsWith('${token}_') ||
        text.endsWith('_$token') ||
        text.contains('_${token}_');
  }

  String? _identitySubmitValueForEntry(FormEntry entry) {
    final text = _entryIdentityText(entry);
    final keyText = entry.key.toLowerCase();

    if (text.contains('id_card_front') ||
        (text.contains('front') &&
            (text.contains('image') || text.contains('photo')))) {
      return _frontOcr?.url;
    }
    if (text.contains('id_card_back') ||
        (text.contains('back') &&
            (text.contains('image') || text.contains('photo')))) {
      return _backImageUrl;
    }
    if (text.contains('national_id') ||
        text.contains('id_number') ||
        text.contains('id_card_number')) {
      return _idNumberController.text.trim();
    }
    if (keyText == 'first_names' ||
        keyText == 'first_name' ||
        text.contains('first_name') ||
        text.contains('given_name') ||
        text.contains('forename') ||
        text.contains('father')) {
      return _firstNamesController.text.trim();
    }
    if (keyText == 'last_name' ||
        text.contains('last_name') ||
        text.contains('surname') ||
        text.contains('family_name')) {
      return _lastNameController.text.trim();
    }
    if (_hasIdentityToken(text, 'gender') || _hasIdentityToken(text, 'sex')) {
      return (_genderSubmitValue ?? _genderController.text).trim();
    }
    if (text.contains('date_of_birth') ||
        text.contains('birthday') ||
        _hasIdentityToken(text, 'birth')) {
      return (_birthdaySubmitValue ?? _birthdayController.text).trim();
    }
    return null;
  }

  Future<void> _showConfirmIdNumberSheet() async {
    final idNumber = _idNumberController.text.trim();
    if (idNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先确认身份证号码')));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0x1A27D3C3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 52,
                    color: Color(0xFF27B7A7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  idNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101314),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '请再次核对您的身份证号码',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF5B646B)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF268470)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Color(0xFF268470),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _submitIdentityInfo();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF268470),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _displayGender(String? value) {
    switch (value?.trim()) {
      case '1':
      case 'M':
      case 'Male':
        return 'Male';
      case '2':
      case 'F':
      case 'Female':
        return 'Female';
      default:
        return value ?? '';
    }
  }

  String _displayBirthday(String? value) {
    if (value == null || value.isEmpty) return '';
    final parts = value.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return value;
  }

  void _fillEditableFields(OcrVerificationResp? data) {
    _idNumberController.text = data?.idCardNumber ?? '';
    _lastNameController.text = data?.lastName ?? '';
    _firstNamesController.text = data?.firstNames ?? '';
    _genderSubmitValue = data?.gender;
    _birthdaySubmitValue = data?.birthday;
    _genderController.text = _displayGender(data?.gender);
    _birthdayController.text = _displayBirthday(data?.birthday);
  }

  void _showUploadOptions({required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFEFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final galleryText = AppStrings.selectFormPhotos;
        final cameraText = AppStrings.takephotos;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    AppStrings.chooseUploadMethod,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101314),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.checkIdCard,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3F4950),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _pickFromGallery(isFront: isFront);
                          },
                          child: _buildUploadOption(
                            icon: Assets.images.cameraM.image(
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                            text: galleryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto(isFront: isFront);
                          },
                          child: _buildUploadOption(
                            icon: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Assets.images.gallerySend.image(
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  top: -11,
                                  right: -11,
                                  child: Assets.images.inforamtionStar.image(
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            text: cameraText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        );
      },
    );
  }

  Widget _buildUploadOption({required Widget icon, required String text}) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery({required bool isFront}) async {
    AppLogger.debug('开始选择身份证图片, isFront=$isFront, isWeb=$kIsWeb');
    final imageData = await CameraService.pickFromGallery();
    if (!mounted) return;
    if (imageData != null) {
      AppLogger.debug('已拿到图片数据, bytes=${imageData.length}, isFront=$isFront');
      await _onImageSelected(imageData, isFront: isFront);
    } else {
      AppLogger.debug('未拿到图片数据, isFront=$isFront');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未选择图片')));
    }
  }

  Future<void> _takePhoto({required bool isFront}) async {
    final imageData = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (context) => IdCameraScreen(isFront: isFront)),
    );
    if (!mounted) return;
    if (imageData != null) {
      await _onImageSelected(imageData, isFront: isFront);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未获取到图片')));
    }
  }

  Future<void> _onImageSelected(
    Uint8List imageData, {
    required bool isFront,
  }) async {
    AppLogger.debug('准备处理身份证图片, isFront=$isFront, bytes=${imageData.length}');
    setState(() {
      if (isFront) {
        _idCardFrontData = imageData;
      } else {
        _idCardBackData = imageData;
      }
      _isOcrLoading = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFront
                ? AppStrings.continueIdentifyStr
                : AppStrings.continueUploadPicture,
          ),
        ),
      );
    }

    if (!isFront) {
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

      if (uploadResult.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('证件背面上传成功')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uploadResult.message ?? '图片上传失败')),
        );
      }
      return;
    }

    final result = await ref
        .read(ocrVerificationProvider)
        .call(bytes: imageData, filename: 'id_card_front.jpg', type: 'FRONT');

    AppLogger.debug(
      'OCR 接口返回: isSuccess=${result.isSuccess}, message=${result.message}, data=${result.data}',
    );

    if (!mounted) return;

    setState(() {
      if (result.isSuccess) {
        _frontOcr = result.data;
        _fillEditableFields(result.data);
      }
      _isOcrLoading = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('证件识别成功')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message ?? 'OCR失败')));
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
            title: AppStrings.idcardVer,
            activeStep: InformationStep.identity,
            onBack: () => FundingLimitDialog.showRetainDialog(context),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                color: Colors.white,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Text(
                                  '*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '请仔细核对个人身份信息',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildIdCardItem(
                              bgImage: Assets.images.inforamtionIdw,
                              isFilled: _idCardFrontData != null,
                              onTap: () => _showUploadOptions(isFront: true),
                              imageData: _idCardFrontData,
                              successText: null,
                            ),
                            const SizedBox(height: 16),
                            _buildIdCardItem(
                              bgImage: Assets.images.inforamtionIdo,
                              isFilled: _idCardBackData != null,
                              onTap: () => _showUploadOptions(isFront: false),
                              imageData: _idCardBackData,
                              successText: null,
                            ),
                            if (_isOcrLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(),
                              ),
                            if (_hasRecognizedIdentityInfo) ...[
                              const SizedBox(height: 8),
                              _buildInfoItem(
                                title: '加纳身份证号码',
                                controller: _idNumberController,
                              ),
                              _buildInfoItem(
                                title: '姓氏',
                                controller: _lastNameController,
                              ),
                              _buildInfoItem(
                                title: '名字',
                                controller: _firstNamesController,
                              ),
                              _buildInfoItem(
                                title: '性别',
                                controller: _genderController,
                              ),
                              _buildInfoItem(
                                title: '生日',
                                controller: _birthdayController,
                                showDivider: false,
                              ),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          BottomContinueButton(
            isEnabled:
                (_canContinue || _allowContinueForFaceTest) &&
                !_isSubmitting &&
                !_isOcrLoading,
            onTap: _onContinue,
            text: _isSubmitting ? '保存中...' : '继续',
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardItem({
    required AssetGenImage bgImage,
    required bool isFilled,
    required VoidCallback onTap,
    Uint8List? imageData,
    String? successText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (MediaQuery.of(context).size.width - 40) * 683.0 / 1005.0,
        decoration: BoxDecoration(
          image: DecorationImage(image: bgImage.provider(), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            if (!isFilled)
              Center(
                child: Assets.images.inforamtionScan.image(
                  width: 40,
                  height: 40,
                ),
              ),
            if (isFilled && imageData != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(36, 24, 36, 20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF8FB3B0),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          image: DecorationImage(
                            image: MemoryImage(imageData),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.cached_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required TextEditingController controller,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFEAEAEA)),
      ],
    );
  }
}
