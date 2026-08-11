import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final opened = await launchUrl(
        Uri.parse('app-settings:'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    }

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

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isSupportedPlatform => isSupported;

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
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class CameraService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/camera');
  static DateTime? _lastPermissionGrantAt;

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
      if (result) {
        _lastPermissionGrantAt = DateTime.now();
      }
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> settleAfterRecentPermissionGrant() async {
    if (kIsWeb || !Platform.isIOS) return;

    final grantedAt = _lastPermissionGrantAt;
    if (grantedAt == null) return;

    const settleDelay = Duration(milliseconds: 450);
    final elapsed = DateTime.now().difference(grantedAt);
    final remaining = settleDelay - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  static Future<bool> ensureReadyForCapture() async {
    if (await checkPermission()) {
      return true;
    }

    final granted = await requestPermission();
    if (!granted && !await checkPermission()) {
      return false;
    }

    await settleAfterRecentPermissionGrant();
    return checkPermission();
  }

  static Future<void> openAppSettings() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final opened = await launchUrl(
        Uri.parse('app-settings:'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    }

    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  /// 从相册选择图片，返回图片二进制数据。
  static Future<Uint8List?> pickFromGallery() async {
    if (kIsWeb) {
      return pickImageBytesForWeb();
    }
    try {
      final result = await _channel.invokeMethod<dynamic>('pickFromGallery');
      if (result == null) {
        return null;
      }
      if (result is Uint8List) {
        return result;
      }
      if (result is String && result.isNotEmpty) {
        return base64Decode(result);
      }
      if (result is List<int>) {
        return Uint8List.fromList(result);
      }
      return null;
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
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// 应用信息服务，统一从原生安装包信息读取版本名、版本号等基础信息。
class AppInfoService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/app_info');

  static Future<String> getVersionName() async {
    if (kIsWeb) return '';

    try {
      final String? result = await _channel.invokeMethod('getVersionName');
      return result ?? '';
    } on PlatformException {
      return '';
    } on MissingPluginException {
      return '';
    }
  }

  /// 获取应用数字版本号，用于接口上报 appVersion。
  static Future<String> getVersionCode() async {
    if (kIsWeb) return '';

    try {
      final String? result = await _channel.invokeMethod('getVersionCode');
      return result ?? '';
    } on PlatformException {
      return '';
    } on MissingPluginException {
      return '';
    }
  }
}

/// 应用任务服务，用于首页系统返回键退到后台而不是结束 Activity。
class AppTaskService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/app_task');

  static Future<bool> moveTaskToBack() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod('moveTaskToBack');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
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
    } on PlatformException {
      return <String, dynamic>{};
    } on MissingPluginException {
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
    } on PlatformException {
      return _emptyData();
    } on MissingPluginException {
      return _emptyData();
    }
  }

  static Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic>? source) {
    if (source == null) return _emptyData();
    return source.map((key, value) => MapEntry(key.toString(), value));
  }

  static Map<String, dynamic> _emptyData() {
    return {'appList': <dynamic>[], 'deviceInfo': <String, dynamic>{}};
  }
}
