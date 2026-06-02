import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/login_resp.dart';
import '../../../entities/check_upload_data_valid_resp.dart';
import '../../../entities/startup_config_resp.dart';

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
    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.sendVerifyCode,
      data: {'phone': phone, 'type': 'phone'},
      includeToken: false,
      fromJson: (json) => json,
    );
    return result;
  }
}

class LoginApi {
  Future<HttpResult<LoginResp>> call({
    required String phone,
    required String code,
  }) async {
    final result = await HttpProvider.instance.post<LoginResp>(
      ApiConstants.login,
      data: {
        'phone': phone,
        'authCode': code,
        'afid': '1779953073476-180350146959368781',
        'appVersion': '1',
        'clientType': 'android',
        'deviceId': '7da8118f936659a7',
        'gaid': 'be1089a1-dc4b-4684-9882-2d670a214784',
        'mediaSource': '',
        'onlyLogin': 0,
        'referrer': 'utm_source=google-play&utm_medium=organic',
        'userAgent': 'SM-A136U',
      },
      includeToken: false,
      fromJson: (json) {
        // 调试：打印原始数据
        debugPrint('LoginApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return LoginResp.fromJson(json);
      },
    );
    debugPrint(
      'LoginApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}

class CheckUploadDataValidApi {
  Future<HttpResult<CheckUploadDataValidResp>> call() async {
    final result = await HttpProvider.instance.get<CheckUploadDataValidResp>(
      ApiConstants.checkUploadDataValid,
      fromJson: (json) {
        debugPrint('CheckUploadDataValidApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return CheckUploadDataValidResp.fromJson(json);
      },
    );
    debugPrint(
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
        debugPrint('StartupConfigApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return StartupConfigResp.fromJson(json);
      },
    );
    debugPrint(
      'StartupConfigApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}
