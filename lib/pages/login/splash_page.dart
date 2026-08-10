import 'dart:async';
import 'dart:io';

import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/tracking/tracking_bootstrap.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/login/splash_animations.dart';
import 'package:easy_moni/services/permission_storage.dart';
import 'package:easy_moni/services/saved_session_route_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  static const Color _backgroundFallbackColor = Colors.white;
  static const Color _progressTrackColor = Color(0xFFECEEF0);
  static const Color _progressFillColor = Color(0xFF268470);
  static const double _designWidth = 375;
  static const double _progressWidth = 192;
  static const double _progressHeight = 4;

  static const int _minDisplayMs = 3500;
  static const int _postAnimationNavigateMs = 2000;

  static bool get _isTest => Platform.environment['FLUTTER_TEST'] == 'true';

  static Duration get _animationDuration => Duration(
        milliseconds: _isTest ? 50 : _minDisplayMs,
      );

  static Duration get _routeResolveTimeout => Duration(
        milliseconds: _isTest ? 100 : _minDisplayMs + _postAnimationNavigateMs,
      );

  static Duration get _postAnimationNavigateTimeout => Duration(
        milliseconds: _isTest ? 0 : _postAnimationNavigateMs,
      );

  static Duration get _hardExitTimeout => Duration(
        milliseconds: _isTest
            ? 500
            : _minDisplayMs + _postAnimationNavigateMs + 200,
      );

  late final AnimationController _progressCtrl;
  Timer? _hardExitTimer;
  Timer? _postAnimationTimer;

  String _targetRoute = AppRoutePaths.login;
  bool _hasNavigated = false;
  bool _animationCompleted = false;
  bool _routeResolved = false;
  bool _hasPrecachedAssets = false;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _progressCtrl.addStatusListener(_onProgressStatusChanged);
    _progressCtrl.forward();

    if (!_isTest) {
      _hardExitTimer = Timer(_hardExitTimeout, _onHardExitTimeout);
    }

    unawaited(_initApp());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPrecachedAssets) return;

    _hasPrecachedAssets = true;
    unawaited(_precacheSplashAssets());
  }

  Future<void> _precacheSplashAssets() async {
    if (!mounted) return;

    await Future.wait([
      precacheImage(Assets.images.loginBg.provider(), context),
      precacheImage(Assets.images.appIconBlack.provider(), context),
      precacheImage(Assets.images.easyMoniText.provider(), context),
      precacheImage(Assets.images.splashBottomText.provider(), context),
    ]);
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _animationCompleted = true;
    _tryNavigate();

    _postAnimationTimer?.cancel();
    _postAnimationTimer = Timer(_postAnimationNavigateTimeout, () {
      if (!mounted || _hasNavigated) return;
      unawaited(_resolveRouteFallback());
      _tryNavigate(force: true);
    });
  }

  void _tryNavigate({bool force = false}) {
    if (_hasNavigated) return;
    if (!force) {
      if (!_animationCompleted) return;
      if (!_routeResolved) return;
    }
    _postAnimationTimer?.cancel();
    _navigateOnce(force: force);
  }

  void _onHardExitTimeout() {
    if (!mounted) return;
    unawaited(_resolveRouteFallback());
    _tryNavigate(force: true);
  }

  Future<void> _initApp() async {
    if (_isTest) {
      _targetRoute = AppRoutePaths.login;
    } else {
      if (await PermissionStorage.isPrivacyAgreed()) {
        unawaited(TrackingBootstrap.ensureStarted());
      }

      try {
        await _resolveRoute().timeout(_routeResolveTimeout);
      } on TimeoutException {
        await _resolveRouteFallback();
      } catch (_) {
        await _resolveRouteFallback();
      }
    }

    _routeResolved = true;
    _tryNavigate();
  }

  Future<void> _resolveRoute() async {
    final route = await ref
        .read(savedSessionRouteServiceProvider)
        .resolveSavedSessionRoute();
    _targetRoute = route ?? AppRoutePaths.login;
  }

  Future<void> _resolveRouteFallback() async {
    try {
      final route = await ref
          .read(savedSessionRouteServiceProvider)
          .resolveSavedSessionRoute();
      _targetRoute = route ?? AppRoutePaths.login;
    } catch (_) {
      _targetRoute = AppRoutePaths.login;
    }
  }

  void _navigateOnce({bool force = false}) {
    if (!force && _hasNavigated) return;
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!force && _hasNavigated) return;

      try {
        context.go(_targetRoute);
        _hasNavigated = true;
        _hardExitTimer?.cancel();
        _postAnimationTimer?.cancel();
      } catch (_) {
        try {
          context.go(AppRoutePaths.login);
          _hasNavigated = true;
          _hardExitTimer?.cancel();
          _postAnimationTimer?.cancel();
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _hardExitTimer?.cancel();
    _postAnimationTimer?.cancel();
    _progressCtrl.removeStatusListener(_onProgressStatusChanged);
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _backgroundFallbackColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 28),
                  Transform.translate(
                    offset: Offset(0, -34 * scale),
                    child: SizedBox(
                      width: 144 * scale,
                      height: 144 * scale,
                      child: Assets.images.appIconBlack.image(
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const Spacer(flex: 36),
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (context, child) {
                      return _SplashProgressBar(
                        width: _progressWidth * scale,
                        height: _progressHeight * scale,
                        progress: SplashProgressCurve.at(_progressCtrl.value),
                      );
                    },
                  ),
                  SizedBox(height: 48 * scale),
                  Assets.images.easyMoniText.image(
                    width: 160 * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 18 * scale),
                  Assets.images.splashBottomText.image(
                    width: 203 * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 44 * scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          gaplessPlayback: true,
          cacheWidth: cacheWidth > 0 ? cacheWidth : null,
          cacheHeight: cacheHeight > 0 ? cacheHeight : null,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(color: _SplashPageState._backgroundFallbackColor);
          },
        );
      },
    );
  }
}

class _SplashProgressBar extends StatelessWidget {
  const _SplashProgressBar({
    required this.width,
    required this.height,
    required this.progress,
  });

  final double width;
  final double height;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final fillWidth = width * progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: _SplashPageState._progressTrackColor),
            ),
            SizedBox(
              width: fillWidth,
              height: height,
              child: const ColoredBox(
                color: _SplashPageState._progressFillColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
