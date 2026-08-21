import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

abstract final class DeviceContext {
  DeviceContext._();

  static String resolveClientType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  static Future<String> resolveUserAgent() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final model = (await plugin.androidInfo).model.trim();
        if (model.isNotEmpty) return model;
      } else if (Platform.isIOS) {
        final machine = (await plugin.iosInfo).utsname.machine.trim();
        if (machine.isNotEmpty) return machine;
      }
    } catch (_) {
    }
    return Platform.operatingSystemVersion;
  }

  /// iOS 设备 ID：IDFV，不需要权限。
  static Future<String> resolveDeviceId() async {
    if (!Platform.isIOS) return '';
    try {
      return (await DeviceInfoPlugin().iosInfo).identifierForVendor?.trim() ??
          '';
    } catch (_) {
      return '';
    }
  }
}
