import 'dart:async';
import 'dart:typed_data';

import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/check_upload_data_valid_resp.dart';
import 'package:easy_moni/pages/login/providers/upload_data_provider.dart';
import 'package:easy_moni/services/upload_data/sms_keyword_provider.dart';
import 'package:easy_moni/services/upload_data/user_upload_data_collector.dart';
import 'package:easy_moni/utils/upload_data_compress_tool.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadDataSyncServiceProvider = Provider<UploadDataSyncService>((ref) {
  return UploadDataSyncService(
    ref: ref,
    collector: UserUploadDataCollector(
      smsKeywordProvider: SmsKeywordProvider(),
    ),
  );
});

class UploadDataSyncService {
  UploadDataSyncService({required this.ref, required this.collector});

  final Ref ref;
  final UserUploadDataCollector collector;

  bool _isRunning = false;
  DateTime? _lastRunAt;

  /// 分析有效性检查结果，并在需要时触发非阻塞上传任务。
  void handleCheckResult(CheckUploadDataValidResp? resp) {
    if (resp == null) return;

    final trackId = resp.appTrackId;
    if (trackId == null || trackId <= 0) {
      AppLogger.debug('UploadDataSyncService: appTrackId 无效，跳过上传');
      return;
    }

    final needDeviceInfo = resp.isValidDeviceInfo == 0;
    final needAppList = resp.isValidAppList == 0;
    final needSmsRecord = resp.isValidSmsRecord == 0;

    if (!needDeviceInfo && !needAppList && !needSmsRecord) {
      AppLogger.debug('UploadDataSyncService: 上传数据均有效，无需上传');
      return;
    }

    if (_isRunning) {
      AppLogger.debug('UploadDataSyncService: 已有上传任务运行中，跳过本次触发');
      return;
    }

    final now = DateTime.now();
    final lastRunAt = _lastRunAt;
    if (lastRunAt != null && now.difference(lastRunAt).inSeconds < 60) {
      AppLogger.debug('UploadDataSyncService: 触发过于频繁，跳过本次上传');
      return;
    }

    unawaited(
      _run(
        trackId: trackId,
        needDeviceInfo: needDeviceInfo,
        needAppList: needAppList,
        needSmsRecord: needSmsRecord,
      ).catchError((Object error, StackTrace stackTrace) {
        AppLogger.debug('UploadDataSyncService: 上传任务异常: $error\n$stackTrace');
      }),
    );
  }

  Future<void> _run({
    required int trackId,
    required bool needDeviceInfo,
    required bool needAppList,
    required bool needSmsRecord,
  }) async {
    _isRunning = true;
    _lastRunAt = DateTime.now();

    try {
      final deviceInfoBytes = needDeviceInfo
          ? await _collectAndCompress(collector.collectDeviceInfo)
          : null;
      final appListBytes = needAppList
          ? await _collectAndCompress(collector.collectAppList)
          : null;
      final smsRecordBytes = needSmsRecord
          ? await _collectAndCompress(collector.collectSmsRecord)
          : null;

      final hasUploadData =
          _hasBytes(deviceInfoBytes) ||
          _hasBytes(appListBytes) ||
          _hasBytes(smsRecordBytes);

      if (!hasUploadData) {
        throw Exception('没有可上传数据');
      }

      final result = await ref
          .read(submitUserUploadDataProvider)
          .call(
            trackId: trackId,
            deviceInfoBytes: deviceInfoBytes,
            appListBytes: appListBytes,
            smsRecordBytes: smsRecordBytes,
          );

      if (result.isSuccess) {
        AppLogger.debug('UploadDataSyncService: submitUserUploadData 成功');
      } else {
        throw Exception(result.message ?? 'submitUserUploadData 失败');
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<Uint8List?> _collectAndCompress(
    Future<dynamic> Function() collect,
  ) async {
    final payload = await collect();
    if (payload == null) return null;

    final bytes = UploadDataCompressTool.compressDeviceData(payload);
    return bytes.isEmpty ? null : bytes;
  }

  bool _hasBytes(Uint8List? bytes) {
    return bytes != null && bytes.isNotEmpty;
  }
}
