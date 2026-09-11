import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/login_resp.dart';
import 'package:easy_moni/entities/startup_config_resp.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';

final sendVerifyCodeProvider = Provider<SendVerifyCodeApi>((ref) {
  return SendVerifyCodeApi();
});

final loginApiProvider = Provider<LoginApi>((ref) {
  return LoginApi();
});

final startupConfigProvider = Provider<StartupConfigApi>((ref) {
  return StartupConfigApi();
});

class SendVerifyCodeApi {
  Future<HttpResult<dynamic>> call(String phone) async {
    final requestBody = {'phone': phone, 'type': 'phone'};
    final requestHeaders = HttpProvider.instance.config.commonHeaders();

    await AppsFlyerTracker.logAppsFlyerActionEvent(
      AppsFlyerEventNames.easRegisterApply,
      body: requestBody,
      heads: requestHeaders,
    );

    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.sendVerifyCode,
      data: requestBody,
      includeToken: false,
      fromJson: (json) => json,
    );
    await AppsFlyerTracker.logAppsFlyerActionEvent(
      AppsFlyerEventNames.easRegisterApplyResult,
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
    await AppsFlyerTracker.logAppsFlyerActionEvent(
      AppsFlyerEventNames.easOtpApply,
      body: requestBody,
    );

    final result = await HttpProvider.instance.post<LoginResp>(
      ApiConstants.login,
      data: requestBody,
      includeToken: false,
      fromJson: (json) {
        return LoginResp.fromJson(json);
      },
    );
    await AppsFlyerTracker.logAppsFlyerActionEvent(
      AppsFlyerEventNames.easOtpApplyResult,
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

class StartupConfigApi {
  Future<HttpResult<StartupConfigResp>> call() async {
    final result = await HttpProvider.instance.post<StartupConfigResp>(
      ApiConstants.startupConfig,
      fromJson: (json) {
        return StartupConfigResp.fromJson(json);
      },
    );
    return result;
  }
}
