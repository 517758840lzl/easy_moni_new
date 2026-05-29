import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';

final sendVerifyCodeProvider = Provider<SendVerifyCodeApi>((ref) {
  return SendVerifyCodeApi();
});

final loginApiProvider = Provider<LoginApi>((ref) {
  return LoginApi();
});

class SendVerifyCodeApi {
  /// 发送验证码
  /// [phone] 格式: "233|502111111"
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
  /// 登录接口
  /// [phone] 手机号
  /// [code] 验证码
  Future<HttpResult<dynamic>> call({
    required String phone,
    required String code,
  }) async {
    final result = await HttpProvider.instance.post<dynamic>(
      ApiConstants.login,
      data: {
        'phone': phone,
        'code': code,
      },
      fromJson: (json) => json,
    );
    return result;
  }
}
