import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// 设备上下文工具，供登录等接口上报设备型号。
abstract final class DeviceContext {
  DeviceContext._();

  /// 登录 `userAgent` — 设备型号（如 `SM-A136U` / `iPhone13,4`），非 OS 版本。
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
      // Fall through to OS version.
    }
    return Platform.operatingSystemVersion;
  }
}
