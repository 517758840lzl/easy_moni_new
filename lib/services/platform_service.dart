import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  static Future<void> openAppSettings() async {
    if (kIsWeb) return;

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
      final latitude = (result['latitude'] as num?)?.toDouble();
      final longitude = (result['longitude'] as num?)?.toDouble();
      if (latitude == null || longitude == null) {
        return null;
      }
      return {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': (result['accuracy'] as num?)?.toDouble() ?? 0,
      };
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class DeviceInfoService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/device_info');

  static Future<Map<String, dynamic>> collectIosDeviceInfo() async {
    if (kIsWeb || !Platform.isIOS) {
      return const {};
    }

    try {
      final result = await _channel.invokeMethod<dynamic>('collectIosDeviceInfo');
      if (result is! Map) {
        return const {};
      }
      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException {
      return const {};
    } on MissingPluginException {
      return const {};
    }
  }

  static Future<Map<String, dynamic>> collectUploadExtras() async {
    if (kIsWeb || !Platform.isIOS) {
      return const {};
    }

    try {
      final result = await _channel.invokeMethod<dynamic>('collectUploadExtras');
      if (result is! Map) {
        return const {};
      }
      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException {
      return const {};
    } on MissingPluginException {
      return const {};
    }
  }

  static Future<Map<String, dynamic>?> reverseGeocode({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timestamp,
  }) async {
    if (kIsWeb || !Platform.isIOS) {
      return null;
    }
    if (latitude == 0 && longitude == 0) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod<dynamic>('reverseGeocode', {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp,
      });
      if (result == null || result is! Map) {
        return null;
      }
      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class ContactsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/contacts');

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

class CameraService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/camera');
  static DateTime? _lastPermissionGrantAt;

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
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

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

class ExternalLinkService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/external_link');

  static Future<bool> openUrl(String url) async {
    if (kIsWeb) return false;

    final target = url.trim();
    if (target.isEmpty) return false;

    try {
      final bool result = await _channel.invokeMethod('openUrl', {
        'url': target,
      });
      return result;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

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
