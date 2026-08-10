import 'dart:async';
import 'dart:io';

import 'package:easy_moni/core/storage/attribution_store.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:flutter/foundation.dart';

/// AppsFlyer 启动入口 — 用户同意隐私协议后再调用；老用户可在 Splash 幂等触发。
abstract final class TrackingBootstrap {
  TrackingBootstrap._();

  static Future<void>? _startFuture;

  static Future<void> ensureStarted() {
    return _startFuture ??= _start();
  }

  static Future<void> _start() async {
    try {
      await AppsFlyerTracker.initializeAppsFlyerTracker().timeout(
        const Duration(seconds: 5),
      );

      if (Platform.isAndroid) {
        await AppsFlyerTracker.refreshAppsFlyerRuntimeAttribution().timeout(
          const Duration(seconds: 5),
        );
      }

      if (await AttributionStore.isFirstOpen()) {
        await AppsFlyerTracker.logAppsFlyerActionEvent(
          AppsFlyerEventNames.easFirstOpen,
        ).timeout(const Duration(seconds: 3));
        await AttributionStore.markFirstOpenReported();
      }
    } on TimeoutException {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Tracking] bootstrap timed out');
      }
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Tracking] bootstrap skipped: $e\n$st');
      }
    }
  }
}
