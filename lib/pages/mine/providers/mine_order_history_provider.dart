import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/order_list_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 历史订单 tab 配置，使用固定实例替代 enum，便于集中维护请求参数和展示文案。
class MineOrderHistoryTab {
  const MineOrderHistoryTab({
    required this.key,
    required this.label,
    required this.statusList,
  });

  final String key;
  final String label;
  final List<int> statusList;
}

/// 历史订单 tab 和接口状态映射。
class MineOrderHistoryTabs {
  MineOrderHistoryTabs._();

  static const String allKey = 'all';

  static List<int> get allStatusList {
    return values
        .expand((tab) => tab.statusList)
        .toSet()
        .toList(growable: false);
  }

  static const List<MineOrderHistoryTab> values = <MineOrderHistoryTab>[
    MineOrderHistoryTab(
      key: allKey,
      label: AppStrings.mineOrderHistoryAllTab,
      statusList: <int>[20, 3, 4, 5, 7, 22],
    ),
    MineOrderHistoryTab(
      key: 'disbursing',
      label: AppStrings.mineOrderHistoryDisbursingTab,
      statusList: <int>[20, 3],
    ),
    MineOrderHistoryTab(
      key: 'repaying',
      label: AppStrings.mineOrderHistoryRepayingTab,
      statusList: <int>[4],
    ),
    MineOrderHistoryTab(
      key: 'failed',
      label: AppStrings.mineOrderHistoryFailedTab,
      statusList: <int>[5, 7, 22],
    ),
  ];

  static MineOrderHistoryTab byKey(String key) {
    return values.firstWhere(
      (tab) => tab.key == key,
      orElse: () => values.first,
    );
  }

  /// 将一次接口返回的全量订单按 tab 状态拆分，避免切换 tab 时重复请求后端。
  static Map<String, List<OrderListItem>> groupOrdersByTab(
    List<OrderListItem> orders,
  ) {
    return <String, List<OrderListItem>>{
      for (final tab in values) tab.key: _filterOrdersByTab(orders, tab),
    };
  }
}

final mineOrderHistoryApiProvider = Provider<MineOrderHistoryApi>((ref) {
  return MineOrderHistoryApi();
});

final mineOrderHistoryProvider = FutureProvider.autoDispose
    .family<List<OrderListItem>, String>((ref, tabKey) async {
      final tab = MineOrderHistoryTabs.byKey(tabKey);
      final result = await ref
          .read(mineOrderHistoryApiProvider)
          .call(statusList: tab.statusList);

      if (result.isSuccess) {
        return result.data ?? const <OrderListItem>[];
      }

      throw Exception(result.message ?? AppStrings.mineOrderHistoryLoadFailed);
    });

class MineOrderHistoryApi {
  // 获取历史订单列表
  Future<HttpResult<List<OrderListItem>>> call({
    required List<int> statusList,
  }) async {
    final result = await HttpProvider.instance.post<List<dynamic>>(
      ApiConstants.userRepayment,
      data: {'statusList': statusList},
      fromJson: (json) => json as List<dynamic>,
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(_parseList(result.data!));
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? AppStrings.mineOrderHistoryLoadFailed,
    );
  }
}

List<OrderListItem> _parseList(List<dynamic> data) {
  return data
      .map((item) => OrderListItem.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<OrderListItem> _filterOrdersByTab(
  List<OrderListItem> orders,
  MineOrderHistoryTab tab,
) {
  if (tab.key == MineOrderHistoryTabs.allKey) {
    return List<OrderListItem>.unmodifiable(orders);
  }

  final statusSet = tab.statusList.toSet();
  return List<OrderListItem>.unmodifiable(
    orders.where((order) => statusSet.contains(order.orderStatus)),
  );
}
