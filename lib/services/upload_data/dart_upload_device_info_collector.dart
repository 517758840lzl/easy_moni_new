import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_moni/core/config/environment_config.dart';
import 'package:easy_moni/core/device/device_context.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/services/platform_service.dart';

/// 对齐线上设备信息 JSON 结构，不额外申请 ATT / 日历 / 通讯录 / 相册权限。
abstract final class DartUploadDeviceInfoCollector {
  DartUploadDeviceInfoCollector._();

  static Future<Map<String, dynamic>> collect() async {
    if (Platform.isIOS) {
      return _collectIos();
    }
    return _collectFallback();
  }

  static Future<Map<String, dynamic>> _collectIos() async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final locale = PlatformDispatcher.instance.locale;
    final ios = await _iosInfo();
    final extras = await DeviceInfoService.collectUploadExtras();
    final coords = await _peekCoordinates();
    final latitude = coords?['latitude'] ?? 0.0;
    final longitude = coords?['longitude'] ?? 0.0;
    final accuracy = coords?['accuracy'] ?? 0.0;

    final deviceId = _resolveDeviceId(ios);
    final appVersion = await AppInfoService.getVersionCode();
    final machine = ios?.utsname.machine.trim() ?? '';
    final systemVersion = ios?.systemVersion.trim().isNotEmpty == true
        ? ios!.systemVersion.trim()
        : _osVersionShort();
    final isSimulator = ios != null && !ios.isPhysicalDevice ? 1 : 0;
    final languageCode = locale.languageCode;
    final nativeScreen = _mapFromDynamic(extras['screenMetrics']);
    final screen = _screenInfo(nativeScreen: nativeScreen);
    final totalStorageMb = _bytesToMb(ios?.totalDiskSize ?? 0);
    final usedStorageMb = _bytesToMb(
      (ios?.totalDiskSize ?? 0) - (ios?.freeDiskSize ?? 0),
    );
    final locationInfo = await _buildLocationInfo(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );

    final rawDeviceInfo = _buildRawDeviceInfo(ios);
    final deviceBaseInfo = _buildDeviceBaseInfo(
      deviceId: deviceId,
      machine: machine,
      systemVersion: systemVersion,
      isSimulator: isSimulator,
      timestamp: timestamp,
    );
    final storageInfo = _buildStorageInfo(
      totalStorageMb: totalStorageMb,
      usedStorageMb: usedStorageMb,
      ramTotalMb: ios?.physicalRamSize ?? 0,
      ramUsableMb: ios?.availableRamSize ?? 0,
    );

    return {
      'advertising_id': '',
      'advinceDeviceInfoBean': {
        'batteryStatusInfo': extras['batteryStatusInfo'],
        'calendarEventList': null,
        'deviceBaseInfo': deviceBaseInfo,
        'fileInfo': null,
        'generalInfo': null,
        'imieInfo': null,
        'localInfo': _buildLocalInfo(locale: locale, now: now, languageCode: languageCode),
        'locationInfo': locationInfo,
        'networkInfo': extras['networkInfo'],
        'newFingerprint': null,
        'otherInfo': {
          'appFreeMemory': 0,
          'appMaxMemory': 0,
          'appTotalMemory': 0,
        },
        'phoneSignalInfo': null,
        'screenInfo': screen.map,
        'sensorList': null,
        'storageInfo': storageInfo,
      },
      'android_id': deviceId,
      'androidVersionCode': 0,
      'app_version': appVersion.isNotEmpty
          ? appVersion
          : EnvironmentConfig.current.appVersion,
      'base_band': '',
      'build_board': machine,
      'build_brand': 'Apple',
      'build_host': '',
      'build_id': machine,
      'build_product': ios?.model.trim().isNotEmpty == true ? ios!.model.trim() : 'iPhone',
      'build_tags': '',
      'build_type': '',
      'build_user': '',
      'build_uuid': deviceId,
      'cpu_cur_frequency': '',
      'cpu_max_frequency': '',
      'device_id': deviceId,
      'device_id_9_sn': '',
      'device_root': 0,
      'device_sim': 0,
      'firebaseInstanceId': '',
      'hours_since_last_launch': 0,
      'imei': '',
      'is_simulator': isSimulator,
      'language': languageCode,
      'latitude': _formatCoord(latitude),
      'longitude': _formatCoord(longitude),
      'mac': '',
      'media_uuid': '',
      'meid': '',
      'new_imei': '',
      'os_version': systemVersion,
      'phoneAliveTime': 0,
      'phone_brand': 'Apple',
      'phone_model': machine,
      'screen_density': screen.density,
      'screen_resolution': screen.logicalResolution,
      'sdcard_total_capacity': totalStorageMb,
      'sdcard_used_capacity': usedStorageMb,
      'sim_card_status': 0,
      'sim_code': '',
      'sn': deviceId,
      'sn_an9': '',
      'sysCurTimestamp': timestamp,
      'total_memory': ios?.physicalRamSize ?? 0,
      'total_storage': totalStorageMb,
      'used_memory': 0,
      'rawDeviceInfo': rawDeviceInfo,
    };
  }

  static Future<Map<String, dynamic>> _collectFallback() async {
    final now = DateTime.now();
    final locale = PlatformDispatcher.instance.locale;
    final screen = _screenInfo();
    final coords = await _peekCoordinates();
    final latitude = coords?['latitude'] ?? 0.0;
    final longitude = coords?['longitude'] ?? 0.0;
    final deviceId =
        HttpProvider.instance.deviceId ??
        EnvironmentConfig.current.defaultDeviceId;
    final appVersion = await AppInfoService.getVersionCode();
    final userAgent = await DeviceContext.resolveUserAgent();
    final languageCode = locale.languageCode;

    return {
      'advertising_id': '',
      'advinceDeviceInfoBean': {
        'screenInfo': screen.map,
        'generalInfo': null,
        'localInfo': _buildLocalInfo(locale: locale, now: now, languageCode: languageCode),
        'locationInfo': latitude == 0 && longitude == 0
            ? null
            : {
                'latitude': _formatCoord(latitude),
                'longitude': _formatCoord(longitude),
                'time': now.millisecondsSinceEpoch,
              },
      },
      'android_id': deviceId,
      'androidVersionCode': 0,
      'app_version': appVersion.isNotEmpty
          ? appVersion
          : EnvironmentConfig.current.appVersion,
      'device_id': deviceId,
      'is_simulator': 0,
      'language': languageCode,
      'latitude': _formatCoord(latitude),
      'longitude': _formatCoord(longitude),
      'os_version': _osVersionShort(),
      'phone_model': userAgent,
      'screen_density': screen.density,
      'screen_resolution': screen.logicalResolution,
      'sysCurTimestamp': now.millisecondsSinceEpoch,
      'total_memory': 0,
      'total_storage': 0,
      'used_memory': 0,
    };
  }

  static Map<String, dynamic> _buildRawDeviceInfo(IosDeviceInfo? ios) {
    if (ios == null) {
      return const {};
    }

    return {
      'isPhysicalDevice': ios.isPhysicalDevice,
      'isiOSAppOnMac': ios.isiOSAppOnMac,
      'utsname': {
        'release': ios.utsname.release,
        'sysname': ios.utsname.sysname,
        'nodename': ios.utsname.nodename,
        'machine': ios.utsname.machine,
        'version': ios.utsname.version,
      },
      'modelName': ios.modelName,
      'localizedModel': ios.localizedModel,
      'totalDiskSize': ios.totalDiskSize,
      'systemName': ios.systemName,
      'systemVersion': ios.systemVersion,
      'identifierForVendor': ios.identifierForVendor,
      'physicalRamSize': ios.physicalRamSize,
      'freeDiskSize': ios.freeDiskSize,
      'availableRamSize': ios.availableRamSize,
      'model': ios.model,
      'name': ios.name,
    };
  }

  static Map<String, dynamic> _buildDeviceBaseInfo({
    required String deviceId,
    required String machine,
    required String systemVersion,
    required int isSimulator,
    required int timestamp,
  }) {
    return {
      'androidId': deviceId,
      'board': machine,
      'brand': 'Apple',
      'buildTime': null,
      'cores': null,
      'createTime': null,
      'currentSystemTime': timestamp,
      'deviceName': null,
      'deviceUuid': deviceId,
      'fingerprint': deviceId,
      'gaid': '',
      'isEmulator': isSimulator,
      'manufacturer': null,
      'model': null,
      'phoneType': null,
      'release': systemVersion,
      'sdkVersion': 0,
      'serialNumber': deviceId,
    };
  }

  static Map<String, dynamic> _buildStorageInfo({
    required int totalStorageMb,
    required int usedStorageMb,
    required int ramTotalMb,
    required int ramUsableMb,
  }) {
    final usableStorage = math.max(totalStorageMb - usedStorageMb, 0);
    return {
      'internalStorageTotal': totalStorageMb,
      'internalStorageUsable': usableStorage,
      'memoryCardSize': null,
      'memoryCardSizeUse': null,
      'ramTotalSize': ramTotalMb,
      'ramUsableSize': ramUsableMb,
      'storageDirSize': null,
      'storageDirSizeUsable': null,
    };
  }

  static Map<String, dynamic> _buildLocalInfo({
    required Locale locale,
    required DateTime now,
    required String languageCode,
  }) {
    return {
      'language': languageCode,
      'localeDisplayLanguage': null,
      'localeIso3Country': '_',
      'localeIso3Language': '_',
      'networkOperatorName': null,
      'simCountryIso': null,
      'timeZoneId': _formatTimeZoneOffset(now),
    };
  }

  static Future<Map<String, dynamic>?> _buildLocationInfo({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timestamp,
  }) async {
    if (latitude == 0 && longitude == 0) {
      return null;
    }

    final geocoded = await DeviceInfoService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
    if (geocoded != null && geocoded.isNotEmpty) {
      return geocoded;
    }

    return {
      'accuracy': accuracy > 0 ? accuracy.toString() : null,
      'address': null,
      'addressList': null,
      'addressObject': null,
      'adminArea': null,
      'countryCode': null,
      'countryName': null,
      'featureName': null,
      'latitude': _formatCoord(latitude),
      'locality': null,
      'longitude': _formatCoord(longitude),
      'subAdminArea': null,
      'time': timestamp,
    };
  }

  static String _resolveDeviceId(IosDeviceInfo? ios) {
    final vendorId = ios?.identifierForVendor?.trim() ?? '';
    if (vendorId.isNotEmpty) {
      return vendorId;
    }
    return HttpProvider.instance.deviceId ??
        EnvironmentConfig.current.defaultDeviceId;
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

  static int _bytesToMb(int bytes) {
    if (bytes <= 0) return 0;
    return (bytes / (1024 * 1024)).round();
  }

  static String _formatCoord(double value) {
    return value.toString();
  }

  static String _formatTimeZoneOffset(DateTime now) {
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    if (hours >= 0) {
      return '+${hours.toString().padLeft(2, '0')}';
    }
    return hours.toString().padLeft(3, '0');
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map) {
      return value.map((key, dynamic item) => MapEntry(key.toString(), item));
    }
    return const {};
  }

  static ({
    String logicalResolution,
    String density,
    Map<String, dynamic> map,
  }) _screenInfo({Map<String, dynamic> nativeScreen = const {}}) {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isEmpty && nativeScreen.isEmpty) {
        return (
          logicalResolution: '',
          density: '',
          map: const <String, dynamic>{},
        );
      }

      final view = views.isNotEmpty ? views.first : null;
      final dpr = view?.devicePixelRatio ?? _doubleFrom(nativeScreen['density']);
      final widthPixels =
          _intFrom(nativeScreen['widthPixels']) ??
          (view == null ? 0 : view.physicalSize.width.round());
      final heightPixels =
          _intFrom(nativeScreen['heightPixels']) ??
          (view == null ? 0 : view.physicalSize.height.round());
      final logicalWidth = dpr > 0 ? (widthPixels / dpr).round() : widthPixels;
      final logicalHeight = dpr > 0 ? (heightPixels / dpr).round() : heightPixels;
      final densityStr = nativeScreen['density']?.toString() ??
          (dpr > 0 ? dpr.toStringAsFixed(1) : '');
      final densityDpi =
          _intFrom(nativeScreen['densityDpi']) ?? (dpr > 0 ? (163 * dpr).round() : 0);

      return (
        logicalResolution: '${logicalWidth}x$logicalHeight',
        density: densityStr,
        map: <String, dynamic>{
          'densityDpi': densityDpi,
          'physicalSize': nativeScreen['physicalSize'] ?? '',
          'scaledDensity': nativeScreen['scaledDensity'] ?? densityStr,
          'density': densityStr,
          'heightPixels': heightPixels,
          'ydpi': nativeScreen['ydpi'] ?? '',
          'xdpi': nativeScreen['xdpi'] ?? '',
          'widthPixels': widthPixels,
        },
      );
    } catch (_) {
      return (
        logicalResolution: '',
        density: '',
        map: const <String, dynamic>{},
      );
    }
  }

  static int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }

  static double _doubleFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
