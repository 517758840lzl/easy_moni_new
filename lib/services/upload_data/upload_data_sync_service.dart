import 'dart:async';

import 'package:easy_moni/pages/login/providers/upload_data_provider.dart';
import 'package:easy_moni/services/upload_data/upload_track_id_store.dart';
import 'package:easy_moni/services/upload_data/user_upload_data_collector.dart';
import 'package:easy_moni/services/user_info_cache.dart';
import 'package:easy_moni/utils/upload_data_compress_tool.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadDataSyncServiceProvider = Provider<UploadDataSyncService>((ref) {
  return UploadDataSyncService(
    ref: ref,
    collector: UserUploadDataCollector(),
  );
});

class UploadDataSyncService {
  UploadDataSyncService({required this.ref, required this.collector});

  final Ref ref;
  final UserUploadDataCollector collector;

  Future<void>? _activeUploadTask;

  Future<int?> resolveTrackId() async {
    final cachedTrackId = UploadTrackIdStore.value;
    if (cachedTrackId != null && cachedTrackId > 0) {
      return cachedTrackId;
    }

    final userInfo = await UserInfoCache.load();
    final userId = userInfo?.userId;
    if (userId != null && userId > 0) {
      UploadTrackIdStore.save(userId);
      return userId;
    }
    return null;
  }

  void uploadDeviceInfoInBackground(int trackId) {
    unawaited(
      uploadDeviceInfo(trackId).catchError((Object error, StackTrace stackTrace) {
      }),
    );
  }

  Future<void> uploadDeviceInfo(int trackId) async {
    if (trackId <= 0) {
      throw Exception('invalid trackId');
    }

    final activeTask = _activeUploadTask;
    if (activeTask != null) {
      await activeTask.catchError((_) {});
    }

    await _startUpload(trackId);
  }

  Future<void> _startUpload(int trackId) {
    final activeTask = _activeUploadTask;
    if (activeTask != null) return activeTask;

    late final Future<void> task;
    task = _run(trackId).whenComplete(() {
      if (identical(_activeUploadTask, task)) {
        _activeUploadTask = null;
      }
    });
    _activeUploadTask = task;
    return task;
  }

  Future<void> _run(int trackId) async {
    final deviceInfoBytes = await _collectAndCompressBase64(
      collector.collectDeviceInfo,
    );

    if (!_hasPayload(deviceInfoBytes)) {
      return;
    }

    final result = await ref
        .read(submitUserUploadDataProvider)
        .call(
          trackId: trackId,
          deviceInfoBytes: deviceInfoBytes,
        );

    if (!result.isSuccess) {
      throw Exception(result.message ?? 'submitUserUploadData failed');
    }
  }

  Future<String?> _collectAndCompressBase64(
    Future<dynamic> Function() collect,
  ) async {
    final payload = await collect();
    if (payload == null) return null;

    final encoded = UploadDataCompressTool.compressDeviceDataBase64(payload);
    return encoded.isEmpty ? null : encoded;
  }

  bool _hasPayload(String? value) {
    return value != null && value.isNotEmpty;
  }
}
