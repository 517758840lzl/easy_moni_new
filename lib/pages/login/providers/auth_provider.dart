import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/login_resp.dart';

final sendVerifyCodeProvider = Provider<SendVerifyCodeApi>((ref) {
  return SendVerifyCodeApi();
});

final loginApiProvider = Provider<LoginApi>((ref) {
  return LoginApi();
});

class SendVerifyCodeApi {
  /// 发送验证码
  Future<HttpResult<dynamic>> call(String phone) async {
    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.sendVerifyCode,
      data: {
        'phone': phone,
        'type': 'phone',
      },
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
        "afid":"1779953073476-180350146959368781",
        "mediaSource":"",
        "appVersion":'1.0',
        "deviceId":"7da8118f936659a7",
        "utm_source":"google-play",
      },
      fromJson: (json) {
        // 调试：打印原始数据
        debugPrint('LoginApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return LoginResp.fromJson(json);
      },
    );
    debugPrint('LoginApi 返回: status=${result.status}, data=${result.data}, message=${result.message}');
    return result;
  }
}
