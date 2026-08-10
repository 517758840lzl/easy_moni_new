import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_moni/core/config/environment_config.dart';
import 'package:easy_moni/core/device/device_context.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/services/platform_service.dart';

/// iOS 设备信息（Dart 采集，App Store 合规）；Android 优先走原生，失败时可回退。
abstract final class DartUploadDeviceInfoCollector {
  DartUploadDeviceInfoCollector._();

  static Future<Map<String, dynamic>> collect() async {
    final now = DateTime.now();
    final locale = PlatformDispatcher.instance.locale;
    final screen = _screenInfo();
    final ios = await _iosInfo();
    final coords = await _peekCoordinates();
    final latitude = coords?['latitude'] ?? 0.0;
    final longitude = coords?['longitude'] ?? 0.0;

    final deviceId =
        HttpProvider.instance.deviceId ??
        EnvironmentConfig.current.defaultDeviceId;
    final appVersion = await AppInfoService.getVersionCode();
    final userAgent = await DeviceContext.resolveUserAgent();

    final machine = ios?.utsname.machine.trim() ?? '';
    final model = (ios?.model.trim().isNotEmpty == true)
        ? ios!.model.trim()
        : machine;
    final systemVersion = ios?.systemVersion.trim().isNotEmpty == true
        ? ios!.systemVersion.trim()
        : _osVersionShort();
    final isSimulator = ios != null && !ios.isPhysicalDevice ? 1 : 0;
    final vendorId = ios?.identifierForVendor?.trim() ?? '';

    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode ?? '';
    final languageTag = countryCode.isEmpty
        ? languageCode
        : '${languageCode}_$countryCode';

    return {
      'androidVersionCode': 0,
      'phoneAliveTime': 0,
      'app_version': appVersion.isNotEmpty
          ? appVersion
          : EnvironmentConfig.current.appVersion,
      'build_board': '',
      'build_user': '',
      'firebaseInstanceId': '',
      'cpu_max_frequency': '',
      'sysCurTimestamp': now.millisecondsSinceEpoch,
      'cpu_cur_frequency': '',
      'build_type': '',
      'device_id': deviceId,
      'build_product': machine,
      'build_brand': Platform.isIOS ? 'Apple' : '',
      'os_version': systemVersion,
      'build_host': '',
      'phone_brand': Platform.isIOS ? 'Apple' : '',
      'screen_resolution': screen.resolution,
      'is_simulator': isSimulator,
      'advinceDeviceInfoBean': {
        'screenInfo': screen.map,
        'generalInfo': {
          'isVpnConnected': 0,
          'isUsingProxyPort': 0,
          'isMockLocation': 0,
          'isUsbDebug': 0,
        },
        'localInfo': {
          'language': languageTag,
          'localeDisplayLanguage': locale.toLanguageTag(),
          'localeIso3Country': countryCode,
          'localeIso3Language': languageCode,
          'networkOperatorName': '',
          'simCountryIso': '',
          'timeZoneId': now.timeZoneName,
        },
      },
      'phone_model': model.isNotEmpty ? model : userAgent,
      'hours_since_last_launch': 0,
      'build_id': ios?.utsname.release.trim() ?? '',
      'screen_density': screen.density,
      'android_id': vendorId.isNotEmpty ? vendorId : deviceId,
      'build_tags': '',
      'latitude': latitude,
      'longitude': longitude,
      'advertising_id': '',
      'language': languageTag,
      'total_memory': 0,
      'total_storage': 0,
      'used_memory': 0,
    };
  }

  static Future<Map<String, double>?> _peekCoordinates() async {
    try {
      return await LocationService.getCurrentLocation();
    } catch (_) {
      return null;
    }
  }

  static Future<IosDeviceInfo?> _iosInfo() async {
    if (!Platform.isIOS) return null;
    try {
      return DeviceInfoPlugin().iosInfo;
    } catch (_) {
      return null;
    }
  }

  static String _osVersionShort() {
    final raw = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+(?:\.\d+)*)').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  static ({String resolution, String density, Map<String, dynamic> map})
  _screenInfo() {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isEmpty) {
        return (resolution: '', density: '', map: const <String, dynamic>{});
      }
      final view = views.first;
      final dpr = view.devicePixelRatio;
      final width = view.physicalSize.width.round();
      final height = view.physicalSize.height.round();
      final densityStr = dpr.toStringAsFixed(2);
      final densityDpi = (160 * dpr).round();
      return (
        resolution: '${width}x$height',
        density: densityStr,
        map: <String, dynamic>{
          'densityDpi': densityDpi,
          'physicalSize': '',
          'scaledDensity': densityStr,
          'density': densityStr,
          'heightPixels': height,
          'ydpi': '',
          'xdpi': '',
          'widthPixels': width,
        },
      );
    } catch (_) {
      return (resolution: '', density: '', map: const <String, dynamic>{});
    }
  }
}
