import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/provinces_cities_area_resp.dart';

final provincesCitiesAreaProvider = Provider<ProvincesCitiesAreaApi>((ref) {
  return ProvincesCitiesAreaApi();
});

class ProvincesCitiesAreaApi {
  /// 查询地区和城市接口
  Future<HttpResult<ProvincesCitiesAreaResp>> call() async {
    final result = await HttpProvider.instance.get<ProvincesCitiesAreaResp>(
      ApiConstants.queryProvincesCitiesArea,
      fromJson: (json) => ProvincesCitiesAreaResp.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }
}
