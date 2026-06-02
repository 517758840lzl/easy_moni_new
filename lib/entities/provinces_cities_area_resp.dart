class ProvincesCitiesAreaResp {
  final List<AreaItem> province;
  final List<AreaItem> city;

  const ProvincesCitiesAreaResp({
    required this.province,
    required this.city,
  });

  factory ProvincesCitiesAreaResp.fromJson(Map<String, dynamic> json) {
    final source = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return ProvincesCitiesAreaResp(
      province: (source['province'] as List<dynamic>?)
              ?.map((e) => AreaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      city: (source['city'] as List<dynamic>?)
              ?.map((e) => AreaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AreaItem {
  final int id;
  final String name;
  final int parentId;

  const AreaItem({
    required this.id,
    required this.name,
    required this.parentId,
  });

  factory AreaItem.fromJson(Map<String, dynamic> json) {
    return AreaItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      parentId: json['parentId'] as int? ?? 0,
    );
  }
}
