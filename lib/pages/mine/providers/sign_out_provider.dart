import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/sign_out_resp.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

final signOutProvider = Provider<SignOutApi>((ref) {
  return SignOutApi();
});

class SignOutApi {
  Future<HttpResult<SignOutResp>> call() async {
    final result = await HttpProvider.instance.post<SignOutResp>(
      ApiConstants.signOut,
      fromJson: (json) {
        AppLogger.debug('SignOutApi fromJson 原始数据: $json');
        return SignOutResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'SignOutApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}
