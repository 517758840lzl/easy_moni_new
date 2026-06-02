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
  int srcY = ((originalImage.height - (originalImage.height * 0.65)) / 2).toInt();
  int srcW = (originalImage.width * 0.55).toInt();
  int srcH = (originalImage.height * 0.65).toInt();


  final croppedImage = img.copyCrop(originalImage, x: srcX, y: srcY, width: srcW, height: srcH);


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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
                Positioned.fill(
                  child: CustomPaint(
                    painter: CardMaskPainter(),
                  ),
                ),


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
            left: 40,
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
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please use landscape mode and place all four corners of your Ghana Card inside the frame.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧拍照控制区与示例图
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 拍照按钮
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        color: Colors.white,
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