import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/sign_out_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountProvider = Provider<DeleteAccountApi>((ref) {
  return DeleteAccountApi();
});

/// 注销账号接口，负责调用后端删除当前登录用户账号。
class DeleteAccountApi {
  Future<HttpResult<SignOutResp>> call() async {
    final result = await HttpProvider.instance.post<SignOutResp>(
      ApiConstants.logout,
      fromJson: (json) {
        return SignOutResp.fromJson(json);
      },
    );
    return result;
  }
}
