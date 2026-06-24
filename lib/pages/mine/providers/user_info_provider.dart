import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/user_info_resp.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

final userInfoProvider = Provider<UserInfoApi>((ref) {
  return UserInfoApi();
});

class UserInfoApi {
  Future<HttpResult<UserInfoResp>> call() async {
    final result = await HttpProvider.instance.get<UserInfoResp>(
      ApiConstants.userInfoStr,
      fromJson: (json) {
        AppLogger.debug('UserInfoApi fromJson 原始数据: $json');
        AppLogger.debug('数据类型: ${json.runtimeType}');
        return UserInfoResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'UserInfoApi 返回: status=${result.status}, data=${result.data}, message=${result.message}',
    );
    return result;
  }
}
