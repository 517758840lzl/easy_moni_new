import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/home_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
