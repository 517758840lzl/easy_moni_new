import 'dart:convert';
import 'dart:math';

import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/upload_data/sms_keyword_provider.dart';
import 'package:easy_moni/services/upload_data/user_upload_data_collector.dart';
import 'package:easy_moni/utils/upload_data_compress_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('真实风控数据采集', () {
    testWidgets('采集并输出真实设备、应用列表和短信数据', (tester) async {
      if (defaultTargetPlatform != TargetPlatform.android) {
        _printLong('真实风控数据采集仅 Android 原生通道支持，请在 Android 真机或模拟器运行。');
        return;
      }

      const shouldRequestSmsPermission = bool.fromEnvironment(
        'REQUEST_SMS_PERMISSION',
      );
      final collector = UserUploadDataCollector(
        smsKeywordProvider: SmsKeywordProvider(),
      );

      // 真实设备/App 数据采集：直接调用原生 silent_permission_data 通道。
      final nativePayload = await SilentPermissionDataService.collect();
      final deviceInfo = await collector.collectDeviceInfo();
      final appList = await collector.collectAppList();

      var hasSmsPermission = await SmsService.checkPermission();
      if (!hasSmsPermission && shouldRequestSmsPermission) {
        hasSmsPermission = await SmsService.requestPermission();
      }
      final smsRecord = await collector.collectSmsRecord();

      final deviceInfoBytes = _compressIfPresent(deviceInfo);
      final appListBytes = _compressIfPresent(appList);
      final smsRecordBytes = _compressIfPresent(smsRecord);

      _printJsonSection(
        '原生完整采集结果 SilentPermissionDataService.collect',
        nativePayload,
      );
      _printJsonSection('上传前真实 deviceInfo', deviceInfo);
      _printJsonSection('上传前真实 appList', appList);
      _printJsonSection('上传前真实 smsRecord', smsRecord);
      _printJsonSection('真实风控数据摘要', {
        'smsPermissionGranted': hasSmsPermission,
        'deviceInfoKeys': deviceInfo is Map ? deviceInfo.keys.toList() : [],
        'appListCount': appList is List ? appList.length : 0,
        'smsRecordCount': smsRecord is List ? smsRecord.length : 0,
        'compressedBytes': {
          'submitUserDeviceInfoBytes': deviceInfoBytes?.length,
          'submitUserAppListBytes': appListBytes?.length,
          'submitUserSmsBytes': smsRecordBytes?.length,
        },
      });

      expect(deviceInfo, isA<Map>());
      final deviceInfoMap = deviceInfo as Map;
      expect(deviceInfoMap, isNotEmpty);
      expect(deviceInfoMap, contains('packageName'));
      expect(deviceInfoMap, contains('androidId'));

      expect(appList, isA<List>());
      final appListItems = appList as List;
      expect(appListItems, isNotEmpty);
      expect(smsRecord == null || smsRecord is List, isTrue);
    });
  });
}

List<int>? _compressIfPresent(dynamic payload) {
  if (payload == null) return null;
  final bytes = UploadDataCompressTool.compressDeviceData(payload);
  return bytes.isEmpty ? null : bytes;
}

void _printJsonSection(String title, dynamic payload) {
  const encoder = JsonEncoder.withIndent('  ');
  _printLong('========== $title ==========\n${encoder.convert(payload)}');
}

void _printLong(String message) {
  const chunkSize = 800;
  for (var index = 0; index < message.length; index += chunkSize) {
    final end = min(index + chunkSize, message.length);
    debugPrintSynchronously(message.substring(index, end));
  }
}
