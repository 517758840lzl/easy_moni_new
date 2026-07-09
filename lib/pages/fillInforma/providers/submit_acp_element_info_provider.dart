import 'dart:convert';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/submit_acp_info_resp.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';

final submitAcpElementInfoProvider = Provider<SubmitAcpElementInfoApi>((ref) {
  return SubmitAcpElementInfoApi();
});

class SubmitAcpElementInfoApi {
  /// 提交KYC步骤数据
  /// [processId] 流程ID
  /// [step] 步骤
  /// [jsonParam] 按文档格式提交的字段列表
  Future<HttpResult<SubmitAcpInfoResp>> call({
    required int processId,
    required int step,
    List<Map<String, dynamic>>? jsonParam,
    Map<String, dynamic>? data,
    int isUpdate = 0,
  }) async {
    final requestBody = jsonParam != null
        ? {
            'isUpdate': isUpdate,
            'jsonParam': jsonParam,
            'processId': processId,
            'step': step,
          }
        : {
            'processId': processId,
            'step': step,
            'data': data ?? <String, dynamic>{},
          };
    AppLogger.debug(
      'submitAcpElementInfo requestBody: ${jsonEncode(requestBody)}',
    );

    final result = await HttpProvider.instance.post<SubmitAcpInfoResp>(
      ApiConstants.submitAcpElementInfo,
      data: requestBody,
      fromJson: SubmitAcpInfoResp.fromJson,
    );
    final submitData = result.data;
    if (result.isSuccess &&
        submitData != null &&
        AcquisitionProgressRouteResolver.resolveSubmitResult(submitData) ==
            AppRoutePaths.home) {
      await AppsFlyerTracker.logAppsFlyerActionEvent(
        AppsFlyerEventNames.easAutoOrder,
      );
    }
    return result;
  }
}
