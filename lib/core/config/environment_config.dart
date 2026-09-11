import 'package:easy_moni/core/config/app_environment.dart';
import 'package:easy_moni/core/device/device_context.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';

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

  Map<String, String> commonHeaders({String? token}) {
    return {
      'BridgeKey': acqChannel,
      'Position': acqChannelIndex,
      if (token != null && token.isNotEmpty) 'Seal': token,
    };
  }

  Future<Map<String, dynamic>> loginParams({
    required String phone,
    required String authCode,
    String? deviceId,
  }) async {
    final runtimeAttribution =
        await AppsFlyerTracker.getAppsFlyerLoginAttributionData();
    final runtimeAppVersion = await AppInfoService.getVersionCode();
    final resolvedUserAgent = await DeviceContext.resolveUserAgent();

    String pickString(String? runtime, String fallback) {
      final value = runtime?.trim();
      if (value != null && value.isNotEmpty) return value;
      return fallback;
    }

    return {
      'afid': pickString(runtimeAttribution['afid']?.toString(), afid),
      'appVersion': runtimeAppVersion.isNotEmpty
          ? runtimeAppVersion
          : appVersion,
      'authCode': authCode,
      'clientType': DeviceContext.resolveClientType(),
      'deviceId': pickString(
        runtimeAttribution['deviceId']?.toString(),
        deviceId ?? defaultDeviceId,
      ),
      'gaid': pickString(runtimeAttribution['gaid']?.toString(), gaid),
      'mediaSource': pickString(
        runtimeAttribution['mediaSource']?.toString(),
        mediaSource,
      ),
      'onlyLogin': onlyLogin,
      'phone': phone,
      'referrer': pickString(
        runtimeAttribution['referrer']?.toString(),
        referrer,
      ),
      'userAgent': pickString(
        runtimeAttribution['userAgent']?.toString(),
        resolvedUserAgent,
      ),
    };
  }

  String resolveApiPath(String path) {
    return Uri.parse(baseUrl).resolve(path).toString();
  }
}

class EnvironmentConfigs {
  EnvironmentConfigs._();

  static const EnvironmentConfig production = EnvironmentConfig(
    name: AppEnvironment.production,
    baseUrl: 'https://www.bluebirdfintech.com/',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    acqChannel: 'PrimeCreditLoan',
    acqChannelIndex: '0',
    disableEncBody: 'true',
    appInstanceId: '',
    appVersion: '',
    defaultDeviceId: '',
    advId: '',
    afid: '',
    gaid: '',
    mediaSource: '',
    referrer: '',
    userAgent: '',
    onlyLogin: 0,
    enableNetworkLog: true,
  );

  static EnvironmentConfig get current => production;
}
