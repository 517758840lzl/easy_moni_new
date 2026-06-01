import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/provinces_cities_area_resp.dart';

final provincesCitiesAreaProvider = Provider<ProvincesCitiesAreaApi>((ref) {
  return ProvincesCitiesAreaApi();
});

class ProvincesCitiesAreaApi {
  /// 查询地区和城市接口（测试用假数据）
  Future<HttpResult<ProvincesCitiesAreaResp>> call() async {
    //   final result = await HttpProvider.instance.get<ProvincesCitiesAreaResp>(
    //     ApiConstants.queryProvincesCitiesArea,
    //     fromJson: (json) => ProvincesCitiesAreaResp.fromJson(json as Map<String, dynamic>),
    // return result;
    // 返回假数据用于测试
    final mockData = ProvincesCitiesAreaResp(
      province: [
        AreaItem(id: 1, name: 'Greater Accra', parentId: 0),
        AreaItem(id: 2, name: 'Ashanti', parentId: 0),
        AreaItem(id: 3, name: 'Central', parentId: 0),
        AreaItem(id: 4, name: 'Eastern', parentId: 0),
        AreaItem(id: 5, name: 'Western', parentId: 0),
        AreaItem(id: 6, name: 'Volta', parentId: 0),
        AreaItem(id: 7, name: 'Northern', parentId: 0),
        AreaItem(id: 8, name: 'Upper East', parentId: 0),
        AreaItem(id: 9, name: 'Upper West', parentId: 0),
        AreaItem(id: 10, name: 'Brong-Ahafo', parentId: 0),
      ],
      city: [
        AreaItem(id: 101, name: 'Accra', parentId: 1),
        AreaItem(id: 102, name: 'Tema', parentId: 1),
        AreaItem(id: 103, name: 'Kumasi', parentId: 2),
        AreaItem(id: 104, name: 'Obuasi', parentId: 2),
        AreaItem(id: 105, name: 'Cape Coast', parentId: 3),
        AreaItem(id: 106, name: 'Koforidua', parentId: 4),
        AreaItem(id: 107, name: 'Takoradi', parentId: 5),
        AreaItem(id: 108, name: 'Ho', parentId: 6),
        AreaItem(id: 109, name: 'Tamale', parentId: 7),
      ],
    );

    return HttpResult.success(mockData);
  }
}
