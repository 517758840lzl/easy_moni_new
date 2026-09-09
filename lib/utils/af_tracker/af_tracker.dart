import 'dart:convert';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:easy_moni/core/config/app_constants.dart';
import 'package:easy_moni/core/config/request_security_config.dart';
import 'package:easy_moni/core/device/device_context.dart';
import 'package:easy_moni/core/storage/attribution_store.dart';
import 'package:easy_moni/core/utils/request_security_util.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:easy_moni/utils/extensions.dart';

/// AppsFlyer 埋点工具，负责 SDK 初始化、归因缓存和统一事件上报。
class AppsFlyerTracker {
  AppsFlyerTracker._();

  static AppsflyerSdk? _sdk;
  static Map<String, dynamic>? _runtimeAttribution;
  static Future<void>? _initFuture;

  /// 初始化 AppsFlyer SDK，并异步缓存 AFID 与安装归因数据。
  static Future<void> initializeAppsFlyerTracker() {
    return _initFuture ??= _initializeAppsFlyerSdk();
  }

  static Future<void> _initializeAppsFlyerSdk() async {
    final devKey = AppConstants.afDevKey;
    if (devKey.isEmpty) {
      return;
    }

    final appleAppId = AppConstants.afAppleAppId.trim();
    if (Platform.isIOS) {
      final ok = RegExp(r'^\d{8,11}$').hasMatch(appleAppId);
      if (!ok) {
        return;
      }
    }

    try {
      final options = AppsFlyerOptions(
        afDevKey: devKey,
        appId: Platform.isIOS ? appleAppId : '',
        showDebug: false,
        // iOS：开启广告标识符（IDFA）采集；配合 ATT 弹窗。
        disableAdvertisingIdentifier: false,
        timeToWaitForATTUserAuthorization: Platform.isIOS ? 60 : null,
      );
      final sdk = AppsflyerSdk(options);
      _sdk = sdk;

      _listenAppsFlyerInstallConversionData();

      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

      final uid = await sdk.getAppsFlyerUID();
      await AttributionStore.setAfid(uid ?? '');
      await refreshAppsFlyerRuntimeAttribution();
    } catch (e) {
    }
  }

  static Future<String> getAppsFlyerId() async {
    final cached = await AttributionStore.getAfid();
    if (cached.isNotEmpty) return cached;

    if (_sdk == null) return AppConstants.defaultAfid;

    try {
      final uid = await _sdk!.getAppsFlyerUID();
      final value = uid ?? '';
      if (value.isNotEmpty) {
        await AttributionStore.setAfid(value);
        return value;
      }
    } catch (e) {
    }
    return AppConstants.defaultAfid;
  }

  /// 运行时归因数据，供登录参数使用真实 AFID、GAID、referrer 等设备参数。
  static Future<Map<String, dynamic>> getAppsFlyerLoginAttributionData() async {
    final attribution =
        _runtimeAttribution ?? await refreshAppsFlyerRuntimeAttribution();
    final afid = await getAppsFlyerId();
    final mediaSource = await getAppsFlyerMediaSource();

    return {
      if (afid.isNotEmpty) 'afid': afid,
      if (mediaSource.isNotEmpty) 'mediaSource': mediaSource,
      ...attribution,
    };
  }

  static Future<Map<String, dynamic>> refreshAppsFlyerRuntimeAttribution() async {
    try {
      if (Platform.isAndroid) {
        final attribution = await AttributionDeviceService.getAttributionData();
        final gaid = attribution['gaid']?.toString().trim() ?? '';
        if (gaid.isNotEmpty) {
          await AttributionStore.setGaid(gaid);
        }

        final referrer = attribution['referrer']?.toString().trim() ?? '';
        if (referrer.isNotEmpty) {
          await AttributionStore.setReferrer(referrer);
        }

        final userAgent = await DeviceContext.resolveUserAgent();
        final deviceId = attribution['deviceId']?.toString().trim() ?? '';
        final map = <String, dynamic>{
          if (gaid.isNotEmpty) 'gaid': gaid,
          if (referrer.isNotEmpty) 'referrer': referrer,
          if (userAgent.isNotEmpty) 'userAgent': userAgent,
          if (deviceId.isNotEmpty) 'deviceId': deviceId,
        };
        _runtimeAttribution = map;
        return map;
      }

      final userAgent = await DeviceContext.resolveUserAgent();
      final deviceId = await DeviceContext.resolveDeviceId();
      final map = <String, dynamic>{
        if (userAgent.isNotEmpty) 'userAgent': userAgent,
        if (deviceId.isNotEmpty) 'deviceId': deviceId,
      };
      _runtimeAttribution = map;
      return map;
    } catch (e) {
      _runtimeAttribution = <String, dynamic>{};
      return _runtimeAttribution!;
    }
  }

  /// 首次打开事件，每台设备只上报一次。
  static Future<void> logAppsFlyerFirstOpenIfNeeded() async {
    if (!await AttributionStore.isFirstOpen()) return;

    final tracked = await logAppsFlyerActionEvent(
      AppsFlyerEventNames.easFirstOpen,
    );
    if (tracked) {
      await AttributionStore.markFirstOpenReported();
    }
  }

  /// 获取缓存的归因渠道。
  static Future<String> getAppsFlyerMediaSource() async {
    return AttributionStore.getMediaSource();
  }

  /// 统一事件上报入口，body 与 msg 使用 AES 加密后再上送。
  static Future<bool> logAppsFlyerActionEvent(
    String eventName, {
    dynamic body,
    dynamic heads,
    dynamic msg,
  }) async {
    if (_sdk == null) {
      return false;
    }

    try {
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

      final result = await _sdk!.logEvent(eventName, eventValueMap);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static void _listenAppsFlyerInstallConversionData() {
    _sdk?.onInstallConversionData((res) async {
      try {
        if (res is! Map) return;

        final map = Map<String, dynamic>.from(res);
        if (map['status'] != 'success' || map['payload'] is! Map) return;

        final payload = Map<String, dynamic>.from(map['payload'] as Map);
        final mediaSource = parseAppsFlyerMediaSource(payload);
        await _saveMediaSourceIfNeeded(mediaSource);
      } catch (e) {
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

  static Future<void> _saveMediaSourceIfNeeded(String mediaSource) async {
    if (mediaSource.isEmpty) return;

    final existing = await AttributionStore.getMediaSource();
    if (existing.isNotEmpty &&
        existing != 'Organic' &&
        existing != 'organic') {
      return;
    }
    await AttributionStore.setMediaSource(mediaSource);
  }

  static Map<String, dynamic> _encryptValue(dynamic value) {
    final result = RequestSecurityUtil.encryptJson(
      value,
      aesKey: RequestSecurityConfig.requestAesKey,
    );
    return result.toRequestBody();
  }
}
