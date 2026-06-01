import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
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
  Uint8List? _idCardFrontData;
  Uint8List? _idCardBackData;

  bool _isIdCardFrontFilled = false;
  bool _isIdCardBackFilled = false;

  bool _isLoading = false;

  bool get _canContinue => _isIdCardFrontFilled && _isIdCardBackFilled;

  Future<void> _onContinue() async {
    if (!_canContinue || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(submitAcpElementInfoProvider);
      final result = await api.call(
        processId: 36, // TODO: 从上一步获取实际 processId
        step: 1,
        data: {
          'idCardFront': _idCardFrontData != null
              ? {'base64': base64Encode(_idCardFrontData!)}
              : null,
          'idCardBack': _idCardBackData != null
              ? {'base64': base64Encode(_idCardBackData!)}
              : null,
        },
      );

      if (result.isSuccess) {
        if (mounted) {
          context.push('/face-verify');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '提交失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUploadOptions({required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFEFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
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
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 30,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  AppStrings.selectFormPhotos,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
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
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 30,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  AppStrings.takephotos,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
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

  Future<void> _pickFromGallery({required bool isFront}) async {
    try {
      final Uint8List? imageData = await CameraService.pickFromGallery();
      if (imageData != null) {
        _onImageSelected(imageData, isFront: isFront);
      }
    } catch (e) {
      debugPrint('从相册选择失败: $e');
    }
  }

  Future<void> _takePhoto({required bool isFront}) async {
    bool hasPermission = await CameraService.checkPermission();

    if (!hasPermission) {
      _showCameraPermissionDialog();
      return;
    }

    try {
      final Uint8List? imageData = await CameraService.takePhoto();
      if (imageData != null) {
        _onImageSelected(imageData, isFront: isFront);
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
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
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '需要相机权限',
                    style: TextStyle(
                      fontSize: 16,
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
                      color: Color(0xFF3F4950),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF268470)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        AppStrings.cancel,
                        style: TextStyle(
                          color: Color(0xFF268470),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // openAppSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF268470),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        '前往设置',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
          ],
        );
      },
    );
  }

  void _onImageSelected(Uint8List imageData, {required bool isFront}) async {
    setState(() {
      if (isFront) {
        _idCardFrontData = imageData;
        _isIdCardFrontFilled = true;
      } else {
        _idCardBackData = imageData;
        _isIdCardBackFilled = true;
      }
    });
    debugPrint('选择的图片大小: ${imageData.length} bytes');

    // 如果正面和背面都选择了，则调用 OCR 验证接口
    if (_idCardFrontData != null && _idCardBackData != null) {
      _callOcrVerification();
    }
  }

  Future<void> _callOcrVerification() async {
    try {
      final api = ref.read(ocrVerificationProvider);
      final result = await api.call(
        idCardFront: _idCardFrontData,
        idCardBack: _idCardBackData,
      );

      if (result.isSuccess) {
        debugPrint('OCR验证成功: ${result.data}');
      } else {
        debugPrint('OCR验证失败: ${result.message}');
      }
    } catch (e) {
      debugPrint('OCR验证异常: $e');
    }
  }

  void _onScanIdCardFront() {
    _showUploadOptions(isFront: true);
  }

  void _onScanIdCardBack() {
    _showUploadOptions(isFront: false);
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
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
                          const Text(
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
                        isFilled: _isIdCardFrontFilled,
                        onTap: _onScanIdCardFront,
                        imageData: _idCardFrontData,
                      ),
                      const SizedBox(height: 16),
                      _buildIdCardItem(
                        bgImage: Assets.images.inforamtionIdo,
                        isFilled: _isIdCardBackFilled,
                        onTap: _onScanIdCardBack,
                        imageData: _idCardBackData,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          BottomContinueButton(
            isEnabled: (_canContinue && !_isLoading),
            onTap: _onContinue,
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (MediaQuery.of(context).size.width - 40)*683.0/1005.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: bgImage.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (!isFilled)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Assets.images.inforamtionScan.image(
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
            if (isFilled && imageData != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: MemoryImage(imageData),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '已上传',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF45F3A6),
                        fontWeight: FontWeight.w500,
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
}