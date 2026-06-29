import 'dart:async';
import 'dart:convert';
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

  Future<void>? _activeUploadTask;
  DateTime? _lastRunAt;

  /// 分析有效性检查结果，并在需要时触发非阻塞上传任务。
  void handleCheckResult(CheckUploadDataValidResp? resp) {
    final request = _buildUploadRequest(resp);
    if (request == null) return;

    if (_activeUploadTask != null) {
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
      _startUpload(request).catchError((Object error, StackTrace stackTrace) {
        AppLogger.debug('UploadDataSyncService: 上传任务异常: $error\n$stackTrace');
      }),
    );
  }

  /// 借款提交前使用的阻塞式补传；无效数据上传完成后才允许继续业务流程。
  Future<void> uploadInvalidDataBeforeSubmit(
    CheckUploadDataValidResp? resp,
  ) async {
    if (resp == null) {
      throw Exception('checkUploadDataValid 无返回数据');
    }

    final request = _buildUploadRequest(resp);
    if (request == null) {
      if (_hasInvalidData(resp)) {
        throw Exception('存在无法自动补传的无效数据');
      }
      return;
    }

    final activeTask = _activeUploadTask;
    if (activeTask != null) {
      AppLogger.debug('UploadDataSyncService: 等待进行中的上传任务完成');
      await activeTask;
      return;
    }

    await _startUpload(request);
  }

  _UploadDataSyncRequest? _buildUploadRequest(CheckUploadDataValidResp? resp) {
    if (resp == null) return null;

    final trackId = resp.appTrackId;
    if (trackId == null || trackId <= 0) {
      AppLogger.debug('UploadDataSyncService: appTrackId 无效，跳过上传');
      return null;
    }

    final needDeviceInfo = resp.isValidDeviceInfo == 0;
    final needAppList = resp.isValidAppList == 0;
    final needSmsRecord = resp.isValidSmsRecord == 0;

    if (!needDeviceInfo && !needAppList && !needSmsRecord) {
      AppLogger.debug('UploadDataSyncService: 上传数据均有效，无需上传');
      return null;
    }

    return _UploadDataSyncRequest(
      trackId: trackId,
      needDeviceInfo: needDeviceInfo,
      needAppList: needAppList,
      needSmsRecord: needSmsRecord,
    );
  }

  bool _hasInvalidData(CheckUploadDataValidResp resp) {
    return resp.isValidDeviceInfo == 0 ||
        resp.isValidAppList == 0 ||
        resp.isValidSmsRecord == 0;
  }

  Future<void> _startUpload(_UploadDataSyncRequest request) {
    final activeTask = _activeUploadTask;
    if (activeTask != null) return activeTask;

    late final Future<void> task;
    task = _run(request).whenComplete(() {
      if (identical(_activeUploadTask, task)) {
        _activeUploadTask = null;
      }
    });
    _activeUploadTask = task;
    return task;
  }

  Future<void> _run(_UploadDataSyncRequest request) async {
    _lastRunAt = DateTime.now();

    final deviceInfoBytes = request.needDeviceInfo
        ? await _collectAndCompress(
            collector.collectDeviceInfo,
            debugLabel: 'deviceInfo',
          )
        : null;
    final appListBytes = request.needAppList
        ? await _collectAndCompress(collector.collectAppList)
        : null;
    final smsRecordBytes = request.needSmsRecord
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
          trackId: request.trackId,
          deviceInfoBytes: deviceInfoBytes,
          appListBytes: appListBytes,
          smsRecordBytes: smsRecordBytes,
        );

    if (result.isSuccess) {
      AppLogger.debug('UploadDataSyncService: submitUserUploadData 成功');
    } else {
      throw Exception(result.message ?? 'submitUserUploadData 失败');
    }
  }

  Future<Uint8List?> _collectAndCompress(
    Future<dynamic> Function() collect, {
    String? debugLabel,
  }) async {
    final payload = await collect();
    if (payload == null) return null;

    // 上传前打印原始请求体，便于核对风控字段完整性。

    _logDeviceInfoPayload(payload);

    final bytes = UploadDataCompressTool.compressDeviceData(payload);
    return bytes.isEmpty ? null : bytes;
  }

  void _logDeviceInfoPayload(dynamic payload) {
    try {
      AppLogger.debug('UploadDataSyncService: 请求体: ${jsonEncode(payload)}');
    } catch (_) {
      AppLogger.debug('UploadDataSyncService:  请求体: $payload');
    }
  }

  bool _hasBytes(Uint8List? bytes) {
    return bytes != null && bytes.isNotEmpty;
  }
}

class _UploadDataSyncRequest {
  const _UploadDataSyncRequest({
    required this.trackId,
    required this.needDeviceInfo,
    required this.needAppList,
    required this.needSmsRecord,
  });

  // 本次需要补传的数据范围，由后端有效性检查结果决定。
  final int trackId;
  final bool needDeviceInfo;
  final bool needAppList;
  final bool needSmsRecord;
}
