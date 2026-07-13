import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/user_info_resp.dart';

final userInfoProvider = Provider<UserInfoApi>((ref) {
  return UserInfoApi();
});

class UserInfoApi {
  Future<HttpResult<UserInfoResp>> call() async {
    final result = await HttpProvider.instance.get<UserInfoResp>(
      ApiConstants.userInfoStr,
      fromJson: (json) {
        return UserInfoResp.fromJson(json);
      },
    );
    return result;
  }
}
