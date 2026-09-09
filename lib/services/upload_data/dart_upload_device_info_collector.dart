import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

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
    final ios = await DeviceInfoService.collectIosDeviceInfo();
    final extras = await DeviceInfoService.collectUploadExtras();
    final coords = await _peekCoordinates();
    final latitude = _coarseCoord(coords?['latitude'] ?? 0.0);
    final longitude = _coarseCoord(coords?['longitude'] ?? 0.0);
    final accuracy = coords?['accuracy'] ?? 0.0;

    final deviceId = _resolveDeviceId(ios);
    final appVersion = await AppInfoService.getVersionCode();
    final machine = ios['machine']?.toString().trim() ?? '';
    final systemVersionRaw = ios['systemVersion']?.toString().trim() ?? '';
    final systemVersion =
        systemVersionRaw.isNotEmpty ? systemVersionRaw : _osVersionShort();
    final isPhysicalDevice = ios['isPhysicalDevice'] == true;
    final isSimulator = ios.isNotEmpty && !isPhysicalDevice ? 1 : 0;
    final nativeScreen = _mapFromDynamic(extras['screenMetrics']);
    final screen = _screenInfo(nativeScreen: nativeScreen);
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
    final networkInfo = _buildNetworkInfo(extras['networkInfo']);
    final advinceDeviceInfoBean = <String, dynamic>{
      'deviceBaseInfo': deviceBaseInfo,
      if (networkInfo.isNotEmpty) 'networkInfo': networkInfo,
      if (screen.map.isNotEmpty) 'screenInfo': screen.map,
      'locationInfo': locationInfo,
    };

    return {
      'advinceDeviceInfoBean': advinceDeviceInfoBean,
      'app_version': appVersion.isNotEmpty
          ? appVersion
          : EnvironmentConfig.current.appVersion,
      'build_brand': 'Apple',
      'build_product': (ios['model']?.toString().trim().isNotEmpty == true)
          ? ios['model'].toString().trim()
          : 'iPhone',
      'device_id': deviceId,
      'is_simulator': isSimulator,
      'latitude': _formatCoord(latitude),
      'longitude': _formatCoord(longitude),
      'os_version': systemVersion,
      'phone_brand': 'Apple',
      if (machine.isNotEmpty) 'phone_model': machine,
      if (screen.density.isNotEmpty) 'screen_density': screen.density,
      if (screen.physicalResolution.isNotEmpty)
        'screen_resolution': screen.physicalResolution,
      'sysCurTimestamp': timestamp,
      if (rawDeviceInfo.isNotEmpty) 'rawDeviceInfo': rawDeviceInfo,
    };
  }

  static Future<Map<String, dynamic>> _collectFallback() async {
    final now = DateTime.now();
    final screen = _screenInfo();
    final coords = await _peekCoordinates();
    final latitude = _coarseCoord(coords?['latitude'] ?? 0.0);
    final longitude = _coarseCoord(coords?['longitude'] ?? 0.0);
    final accuracy = coords?['accuracy'] ?? 0.0;
    final timestamp = now.millisecondsSinceEpoch;
    final deviceId =
        HttpProvider.instance.deviceId ??
        EnvironmentConfig.current.defaultDeviceId;
    final appVersion = await AppInfoService.getVersionCode();
    final userAgent = await DeviceContext.resolveUserAgent();

    final locationInfo = await _buildLocationInfo(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );

    return {
      'advinceDeviceInfoBean': {
        if (screen.map.isNotEmpty) 'screenInfo': screen.map,
        'locationInfo': locationInfo,
      },
      'app_version': appVersion.isNotEmpty
          ? appVersion
          : EnvironmentConfig.current.appVersion,
      'device_id': deviceId,
      'latitude': _formatCoord(latitude),
      'longitude': _formatCoord(longitude),
      'os_version': _osVersionShort(),
      if (userAgent.isNotEmpty) 'phone_model': userAgent,
      if (screen.density.isNotEmpty) 'screen_density': screen.density,
      if (screen.physicalResolution.isNotEmpty)
        'screen_resolution': screen.physicalResolution,
      'sysCurTimestamp': timestamp,
    };
  }

  static Map<String, dynamic> _buildRawDeviceInfo(Map<String, dynamic> ios) {
    if (ios.isEmpty) {
      return const {};
    }

    return {
      'isPhysicalDevice': ios['isPhysicalDevice'] == true,
      'isiOSAppOnMac': ios['isiOSAppOnMac'] == true,
      'modelName': ios['modelName']?.toString() ?? '',
      'localizedModel': ios['localizedModel']?.toString() ?? '',
      'systemName': ios['systemName']?.toString() ?? '',
      'systemVersion': ios['systemVersion']?.toString() ?? '',
      'model': ios['model']?.toString() ?? '',
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
      if (machine.isNotEmpty) 'board': machine,
      'brand': 'Apple',
      'currentSystemTime': timestamp,
      'deviceUuid': deviceId,
      'isEmulator': isSimulator,
      'release': systemVersion,
    };
  }

  static Future<Map<String, dynamic>> _buildLocationInfo({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timestamp,
  }) async {
    if (latitude == 0 && longitude == 0) {
      return {
        'latitude': _formatCoord(latitude),
        'longitude': _formatCoord(longitude),
        'time': timestamp,
      };
    }

    final geocoded = await DeviceInfoService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
    if (geocoded != null && geocoded.isNotEmpty) {
      return _coarseLocationInfo(geocoded);
    }

    return {
      'latitude': _formatCoord(latitude),
      'longitude': _formatCoord(longitude),
      'time': timestamp,
    };
  }

  static Map<String, dynamic> _buildNetworkInfo(dynamic raw) {
    final map = _mapFromDynamic(raw);
    final networkType = map['networkType']?.toString() ?? '';
    if (networkType.isEmpty) {
      return const {};
    }
    return {'networkType': networkType};
  }

  /// 与 PrivacyInfo 中 CoarseLocation 声明一致；address 为 city + region + country 拼接。
  static const _coarseLocationKeys = {
    'time',
    'latitude',
    'longitude',
    'address',
  };

  static Map<String, dynamic> _coarseLocationInfo(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    for (final key in _coarseLocationKeys) {
      final value = source[key];
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      if (key == 'latitude' || key == 'longitude') {
        result[key] = _formatCoord(double.tryParse(value.toString()) ?? 0);
        continue;
      }
      result[key] = value;
    }
    return result;
  }

  static String _resolveDeviceId(Map<String, dynamic> ios) {
    final vendorId = ios['identifierForVendor']?.toString().trim() ?? '';
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

  static String _osVersionShort() {
    final raw = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+(?:\.\d+)*)').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  /// 约 1.1 km 精度，对齐 Coarse Location。
  static double _coarseCoord(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static String _formatCoord(double value) {
    if (value == 0) return '0.0';
    return _coarseCoord(value).toStringAsFixed(2);
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map) {
      return value.map((key, dynamic item) => MapEntry(key.toString(), item));
    }
    return const {};
  }

  static ({
    String logicalResolution,
    String physicalResolution,
    String density,
    Map<String, dynamic> map,
  }) _screenInfo({Map<String, dynamic> nativeScreen = const {}}) {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isEmpty && nativeScreen.isEmpty) {
        return (
          logicalResolution: '',
          physicalResolution: '',
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
      final physicalResolution = widthPixels > 0 && heightPixels > 0
          ? '${widthPixels}x$heightPixels'
          : '';

      final physicalSize = nativeScreen['physicalSize']?.toString() ?? '';
      final scaledDensity = nativeScreen['scaledDensity']?.toString() ?? densityStr;
      final ydpi = nativeScreen['ydpi']?.toString() ?? '';
      final xdpi = nativeScreen['xdpi']?.toString() ?? '';

      return (
        logicalResolution: '${logicalWidth}x$logicalHeight',
        physicalResolution: physicalResolution,
        density: densityStr,
        map: <String, dynamic>{
          if (densityDpi > 0) 'densityDpi': densityDpi,
          if (physicalSize.isNotEmpty) 'physicalSize': physicalSize,
          if (scaledDensity.isNotEmpty) 'scaledDensity': scaledDensity,
          if (densityStr.isNotEmpty) 'density': densityStr,
          if (heightPixels > 0) 'heightPixels': heightPixels,
          if (ydpi.isNotEmpty) 'ydpi': ydpi,
          if (xdpi.isNotEmpty) 'xdpi': xdpi,
          if (widthPixels > 0) 'widthPixels': widthPixels,
        },
      );
    } catch (_) {
      return (
        logicalResolution: '',
        physicalResolution: '',
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
