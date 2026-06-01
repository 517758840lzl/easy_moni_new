import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../entities/home_resp.dart';

final homeProvider = Provider<HomeApi>((ref) => HomeApi());

class HomeApi {
  Future<HttpResult<HomeResp>> call() async {
    final result = await HttpProvider.instance.get<HomeResp>(
      ApiConstants.home,
      fromJson: (json) {
        debugPrint('HomeApi fromJson: $json');
        return HomeResp.fromJson(json);
      },
    );
    debugPrint(
      'HomeApi 返回: status=${result.status}, message=${result.message}',
    );
    return result;
  }
}
