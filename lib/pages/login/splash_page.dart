import 'dart:async';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// App 启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _displayDuration = Duration(milliseconds: 1500);
  static const Duration _animationDuration = Duration(milliseconds: 700);

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isVisible = true;
      });
      unawaited(AfTracker.logFirstOpenIfNeeded());
      unawaited(_goToNextPage());
    });
  }

  /// 启动页首帧可见后再开始计时，避免启动期掉帧吃掉展示时长。
  Future<void> _goToNextPage() async {
    await Future<void>.delayed(_displayDuration);
    if (!mounted) return;

    context.go(AppRoutePaths.permission);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF123E39),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Stack(
          children: [
            const Positioned.fill(child: _SplashBackground()),
            SafeArea(
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    scale: _isVisible ? 1 : 0.96,
                    duration: _animationDuration,
                    curve: Curves.easeOutCubic,
                    child: const _SplashLogo(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 44,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1 : 0,
                duration: _animationDuration,
                curve: Curves.easeOutCubic,
                child: const _SplashBrandFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 启动页背景，使用设计提供的图片资源铺满屏幕。
class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (constraints.maxWidth * devicePixelRatio).round();
        final cacheHeight = (constraints.maxHeight * devicePixelRatio).round();

        return Assets.images.loginBg.image(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          cacheWidth: cacheWidth > 0 ? cacheWidth : null,
          cacheHeight: cacheHeight > 0 ? cacheHeight : null,
        );
      },
    );
  }
}

/// 中央 App 图标
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -34),
      child: SizedBox(
        width: 144,
        height: 144,
        child: Assets.images.appIconBlack.image(),
      ),
    );
  }
}

/// 底部品牌区，品牌字样使用设计提供的斜体贴图。
class _SplashBrandFooter extends StatelessWidget {
  const _SplashBrandFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.images.easyMoniText.image(
          width: 160,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 18),
        const Text(
          AppStrings.splashTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 16 / 14,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
