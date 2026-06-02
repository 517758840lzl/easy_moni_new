import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

import '../../utils/widgets/cardmask.dart';

Future<File> cropIdentityCard(String imagePath) async {
  //原图
  final bytes = await File(imagePath).readAsBytes();
  final originalImage = img.decodeImage(bytes);

  if (originalImage == null) throw Exception("无法解码图片");

  // CustomPainter 里画框的比例计算裁剪像素
  // 框占了屏幕宽度的 55%，高度的 65%，左边距 8%
  int srcX = (originalImage.width * 0.08).toInt();
  int srcY = ((originalImage.height - (originalImage.height * 0.65)) / 2)
      .toInt();
  int srcW = (originalImage.width * 0.55).toInt();
  int srcH = (originalImage.height * 0.65).toInt();

  final croppedImage = img.copyCrop(
    originalImage,
    x: srcX,
    y: srcY,
    width: srcW,
    height: srcH,
  );

  final croppedFile = File(imagePath.replaceAll('.jpg', '_cropped.jpg'));
  await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

  return croppedFile; // 返回裁剪后的纯证件文件
}

class IdCameraScreen extends ConsumerStatefulWidget {
  final CameraDescription? camera;

  const IdCameraScreen({Key? key, this.camera}) : super(key: key);

  @override
  ConsumerState<IdCameraScreen> createState() => _IdCameraScreenState();
}

class _IdCameraScreenState extends ConsumerState<IdCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // 锁定为横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializeControllerFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    CameraDescription? camera = widget.camera;
    if (camera == null) {
      final cameras = await availableCameras();
      camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
    }
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
  }

  @override
  void dispose() {
    // 恢复成竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final scanState = ref.watch(scanStateProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Positioned.fill(child: CustomPaint(painter: CardMaskPainter())),

                _buildUiLayer(),

                // 加一个全局的全屏 Loading 遮罩
                // if (scanState.isLoading) const Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildUiLayer() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 36,
            right: 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.takeOcrPictures,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 280, // 💡 因为增加了文字，稍微加宽到 280 让排版更舒适
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  // 1. 左侧：图文区域，占据整体宽度的 3分之2 (Expanded flex: 2)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 上排两张图文
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageWithText(
                                    Assets.images.inforamtionF.image(
                                      fit: BoxFit.contain,
                                    ),
                                    "文字F",
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildImageWithText(
                                    Assets.images.inforamtionO.image(
                                      fit: BoxFit.contain,
                                    ),
                                    "文字O",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12), // 上下排之间的间距
                          // 下排两张图文
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageWithText(
                                    Assets.images.inforamtionTh.image(
                                      fit: BoxFit.contain,
                                    ),
                                    "文字Th",
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildImageWithText(
                                    Assets.images.inforamtionT.image(
                                      fit: BoxFit.contain,
                                    ),
                                    "文字T",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. 右侧：拍照按钮，固定占据整体宽度的 3分之1 (Expanded flex: 1)
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double buttonSize = constraints.maxWidth * 0.65;
                          return GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithText(Widget imageWidget, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 自动让图片占据上方所有可用空间
        Expanded(child: Center(child: imageWidget)),
        const SizedBox(height: 4), // 图文之间的小间距
        // 下方的文字
        Text(
          text,
          maxLines: 1, // 限制单行，防止长文本撑爆炸开
          overflow: TextOverflow.ellipsis, // 文本过长时显示...
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            // 加上一层淡淡的文字阴影，防止在亮色背景下看不清白字
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 拍照逻辑
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      debugPrint("照片已保存至: ${image.path}");
      // ref.read(scanStateProvider.notifier).uploadAndRecognize(image.path);
    } catch (e) {
      debugPrint("拍照出错: $e");
    }
  }
}
