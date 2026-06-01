import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/user_info_resp.dart';

final userInfoProvider = Provider<UserInfoApi>((ref) {
  return UserInfoApi();
});

class UserInfoApi {
  Future<HttpResult<UserInfoResp>> call() async {
    final result = await HttpProvider.instance.get<UserInfoResp>(
      ApiConstants.userInfoStr,
      fromJson: (json) {
        debugPrint('UserInfoApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return UserInfoResp.fromJson(json);
      },
    );
    debugPrint('UserInfoApi 返回: status=${result.status}, data=${result.data}, message=${result.message}');
    return result;
  }
}
