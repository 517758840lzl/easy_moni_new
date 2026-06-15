import 'package:easy_moni/core/config/app_environment.dart';

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

  /// 构建每次请求都会携带的公共请求头。
  Map<String, String> commonHeaders({
    String? token,
    String? deviceId,
    bool includeContentType = true,
  }) {
    return {
      if (includeContentType) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'acqChannel': acqChannel,
      'acqChannelIndex': acqChannelIndex,
      'disableEncBody': disableEncBody,
      'appVersion': appVersion,
      'clientType': clientType,
      'advId': advId,
      'deviceId': deviceId ?? defaultDeviceId,
      if (token != null && token.isNotEmpty) 'token': token,
    };
  }

  /// 构建登录接口需要的环境和渠道参数。
  Map<String, dynamic> loginParams({
    required String phone,
    required String authCode,
    String? deviceId,
  }) {
    return {
      'phone': phone,
      'authCode': authCode,
      'afid': afid,
      'appVersion': appVersion,
      'clientType': clientType,
      'deviceId': deviceId ?? defaultDeviceId,
      'gaid': gaid,
      'mediaSource': mediaSource,
      'onlyLogin': onlyLogin,
      'referrer': referrer,
      'userAgent': userAgent,
    };
  }

  /// 将接口 path 拼接成完整 URL，供文件上传等直连场景使用。
  String resolveApiPath(String path) {
    return Uri.parse(baseUrl).resolve(path).toString();
  }
}

/// 项目环境配置入口，通过 --dart-define=APP_ENV=test 切换测试环境。
class EnvironmentConfigs {
  EnvironmentConfigs._();

  static const EnvironmentConfig test = EnvironmentConfig(
    name: AppEnvironment.test,
    baseUrl: 'https://www.zzyd.click/',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    acqChannel: 'GHPM',
    acqChannelIndex: '0',
    disableEncBody: 'false',
    appVersion: '10',
    clientType: 'android',
    defaultDeviceId: '7da8118f936659a7',
    advId: 'be1089a1-dc4b-4684-9882-2d670a214784',
    afid: '1779953073476-180350146959368781',
    gaid: 'be1089a1-dc4b-4684-9882-2d670a214784',
    mediaSource: '',
    referrer: 'utm_source=google-play&utm_medium=organic',
    userAgent: 'SM-A136U',
    onlyLogin: 0,
    enableNetworkLog: true,
  );

  static const EnvironmentConfig production = EnvironmentConfig(
    name: AppEnvironment.production,
    baseUrl: 'https://www.zzyd.click/',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    acqChannel: 'GHPM',
    acqChannelIndex: '0',
    disableEncBody: 'false',
    appVersion: '10',
    clientType: 'android',
    defaultDeviceId: '7da8118f936659a7',
    advId: 'be1089a1-dc4b-4684-9882-2d670a214784',
    afid: '1779953073476-180350146959368781',
    gaid: 'be1089a1-dc4b-4684-9882-2d670a214784',
    mediaSource: '',
    referrer: 'utm_source=google-play&utm_medium=organic',
    userAgent: 'SM-A136U',
    onlyLogin: 0,
    enableNetworkLog: false,
  );

  static EnvironmentConfig get current {
    if (AppEnvironment.currentName == AppEnvironment.test) {
      return test;
    }
    return production;
  }
}
