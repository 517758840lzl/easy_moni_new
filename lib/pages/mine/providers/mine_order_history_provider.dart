import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/order_list_resp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MineOrderHistoryTabs {
  MineOrderHistoryTabs._();

  static const String allKey = 'all';

  static const List<MineOrderHistoryTab> values = <MineOrderHistoryTab>[
    MineOrderHistoryTab(
      key: allKey,
      label: AppStrings.mineOrderHistoryAllTab,
      statusList: <int>[20, 3, 4, 5],
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
    // MineOrderHistoryTab(
    //   key: 'failed',
    //   label: AppStrings.mineOrderHistoryFailedTab,
    //   statusList: <int>[5, 22],
    // ),
  ];

  static MineOrderHistoryTab byKey(String key) {
    return values.firstWhere(
      (tab) => tab.key == key,
      orElse: () => values.first,
    );
  }

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
      final result = await ref.read(mineOrderHistoryApiProvider).call();

      if (result.isSuccess) {
        return _filterOrdersByTab(result.data ?? const <OrderListItem>[], tab);
      }

      throw Exception(result.message ?? AppStrings.mineOrderHistoryLoadFailed);
    });

class MineOrderHistoryApi {
  Future<HttpResult<List<OrderListItem>>> call() async {
    final result = await HttpProvider.instance.post<List<dynamic>>(
      ApiConstants.userRepayment,
      data: {'statusList': const <int>[]},
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
  final statusSet = tab.statusList.toSet();
  return List<OrderListItem>.unmodifiable(
    orders.where((order) => statusSet.contains(order.orderStatus)),
  );
}
