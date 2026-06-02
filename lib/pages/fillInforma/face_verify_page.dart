import 'dart:typed_data';

import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/upload_file_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/platform_service.dart';
import '../../utils/widgets/informationBottomButton.dart';

class FaceVerifyPage extends ConsumerStatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  ConsumerState<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

class _FaceVerifyPageState extends ConsumerState<FaceVerifyPage> {
  StepInfo? _stepInfo;
  int? _processId;
  Uint8List? _faceImage;
  String? _faceImageUrl;
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isSubmitting = false;

  bool get _canContinue => _faceImageUrl != null && _faceImageUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  Future<void> _fetchStepInfo() async {
    try {
      final result = await ref.read(acpElementInfoProvider).call(5);
      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        _processId = result.data!.processId;
        _stepInfo = result.data!.stepInfoList.isNotEmpty
            ? result.data!.stepInfoList.first
            : null;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFaceImage() async {
    final imageBytes = await CameraService.pickFromGallery();
    if (imageBytes == null) return;

    setState(() {
      _isUploading = true;
      _faceImage = imageBytes;
    });

    final result = await ref.read(uploadFileProvider).call(
      bytes: imageBytes,
      filename: 'face_verify.jpg',
    );

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (result.isSuccess) {
        _faceImageUrl = result.data;
      }
    });

    if (!result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message ?? '上传失败')));
    }
  }

  Future<void> _onContinue() async {
    if (!_canContinue || _isSubmitting || _stepInfo == null || _processId == null) {
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
      key ??= _stepInfo!.entries.isNotEmpty ? _stepInfo!.entries.first.key : null;
      if (key == null) {
        throw Exception('face verify field missing');
      }

      final result = await ref.read(submitAcpElementInfoProvider).call(
        processId: _processId!,
        step: _stepInfo!.step,
        jsonParam: [
          {
            'key': key,
            'value': '["$_faceImageUrl"]',
          },
        ],
      );

      if (!mounted) return;
      if (result.isSuccess) {
        context.go('/');
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
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickFaceImage,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: _canContinue
                                      ? const Color(0xFF45F3A6)
                                      : const Color(0xFF268470),
                                  width: 3,
                                ),
                                image: _faceImage != null
                                    ? DecorationImage(
                                        image: MemoryImage(_faceImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _faceImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.face,
                                          size: 60,
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '点击上传人脸图片',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_isUploading)
                            const CircularProgressIndicator()
                          else
                            Text(
                              _canContinue ? '图片上传成功' : '请选择一张清晰的人脸照片',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _canContinue
                                    ? const Color(0xFF45F3A6)
                                    : const Color(0xFF3F4950),
                              ),
                            ),
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
}
