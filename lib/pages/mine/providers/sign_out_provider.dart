import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/sign_out_resp.dart';

final signOutProvider = Provider<SignOutApi>((ref) {
  return SignOutApi();
});

class SignOutApi {
  Future<HttpResult<SignOutResp>> call() async {
    final result = await HttpProvider.instance.post<SignOutResp>(
      ApiConstants.signOut,
      fromJson: (json) {
        return SignOutResp.fromJson(json);
      },
    );
    return result;
  }
}
