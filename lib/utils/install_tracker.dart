import 'dart:convert';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
// import 'package:palm_loan/manager/encryption_tool.dart';
import 'package:flutter/foundation.dart';
// import 'package:palm_loan/data/strings/build_config_info.dart';
// import 'package:palm_loan/manager/time_adapter.dart';
// import 'package:palm_loan/manager/console_tracer.dart';
// import 'package:palm_loan/manager/local_vault.dart';

/// AppsFlyer 分析跟踪助手
class InstallTracker {
  static AppsflyerSdk? _obtainSdk;
  static String? _obtainCachedUid;

  /// 初始化 AppsFlyer SDK
  static Future<void> initialize() async {
    // final options = AppsFlyerOptions(afDevKey: BuildConfigInfo.obtainAppsFlyerDevKey, showDebug: false);
    //
    // _obtainSdk = AppsflyerSdk(options);
    //
    // await _obtainSdk!.initSdk(
    //   registerConversionDataCallback: true,
    //   registerOnAppOpenAttributionCallback: true,
    //   registerOnDeepLinkingCallback: true,
    // );
    //
    // _registerConversionObserver();
    // _obtainCachedUid = await _obtainUid();
  }

  static Future<String> obtainAfTrackId() async {
    if (_obtainCachedUid != null && _obtainCachedUid!.isNotEmpty) {
      return _obtainCachedUid!;
    }

    if (_obtainSdk != null) {
      try {
        _obtainCachedUid = await _obtainSdk!.getAppsFlyerUID();
        return _obtainCachedUid ?? '';
      } catch (e) {
        if (kDebugMode) {
          // ConsoleTracer.err('AppsFlyer', 'Failed to get user ID: $e');
        }
      }
    }

    return '';
  }

  /// 跟踪事件
  static Future<bool> trackEvent(
    String obtainEventName, {
    Map<String, dynamic>? obtainBody,
    Map<String, dynamic>? obtainHeads,
    dynamic obtainMessage,
  }) async {
    bool? obtainResult;
    try {
      // final eventParams = _buildEventParameters(body: obtainBody, heads: obtainHeads, message: obtainMessage);
      // obtainResult = await _obtainSdk?.logEvent(obtainEventName, eventParams);
      // ConsoleTracer.info('Track event result: $obtainResult');
      // return obtainResult ?? false;
      return false;
    } catch (e) {
      // ConsoleTracer.info('Track event error: $e');
      return false;
    }
  }

  // ============== 私有方法 ==============

  /// 获取用户 ID（内部）
  static Future<String> _obtainUid() async {
    try {
      return await _obtainSdk!.getAppsFlyerUID() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// 注册安装来源监听
  static void _registerConversionObserver() {
    _obtainSdk?.onInstallConversionData((obtainResponse) {
      try {
        // ConsoleTracer.info('Conversion data: $obtainResponse');
        final obtainPayload = _parseConversionData(obtainResponse);
        if (obtainPayload != null) {
          _processMediaSource(obtainPayload);
        }
      } catch (e) {
        // ConsoleTracer.info('Conversion listener error: $e');
      }
    });
  }

  /// 解析转换数据
  static Map<String, dynamic>? _parseConversionData(dynamic obtainResponse) {
    if (obtainResponse is! Map) return null;

    final obtainMap = Map<String, dynamic>.from(obtainResponse);
    if (obtainMap.containsKey('status') && obtainMap['status'] == 'success' && obtainMap.containsKey('payload')) {
      return Map<String, dynamic>.from(obtainMap['payload'] ?? {});
    }
    return null;
  }

  /// 处理媒体来源
  static void _processMediaSource(Map<String, dynamic> obtainPayload) {
    final obtainMediaSource = _extractMediaOrigin(obtainPayload);
    // final obtainStoredSource = LocalVault.to.obtainMediaSource();
    //
    // // 仅在未设置或为自然流量时更新
    // if (obtainStoredSource == 'Organic' || obtainStoredSource == 'organic' || obtainStoredSource == '') {
    //   LocalVault.to.saveMediaSource(obtainMediaSource);
    // }
  }

  /// 提取媒体来源
  static String _extractMediaOrigin(Map<String, dynamic> obtainData) {
    final obtainStatus = obtainData['af_status']?.toString() ?? '';

    if (obtainStatus.isEmpty || obtainStatus.toLowerCase() == 'organic') {
      return 'Organic';
    }

    final obtainCampaign = obtainData['campaign']?.toString() ?? '';
    if (obtainCampaign.isNotEmpty && obtainCampaign != 'None') {
      return obtainCampaign;
    }

    final obtainMediaSource = obtainData['media_source']?.toString() ?? '';
    if (obtainMediaSource.isNotEmpty && obtainMediaSource != 'None') {
      return obtainMediaSource;
    }

    return 'No-Organic';
  }


  /// 构建事件参数
  // static Map<String, dynamic> _buildEventParameters({
  //   Map<String, dynamic>? body,
  //   Map<String, dynamic>? heads,
  //   dynamic message,
  // }) {
  //   final obtainCreateTime = TimeAdapter.formatTimestamp(
  //     DateTime.now().millisecondsSinceEpoch,
  //     obtainPattern: 'dd/MM/yyyy HH:mm:ss',
  //   );
  //
  //   final obtainParams = <String, dynamic>{'create_time': obtainCreateTime};
  //
  //   if (body != null || heads != null) {
  //     if (body != null) {
  //       obtainParams['body'] = EncryptionTool.to.encodeData(jsonEncode(body));
  //     }
  //     if (heads != null) {
  //       obtainParams['heads'] = jsonEncode(heads);
  //     }
  //   }
  //
  //   if (message != null) {
  //     obtainParams['msg'] = (message is String) ? message : jsonEncode(message);
  //   }
  //
  //   return obtainParams;
  // }
}