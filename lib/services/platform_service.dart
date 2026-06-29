import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'web_image_picker_stub.dart'
    if (dart.library.html) 'web_image_picker_web.dart';

class LocationService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/location');

  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'checkLocationPermission',
      );
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestLocationPermission',
      );
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 打开系统 App 设置页，引导用户在权限设置中开启位置权限。
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  static Future<bool> isServiceEnabled() async {
    try {
      final bool result = await _channel.invokeMethod(
        'isLocationServiceEnabled',
      );
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'getCurrentLocation',
      );
      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
      };
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class ContactsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/contacts');

  /// 打开系统联系人选择器，仅返回用户主动选择的联系人，不申请通讯录读取权限。
  static Future<Map<String, String>?> pickContact() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
        'pickContact',
      );
      if (result == null) return null;
      return {
        'id': result['id'] as String? ?? '',
        'name': result['name'] as String? ?? '',
        'phone': result['phone'] as String? ?? '',
      };
    } on PlatformException {
      return null;
    }
  }
}

class SmsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/sms');

  /// 短信读取仅 Android 原生端支持，其他平台直接跳过采集。
  static bool get _isSupportedPlatform {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<bool> checkPermission() async {
    if (!_isSupportedPlatform) return false;

    try {
      final bool result = await _channel.invokeMethod('checkSmsPermission');
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 请求读取短信权限，授权结果只用于记录，不阻塞后续业务流程。
  static Future<bool> requestPermission() async {
    if (!_isSupportedPlatform) return false;

    try {
      final bool result = await _channel.invokeMethod('requestSmsPermission');
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    if (!_isSupportedPlatform) return;

    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  /// 读取本机短信记录；关键词和条数限制交由 Android 原生查询处理。
  static Future<List<Map<String, dynamic>>?> getSmsRecords({
    required List<String> keywords,
    required int limit,
  }) async {
    if (!_isSupportedPlatform) return null;

    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getSmsRecords',
        {'keywords': keywords, 'limit': limit},
      );
      return result.map((item) {
        final map = item as Map<dynamic, dynamic>;
        return map.map((key, value) => MapEntry(key.toString(), value));
      }).toList();
    } on PlatformException catch (e) {
      AppLogger.debug('SmsService.getSmsRecords failed: $e');
      return null;
    } on MissingPluginException catch (e) {
      AppLogger.debug('SmsService.getSmsRecords missing plugin: $e');
      return null;
    }
  }
}

class CameraService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/camera');

  /// 检查相机权限；拍摄页只在已授权后进入，避免相机插件再次触发权限流程。
  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkCameraPermission');
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 请求相机权限，授权结果只用于记录，不阻塞后续业务流程。
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestCameraPermission',
      );
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  /// 从相册选择图片，返回 Base64 编码的图片数据
  static Future<Uint8List?> pickFromGallery() async {
    if (kIsWeb) {
      return pickImageBytesForWeb();
    }
    try {
      final String? base64 = await _channel.invokeMethod('pickFromGallery');
      if (base64 == null || base64.isEmpty) {
        return null;
      }
      return base64Decode(base64);
    } on PlatformException {
      return null;
    }
  }
}

/// 系统拨号盘服务，只负责拉起拨号界面，不直接发起通话。
class DialerService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/dialer');

  static Future<bool> openDialer({String phone = ''}) async {
    if (kIsWeb) return false;

    try {
      final bool result = await _channel.invokeMethod('openDialer', {
        'phone': phone.trim(),
      });
      return result;
    } on PlatformException catch (e) {
      AppLogger.debug('DialerService.openDialer failed: $e');
      return false;
    } on MissingPluginException catch (e) {
      AppLogger.debug('DialerService.openDialer missing plugin: $e');
      return false;
    }
  }
}

/// 归因设备服务，提供登录埋点需要的真实 GAID、Install Referrer 和设备标识。
class AttributionDeviceService {
  static const MethodChannel _channel = MethodChannel(
    'com.easy_moni/attribution',
  );

  static Future<Map<String, dynamic>> getAttributionData() async {
    if (kIsWeb) {
      return <String, dynamic>{};
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getAttributionData',
      );
      if (result == null) return <String, dynamic>{};
      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException catch (e) {
      AppLogger.debug('AttributionDeviceService.getAttributionData failed: $e');
      return <String, dynamic>{};
    } on MissingPluginException catch (e) {
      AppLogger.debug(
        'AttributionDeviceService.getAttributionData missing plugin: $e',
      );
      return <String, dynamic>{};
    }
  }
}

/// 静默采集用户授权后需要的基础风控数据。
class SilentPermissionDataService {
  static const MethodChannel _channel = MethodChannel(
    'com.easy_moni/silent_permission_data',
  );

  /// 异步获取 App list、设备信息和应用内活动数据；失败时返回空结构，避免阻断页面跳转。
  static Future<Map<String, dynamic>> collect() async {
    if (kIsWeb) {
      return _emptyData();
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'collect',
      );
      return _normalizeMap(result);
    } on PlatformException catch (e) {
      AppLogger.debug('SilentPermissionDataService.collect failed: $e');
      return _emptyData();
    }
  }

  static Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic>? source) {
    if (source == null) return _emptyData();
    return source.map((key, value) => MapEntry(key.toString(), value));
  }

  static Map<String, dynamic> _emptyData() {
    return {
      'appList': <dynamic>[],
      'deviceInfo': <String, dynamic>{},
    };
  }
}
