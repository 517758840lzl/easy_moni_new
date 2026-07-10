import 'package:easy_moni/core/config/app_environment.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';

/// 单个运行环境的网络、渠道、登录归因等参数配置。
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.name,
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.acqChannel,
    required this.acqChannelIndex,
    required this.disableEncBody,
    required this.appInstanceId,
    required this.appVersion,
    required this.clientType,
    required this.defaultDeviceId,
    required this.advId,
    required this.afid,
    required this.gaid,
    required this.mediaSource,
    required this.referrer,
    required this.userAgent,
    required this.onlyLogin,
    required this.enableNetworkLog,
  });

  final String name;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String acqChannel;
  final String acqChannelIndex;
  final String disableEncBody;
  final String appInstanceId;
  final String appVersion;
  final String clientType;
  final String defaultDeviceId;
  final String advId;
  final String afid;
  final String gaid;
  final String mediaSource;
  final String referrer;
  final String userAgent;
  final int onlyLogin;
  final bool enableNetworkLog;

  static EnvironmentConfig get current => EnvironmentConfigs.current;

  /// 构建每次请求都会携带的公共请求头，仅保留后端要求的业务头字段。
  Map<String, String> commonHeaders({String? token}) {
    return {
      'BridgeKey': acqChannel,
      'Position': acqChannelIndex,
      if (token != null && token.isNotEmpty) 'Seal': token,
    };
  }

  /// 构建登录接口需要的环境和渠道参数，优先使用运行时真实归因与设备值。
  Future<Map<String, dynamic>> loginParams({
    required String phone,
    required String authCode,
    String? deviceId,
  }) async {
    final runtimeAttribution =
        await AppsFlyerTracker.getAppsFlyerLoginAttributionData();
    final runtimeAppVersion = await AppInfoService.getVersionCode();

    return {
      'afid': runtimeAttribution['afid'] ?? afid,
      'appVersion': runtimeAppVersion.isNotEmpty
          ? runtimeAppVersion
          : appVersion,
      'authCode': authCode,
      'clientType': clientType,
      'deviceId': runtimeAttribution['deviceId'] ?? deviceId ?? defaultDeviceId,
      'gaid': runtimeAttribution['gaid'] ?? gaid,
      'mediaSource': runtimeAttribution['mediaSource'] ?? mediaSource,
      'onlyLogin': onlyLogin,
      'phone': phone,
      'referrer': runtimeAttribution['referrer'] ?? referrer,
      'userAgent': runtimeAttribution['userAgent'] ?? userAgent,
    };
  }

  /// 将接口 path 拼接成完整 URL，供文件上传等直连场景使用。
  String resolveApiPath(String path) {
    return Uri.parse(baseUrl).resolve(path).toString();
  }
}

/// 项目环境配置入口，项目当前仅保留生产环境参数。
class EnvironmentConfigs {
  EnvironmentConfigs._();

  static const EnvironmentConfig production = EnvironmentConfig(
    name: AppEnvironment.production,
    baseUrl: 'https://www.zzyd.click/',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    acqChannel: 'Easy',
    acqChannelIndex: '0',
    disableEncBody: 'true',
    appInstanceId: '',
    appVersion: '',
    clientType: 'android',
    defaultDeviceId: '',
    advId: '',
    afid: '',
    gaid: '',
    mediaSource: '',
    referrer: '',
    userAgent: '',
    onlyLogin: 0,
    enableNetworkLog: false,
  );

  static EnvironmentConfig get current => production;
}
