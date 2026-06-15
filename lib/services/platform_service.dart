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
    }
  }
}

class ContactsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/contacts');

  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'checkContactsPermission',
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestContactsPermission',
      );
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<Map<String, String>>?> getContacts() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getContacts');
      return result.map((item) {
        final map = item as Map<dynamic, dynamic>;
        return {
          'id': map['id'] as String,
          'name': map['name'] as String,
          'phone': map['phone'] as String,
        };
      }).toList();
    } on PlatformException {
      return null;
    }
  }

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

  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    }
  }
}

class SmsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/sms');

  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkSmsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// 请求读取短信权限，授权结果只用于记录，不阻塞后续业务流程。
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestSmsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    }
  }
}

class CameraService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/camera');

  /// 请求相机权限，授权结果只用于记录，不阻塞后续业务流程。
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestCameraPermission',
      );
      return result;
    } on PlatformException {
      return false;
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
      'inAppActivityData': <String, dynamic>{},
    };
  }
}
