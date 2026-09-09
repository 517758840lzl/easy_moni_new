import 'dart:io';

import 'package:easy_moni/services/platform_service.dart';

abstract final class DeviceContext {
  DeviceContext._();

  static String resolveClientType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  static Future<String> resolveUserAgent() async {
    if (Platform.isIOS) {
      try {
        final info = await DeviceInfoService.collectIosDeviceInfo();
        final machine = info['machine']?.toString().trim() ?? '';
        if (machine.isNotEmpty) return machine;
      } catch (_) {}
    }
    return Platform.operatingSystemVersion;
  }

  /// iOS 设备 ID：IDFV，不需要权限。
  static Future<String> resolveDeviceId() async {
    if (!Platform.isIOS) return '';
    try {
      final info = await DeviceInfoService.collectIosDeviceInfo();
      return info['identifierForVendor']?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
