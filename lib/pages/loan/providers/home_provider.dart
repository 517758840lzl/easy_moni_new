import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

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
        AppLogger.debug('HomeApi fromJson: $json');
        return HomeResp.fromJson(json);
      },
    );
    AppLogger.debug(
      'HomeApi 返回: status=${result.status}, message=${result.message}',
    );
    return result;
  }
}
