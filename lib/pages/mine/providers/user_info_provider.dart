import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/user_info_resp.dart';

import 'package:easy_moni/services/user_info_cache.dart';

final userInfoProvider = Provider<UserInfoApi>((ref) {
  return UserInfoApi();
});

class UserInfoApi {
  Future<HttpResult<UserInfoResp>> call() async {
    final cached = await UserInfoCache.load();
    if (cached != null) {
      return HttpResult.success(cached);
    }

    final result = await HttpProvider.instance.get<UserInfoResp>(
      ApiConstants.userInfoStr,
      fromJson: (json) {
        return UserInfoResp.fromJson(json);
      },
    );

    if (result.isSuccess && result.data != null) {
      await UserInfoCache.save(result.data!);
    }

    return result;
  }
}
