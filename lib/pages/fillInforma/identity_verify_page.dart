import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../services/platform_service.dart';
import '../../utils/widgets/informationBottomButton.dart';

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
  OcrVerificationResp? _backOcr;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isOcrLoading = false;

  bool get _canContinue =>
      _idCardFrontData != null &&
      _idCardBackData != null &&
      _frontOcr?.url != null &&
      (_backOcr?.url != null || _backOcr?.backUrl != null);

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
    if (!_canContinue ||
        _isSubmitting ||
        _stepInfo == null ||
        _processId == null) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final entries = _stepInfo!.entries;
      final jsonParam = <Map<String, dynamic>>[];

      String? findKey(List<String> patterns) {
        for (final entry in entries) {
          final text = '${entry.showContent} ${entry.defaultText}'
              .toLowerCase();
          if (patterns.any((pattern) => text.contains(pattern))) {
            return entry.key;
          }
        }
        return null;
      }

      void addIfFound(List<String> patterns, String? value) {
        final key = findKey(patterns);
        if (key != null && value != null && value.isNotEmpty) {
          jsonParam.add({'key': key, 'value': value});
        }
      }

      addIfFound(['front'], _frontOcr?.url);
      addIfFound(['back'], _backOcr?.url ?? _backOcr?.backUrl);
      addIfFound(['national id', 'id number'], _frontOcr?.idCardNumber);
      addIfFound(['last name', 'surname', 'name'], _frontOcr?.lastName);
      addIfFound(['first name', 'father'], _frontOcr?.firstNames);
      addIfFound(['gender'], _frontOcr?.gender);
      addIfFound(['birth'], _frontOcr?.birthday);

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;
      if (result.isSuccess) {
        context.push('/face-verify');
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

  void _showUploadOptions({required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFEFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final galleryText = kIsWeb ? '选择图片' : AppStrings.selectFormPhotos;
        final cameraText = kIsWeb ? '重新选择图片' : AppStrings.takephotos;
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
                            icon: Icons.photo_library_outlined,
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
                            icon: Icons.camera_alt_outlined,
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

  Widget _buildUploadOption({required IconData icon, required String text}) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.black.withValues(alpha: 0.7)),
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
    debugPrint('开始选择身份证图片, isFront=$isFront, isWeb=$kIsWeb');
    final imageData = await CameraService.pickFromGallery();
    if (!mounted) return;
    if (imageData != null) {
      debugPrint('已拿到图片数据, bytes=${imageData.length}, isFront=$isFront');
      await _onImageSelected(imageData, isFront: isFront);
    } else {
      debugPrint('未拿到图片数据, isFront=$isFront');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未选择图片')));
    }
  }

  Future<void> _takePhoto({required bool isFront}) async {
    final hasPermission = await CameraService.checkPermission();
    if (!hasPermission && !kIsWeb) {
      _showCameraPermissionDialog();
      return;
    }
    final imageData = await CameraService.takePhoto();
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
    debugPrint('准备调用 OCR 接口, isFront=$isFront, bytes=${imageData.length}');
    setState(() {
      if (isFront) {
        _idCardFrontData = imageData;
      } else {
        _idCardBackData = imageData;
      }
      _isOcrLoading = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('开始识别证件信息...')));
    }

    final result = await ref
        .read(ocrVerificationProvider)
        .call(
          bytes: imageData,
          filename: isFront ? 'id_card_front.jpg' : 'id_card_back.jpg',
        );

    debugPrint(
      'OCR 接口返回: isSuccess=${result.isSuccess}, message=${result.message}, data=${result.data}',
    );

    if (!mounted) return;

    setState(() {
      if (result.isSuccess) {
        if (isFront) {
          _frontOcr = result.data;
        } else {
          _backOcr = result.data;
        }
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

  void _showCameraPermissionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFEFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Color(0xFF268470),
              ),
              SizedBox(height: 16),
              Text('需要相机权限'),
              SizedBox(height: 8),
              Text(AppStrings.idcardMessage, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
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
                                value: _frontOcr?.idCardNumber ?? '',
                              ),
                              _buildInfoItem(
                                title: '姓氏',
                                value: _frontOcr?.lastName ?? '',
                              ),
                              _buildInfoItem(
                                title: '名字',
                                value: _frontOcr?.firstNames ?? '',
                              ),
                              _buildInfoItem(
                                title: '性别',
                                value: _displayGender(_frontOcr?.gender),
                              ),
                              _buildInfoItem(
                                title: '生日',
                                value: _displayBirthday(_frontOcr?.birthday),
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
            isEnabled: _canContinue && !_isSubmitting && !_isOcrLoading,
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
    required String value,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFB8B8B8),
                          size: 22,
                        ),
                      ],
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
