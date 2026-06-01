import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FaceVerifyPage extends ConsumerStatefulWidget {
  const FaceVerifyPage({super.key});

  @override
  ConsumerState<FaceVerifyPage> createState() => _FaceVerifyPageState();
}

class _FaceVerifyPageState extends ConsumerState<FaceVerifyPage> {
  bool _isLoading = false;
  bool _isVerified = false;

  bool get _canContinue => _isVerified;

  Future<void> _onContinue() async {
    if (!_canContinue || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // TODO: 调用人脸验证接口
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // 验证成功，跳转到首页
        context.pushReplacement('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('验证失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startFaceVerification() {
    // TODO: 调用原生人脸验证 SDK
    setState(() {
      _isVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _isVerified
                              ? const Color(0xFF45F3A6)
                              : const Color(0xFF268470),
                          width: 3,
                        ),
                      ),
                      child: _isVerified
                          ? const Icon(
                              Icons.check,
                              size: 80,
                              color: Color(0xFF45F3A6),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.face,
                                  size: 60,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '点击开始验证',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 40),
                    if (!_isVerified)
                      ElevatedButton(
                        onPressed: _startFaceVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF268470),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '开始人脸验证',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isVerified)
                      const Text(
                        '验证成功',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF45F3A6),
                        ),
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
              onTap: _canContinue && !_isLoading ? _onContinue : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _canContinue && !_isLoading
                      ? const Color(0xFF45F3A6)
                      : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF104440),
                            ),
                          ),
                        )
                      : Text(
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
}
