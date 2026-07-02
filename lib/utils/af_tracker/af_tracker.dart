import 'dart:convert';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:easy_moni/core/config/request_security_config.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/core/utils/request_security_util.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppsFlyer 埋点工具，负责 SDK 初始化、归因缓存和统一事件上报。
class AppsFlyerTracker {
  AppsFlyerTracker._();

  // TODO 正式环境替换_devKey
  static const String _tag = 'AF_HELPER';
  static const String _devKey = 'TvjK7RCEfTqdjkXRpnzY7P';
  static const String _keyUid = 'af_tracker_uid';
  static const String _keyMediaSource = 'af_tracker_media_source';
  static const String _keyFirstOpenTracked = 'af_tracker_first_open_tracked';

  static AppsflyerSdk? _sdk;
  static String? _uid;
  static Map<String, dynamic>? _runtimeAttribution;
  static Future<void>? _initFuture;

  /// 初始化 AppsFlyer SDK，并异步缓存 AFID 与安装归因数据。
  static Future<void> initializeAppsFlyerTracker() async {
    final runningInit = _initFuture;
    if (runningInit != null) {
      return runningInit;
    }

    _initFuture = _initializeAppsFlyerSdk();
    return _initFuture!;
  }

  static Future<void> _initializeAppsFlyerSdk() async {
    try {
      final options = AppsFlyerOptions(
        afDevKey: _devKey,
        showDebug: kDebugMode,
      );
      final sdk = AppsflyerSdk(options);
      _sdk = sdk;

      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );
      _listenAppsFlyerInstallConversionData();
      await _cacheAppsFlyerUid();
      await refreshAppsFlyerRuntimeAttribution();
    } catch (e, stackTrace) {
      AppLogger.error('$_tag init failed', e, stackTrace);
    }
  }

  /// 获取 AppsFlyer UID，优先使用内存和本地缓存。
  static Future<String> getAppsFlyerId() async {
    final cachedUid = _uid;
    if (cachedUid != null && cachedUid.isNotEmpty) {
      return cachedUid;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUid = prefs.getString(_keyUid) ?? '';
      if (storedUid.isNotEmpty) {
        _uid = storedUid;
        return storedUid;
      }
    } catch (e) {
      AppLogger.debug('$_tag read cached uid failed: $e');
    }

    return _cacheAppsFlyerUid();
  }

  /// 运行时归因数据，供登录参数使用真实 AFID、GAID、referrer 等设备参数。
  static Future<Map<String, dynamic>> getAppsFlyerLoginAttributionData() async {
    final attribution =
        _runtimeAttribution ?? await refreshAppsFlyerRuntimeAttribution();
    final afid = await getAppsFlyerId();
    final mediaSource = await getAppsFlyerMediaSource();
    AppLogger.debug('mediaSource $mediaSource');

    return {
      if (afid.isNotEmpty) 'afid': afid,
      if (mediaSource.isNotEmpty) 'mediaSource': mediaSource,
      ...attribution,
    };
  }

  /// 刷新 Android 原生侧获取的 GAID、Install Referrer 与设备信息。
  static Future<Map<String, dynamic>>
  refreshAppsFlyerRuntimeAttribution() async {
    try {
      final attribution = await AttributionDeviceService.getAttributionData();
      _runtimeAttribution = attribution;
      return attribution;
    } catch (e) {
      AppLogger.debug('$_tag refreshAppsFlyerRuntimeAttribution failed: $e');
      _runtimeAttribution = <String, dynamic>{};
      return _runtimeAttribution!;
    }
  }

  /// 首次打开事件，每台设备只上报一次。
  static Future<void> logAppsFlyerFirstOpenIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasTracked = prefs.getBool(_keyFirstOpenTracked) ?? false;
      if (hasTracked) return;

      final tracked = await logAppsFlyerActionEvent(
        AppsFlyerEventNames.firstOpen,
      );
      if (tracked) {
        await prefs.setBool(_keyFirstOpenTracked, true);
      }
    } catch (e) {
      AppLogger.debug('$_tag logAppsFlyerFirstOpenIfNeeded failed: $e');
    }
  }

  /// 获取缓存的归因渠道。
  static Future<String> getAppsFlyerMediaSource() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mediaSource = prefs.getString(_keyMediaSource) ?? '';
      return mediaSource;
    } catch (e) {
      AppLogger.debug('$_tag getAppsFlyerMediaSource failed: $e');
      return '';
    }
  }

  /// 统一事件上报入口，body 与 msg 使用 AES 加密后再上送。
  static Future<bool> logAppsFlyerActionEvent(
    String eventName, {
    dynamic body,
    dynamic heads,
    dynamic msg,
  }) async {
    try {
      if (_sdk == null) {
        await initializeAppsFlyerTracker();
      }
      final eventValueMap = <String, dynamic>{
        'create_time': DateTime.now().formatAfCreateTime,
      };

      if (body != null) {
        eventValueMap['body'] = _encryptValue(body);
      }
      if (heads != null) {
        eventValueMap['heads'] = jsonEncode(heads);
      }
      if (msg != null) {
        eventValueMap['msg'] = _encryptValue(msg);
      }

      final result = await _sdk?.logEvent(eventName, eventValueMap);
      AppLogger.debug('$_tag Result logEvent($eventName): $result');
      return result ?? false;
    } catch (e, stackTrace) {
      AppLogger.error('$_tag logEvent($eventName) failed', e, stackTrace);
      return false;
    }
  }

  static void _listenAppsFlyerInstallConversionData() {
    _sdk?.onInstallConversionData((res) async {
      try {
        AppLogger.debug('$_tag onInstallConversionData res: $res');
        final sourceMap = res is Map ? Map<String, dynamic>.from(res) : null;
        final payload = sourceMap?['payload'];
        if (sourceMap?['status'] == 'success' && payload is Map) {
          final mediaSource = parseAppsFlyerMediaSource(
            Map<String, dynamic>.from(payload),
          );
          await _saveMediaSourceIfNeeded(mediaSource);
        }
      } catch (e) {
        AppLogger.debug('$_tag onInstallConversionData failed: $e');
      }
    });
  }

  /// 按示例优先级解析安装归因渠道。
  static String parseAppsFlyerMediaSource(
    Map<String, dynamic>? conversionData,
  ) {
    if (conversionData == null) return '';

    final status = conversionData['af_status']?.toString() ?? '';
    if (status.isEmpty || status.toLowerCase() == 'organic') {
      return 'Organic';
    }

    final campaign = conversionData['campaign']?.toString() ?? '';
    if (campaign.isNotEmpty && campaign != 'None') {
      return campaign;
    }

    final mediaSource = conversionData['media_source']?.toString() ?? '';
    if (mediaSource.isNotEmpty && mediaSource != 'None') {
      return mediaSource;
    }

    return 'No-Organic';
  }

  static Future<String> _cacheAppsFlyerUid() async {
    try {
      final uid = await _sdk?.getAppsFlyerUID() ?? '';
      _uid = uid;
      if (uid.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUid, uid);
      }
      AppLogger.debug('$_tag AppsFlyer UID: $uid');
      return uid;
    } catch (e) {
      AppLogger.debug('$_tag get AppsFlyer UID failed: $e');
      return '';
    }
  }

  static Future<void> _saveMediaSourceIfNeeded(String mediaSource) async {
    if (mediaSource.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyMediaSource) ?? '';
    final normalizedStored = stored.toLowerCase();
    if (stored.isEmpty || normalizedStored == 'organic') {
      await prefs.setString(_keyMediaSource, mediaSource);
    }
  }

  static Map<String, dynamic> _encryptValue(dynamic value) {
    final result = RequestSecurityUtil.encryptJson(
      value,
      aesKey: RequestSecurityConfig.requestAesKey,
    );
    return result.toRequestBody();
  }
}
