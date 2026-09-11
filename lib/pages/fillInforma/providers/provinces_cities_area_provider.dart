import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/provinces_cities_area_resp.dart';

final provincesCitiesAreaProvider = Provider<ProvincesCitiesAreaApi>((ref) {
  return ProvincesCitiesAreaApi();
});

class ProvincesCitiesAreaApi {
  Future<HttpResult<ProvincesCitiesAreaResp>> call() async {
    return HttpProvider.instance.get<ProvincesCitiesAreaResp>(
      ApiConstants.queryProvincesCitiesArea,
      fromJson: (json) =>
          ProvincesCitiesAreaResp.fromJson(json as Map<String, dynamic>),
    );
  }
}
