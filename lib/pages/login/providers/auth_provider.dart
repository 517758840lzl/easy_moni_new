import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/check_upload_data_valid_resp.dart';
import 'package:easy_moni/entities/login_resp.dart';
import 'package:easy_moni/entities/startup_config_resp.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';

final sendVerifyCodeProvider = Provider<SendVerifyCodeApi>((ref) {
  return SendVerifyCodeApi();
});

final loginApiProvider = Provider<LoginApi>((ref) {
  return LoginApi();
});

final checkUploadDataValidProvider = Provider<CheckUploadDataValidApi>((ref) {
  return CheckUploadDataValidApi();
});

final startupConfigProvider = Provider<StartupConfigApi>((ref) {
  return StartupConfigApi();
});

class SendVerifyCodeApi {
  /// 发送验证码
  Future<HttpResult<dynamic>> call(String phone) async {
    final requestBody = {'phone': phone, 'type': 'phone'};
    final requestHeaders = HttpProvider.instance.config.commonHeaders();

    await AfTracker.logActionEvent(
      TrackEvents.registerApply,
      body: requestBody,
      heads: requestHeaders,
    );

    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.sendVerifyCode,
      data: requestBody,
      includeToken: false,
      fromJson: (json) => json,
    );
    await AfTracker.logActionEvent(
      TrackEvents.registerApplyResult,
      msg: _httpResultLogValue(result),
    );
    return result;
  }
}

class LoginApi {
  Future<HttpResult<LoginResp>> call({
    required String phone,
    required String code,
  }) async {
    final config = HttpProvider.instance.config;
    final requestBody = await config.loginParams(
      phone: phone,
      authCode: code,
      deviceId: HttpProvider.instance.deviceId,
    );
    await AfTracker.logActionEvent(TrackEvents.otpApply, body: requestBody);

    final result = await HttpProvider.instance.post<LoginResp>(
      ApiConstants.login,
      data: requestBody,
      includeToken: false,
      fromJson: (json) {
        // 调试：打印原始数据
        AppLogger.debug('LoginApi fromJson 原始数据: $json');
        AppLogger.debug('数据类型: ${json.runtimeType}');
        return LoginResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'LoginApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    await AfTracker.logActionEvent(
      TrackEvents.otpApplyResult,
      msg: {
        ..._httpResultLogValue(result),
        if (result.data != null) 'data': result.data!.toJson(),
      },
    );
    return result;
  }
}

Map<String, dynamic> _httpResultLogValue(HttpResult<dynamic> result) {
  return {
    'isSuccess': result.isSuccess,
    'status': result.status,
    'statusCode': result.statusCode,
    'message': result.message,
  };
}

class CheckUploadDataValidApi {
  Future<HttpResult<CheckUploadDataValidResp>> call() async {
    final result = await HttpProvider.instance.get<CheckUploadDataValidResp>(
      ApiConstants.checkUploadDataValid,
      fromJson: (json) {
        AppLogger.debug('CheckUploadDataValidApi fromJson 原始数据: $json');
        AppLogger.debug('数据类型: ${json.runtimeType}');
        return CheckUploadDataValidResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'CheckUploadDataValidApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}

class StartupConfigApi {
  Future<HttpResult<StartupConfigResp>> call() async {
    final result = await HttpProvider.instance.post<StartupConfigResp>(
      ApiConstants.startupConfig,
      fromJson: (json) {
        AppLogger.debug('StartupConfigApi fromJson 原始数据: $json');
        AppLogger.debug('数据类型: ${json.runtimeType}');
        return StartupConfigResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'StartupConfigApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}
