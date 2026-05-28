import 'dart:typed_data';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/platform_service.dart';

class IdentityVerifyPage extends ConsumerStatefulWidget {
  const IdentityVerifyPage({super.key});

  @override
  ConsumerState<IdentityVerifyPage> createState() => _IdentityVerifyPageState();
}

class _IdentityVerifyPageState extends ConsumerState<IdentityVerifyPage> {
  // TODO: 测试写死需要替换为真实图片路径

  Uint8List? _idCardFrontData;
  Uint8List? _idCardBackData;

  bool _isIdCardFrontFilled = false;
  bool _isIdCardBackFilled = false;

  bool get _canContinue => _isIdCardFrontFilled && _isIdCardBackFilled;

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
            // Drag indicator
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
    // 检查相机权限
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
            // Drag indicator
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

  void _onImageSelected(Uint8List imageData, {required bool isFront}) {
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
  }

  void _onScanIdCardFront() {
    _showUploadOptions(isFront: true);
  }

  void _onScanIdCardBack() {
    _showUploadOptions(isFront: false);
  }

  void _onContinue() {
    if (_canContinue) {
      debugPrint('身份证正面大小: ${_idCardFrontData?.length}');
      debugPrint('身份证背面大小: ${_idCardBackData?.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF216A4A), Color(0xFF278571)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 44),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              AppStrings.idcardVer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Colors.black,
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
                    const SizedBox(height: 20),
                    _buildIdCardItem(
                      title: '身份证人像面',
                      isFilled: _isIdCardFrontFilled,
                      onTap: _onScanIdCardFront,
                      imageData: _idCardFrontData,
                    ),
                    const SizedBox(height: 16),
                    _buildIdCardItem(
                      title: '身份证国徽面',
                      isFilled: _isIdCardBackFilled,
                      onTap: _onScanIdCardBack,
                      imageData: _idCardBackData,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
              onTap: _canContinue ? _onContinue : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _canContinue
                      ? const Color(0xFF45F3A6)
                      : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    '继续',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _canContinue
                          ? const Color(0xFF104440)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepItem(icon: Icons.person, label: '个人信息', isCompleted: true),
        _buildConnector(),
        _buildStepItem(
          icon: Icons.badge_outlined,
          label: '身份验证',
          isCompleted: true,
        ),
        _buildConnector(),
        _buildStepItem(icon: Icons.face, label: '人脸验证', isCompleted: false),
      ],
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String label,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF45F3A6) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isCompleted
                ? null
                : Border.all(color: Colors.white, width: 1.5),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? const Color(0xFF45F3A6) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 32,
      height: 0,
      margin: const EdgeInsets.only(bottom: 30),
      child: CustomPaint(painter: _LinePainter()),
    );
  }

  Widget _buildIdCardItem({
    required String title,
    required bool isFilled,
    required VoidCallback onTap,
    Uint8List? imageData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFilled ? const Color(0xFF45F3A6) : const Color(0xFFE0E0E0),
            width: 1,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0E3133), Color(0xFF268470)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击扫描',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.5),
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
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
