import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/sign_out_resp.dart';

final signOutProvider = Provider<SignOutApi>((ref) {
  return SignOutApi();
});

class SignOutApi {
  Future<HttpResult<SignOutResp>> call() async {
    final result = await HttpProvider.instance.post<SignOutResp>(
      ApiConstants.signOut,
      fromJson: (json) {
        debugPrint('SignOutApi fromJson 原始数据: $json');
        debugPrint('数据类型: ${json.runtimeType}');
        return SignOutResp.fromJson(json);
      },
    );
    debugPrint('SignOutApi 返回: status=${result.status}, data=${result.data}, message=${result.message}');
    return result;
  }
}
