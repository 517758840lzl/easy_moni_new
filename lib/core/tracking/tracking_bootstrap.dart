import 'dart:async';
import 'dart:io';

import 'package:easy_moni/core/storage/attribution_store.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';

abstract final class TrackingBootstrap {
  TrackingBootstrap._();

  static Future<void>? _startFuture;

  static Future<void> ensureStarted() {
    return _startFuture ??= _startAppsFlyer();
  }

  static Future<void> _startAppsFlyer() async {
    try {
      await AppsFlyerTracker.initializeAppsFlyerTracker().timeout(
        const Duration(seconds: 8),
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
    } catch (_) {
    }
  }
}
