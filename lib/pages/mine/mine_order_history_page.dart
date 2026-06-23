import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/order_list_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/pages/mine/components/mine_order_summary_card.dart';
import 'package:easy_moni/pages/mine/providers/mine_order_history_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 历史订单页面，负责 tab 切换、接口加载状态和订单列表展示。
class MineOrderHistoryPage extends ConsumerStatefulWidget {
  const MineOrderHistoryPage({super.key});

  @override
  ConsumerState<MineOrderHistoryPage> createState() =>
      _MineOrderHistoryPageState();
}

class _MineOrderHistoryPageState extends ConsumerState<MineOrderHistoryPage> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String _loadError = '';
  Map<String, List<OrderListItem>> _ordersByTab =
      MineOrderHistoryTabs.groupOrdersByTab(const <OrderListItem>[]);

  MineOrderHistoryTab get _selectedTab {
    return MineOrderHistoryTabs.values[_selectedTabIndex];
  }

  List<OrderListItem> get _selectedOrders {
    return _ordersByTab[_selectedTab.key] ?? const <OrderListItem>[];
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _onTabTap(int index) {
    if (index == _selectedTabIndex) return;
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = '';
      });
    }

    final result = await ref
        .read(mineOrderHistoryApiProvider)
        .call(statusList: MineOrderHistoryTabs.allStatusList);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _ordersByTab = MineOrderHistoryTabs.groupOrdersByTab(
          result.data ?? const <OrderListItem>[],
        );
        _isLoading = false;
        _loadError = '';
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _loadError = result.message ?? AppStrings.mineOrderHistoryLoadFailed;
    });
  }

  Future<void> _refreshOrders() async {
    await _loadOrders(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 108,
      contentTopRadius: 12,
      backgroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF288572), Color(0xFF226B4B)],
        ),
      ),
      header: _MineOrderHistoryHeader(
        tabs: MineOrderHistoryTabs.values,
        selectedIndex: _selectedTabIndex,
        itemCounts: _buildTabItemCounts(),
        onTap: _onTabTap,
      ),
      content: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const _MineOrderHistoryScrollableStateView(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError.isNotEmpty) {
      return _MineOrderHistoryScrollableStateView(
        icon: Icons.error_outline_rounded,
        text: AppStrings.mineOrderHistoryLoadFailed,
        actionText: AppStrings.mineOrderHistoryRetry,
        onActionTap: _loadOrders,
      );
    }

    return _MineOrderHistoryList(
      orders: _selectedOrders,
      onOrderTap: _openOrderDetail,
    );
  }

  Map<String, int> _buildTabItemCounts() {
    return <String, int>{
      for (final tab in MineOrderHistoryTabs.values)
        tab.key: _ordersByTab[tab.key]?.length ?? 0,
    };
  }

  void _openOrderDetail(OrderListItem order) {
    final detailData = LoanOrderDetailData.fromOrderListItem(order);
    if (detailData.appOrderId.isEmpty) return;

    context.push(AppRoutePaths.loanOrderDetail, extra: detailData);
  }
}

class _MineOrderHistoryHeader extends StatelessWidget {
  const _MineOrderHistoryHeader({
    required this.tabs,
    required this.selectedIndex,
    required this.itemCounts,
    required this.onTap,
  });

  final List<MineOrderHistoryTab> tabs;
  final int selectedIndex;
  final Map<String, int> itemCounts;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.mineAnthBg.provider(),
           fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Text(
                    AppStrings.mineOrderHistoryTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 20 / 16,
                    ),
                  ),
                  Positioned(
                    right: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push(AppRoutePaths.customerService),
                      child: Assets.images.customer.image(width: 32, height: 32),
                    ),
                  ),
                ],
              ),
            ),
            _MineOrderHistoryTabBar(
              tabs: tabs,
              selectedIndex: selectedIndex,
              itemCounts: itemCounts,
              onTap: onTap,
            ),
            const SizedBox(height: 8,)
          ],
        ),
      ),
    );
  }
}

class _MineOrderHistoryTabBar extends StatelessWidget {
  const _MineOrderHistoryTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.itemCounts,
    required this.onTap,
  });

  final List<MineOrderHistoryTab> tabs;
  final int selectedIndex;
  final Map<String, int> itemCounts;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: _MineOrderHistoryTabItem(
              label: tabs[index].label,
              itemCount: itemCounts[tabs[index].key] ?? 0,
              selected: selected,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }
}

class _MineOrderHistoryTabItem extends StatelessWidget {
  const _MineOrderHistoryTabItem({
    required this.label,
    required this.itemCount,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int itemCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      height: 18 / 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    AppStrings.mineOrderHistoryTabCount(itemCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      height: 18 / 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineOrderHistoryList extends StatelessWidget {
  const _MineOrderHistoryList({required this.orders, required this.onOrderTap});

  final List<OrderListItem> orders;
  final ValueChanged<OrderListItem> onOrderTap;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _MineOrderHistoryScrollableStateView(
        icon: Icons.receipt_long_outlined,
        text: AppStrings.mineOrderHistoryEmpty,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        10,
        10,
        10,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return MineOrderSummaryCard(
          productName: _valueOrEmpty(order.productName),
          productLogo: order.productLogo,
          statusCode: order.orderStatus,
          remainingDays: order.remainingDays,
          columns: _buildOrderInfoColumns(order),
          onTap: () => onOrderTap(order),
        );
      },
    );
  }
}

/// 历史订单卡片状态码，集中维护后便于和接口约定核对。
class _MineOrderHistoryStatusCodes {
  const _MineOrderHistoryStatusCodes._();

  static const int reviewing = 20;
  static const int disbursing = 3;
  static const int waitingRepayment = 4;
  static const int transferFailed = 5;

  static bool usesDisbursementColumns(int? statusCode) {
    return statusCode == reviewing ||
        statusCode == disbursing ||
        statusCode == transferFailed;
  }
}

/// 根据订单状态组装卡片摘要字段，状态 4 需要额外区分是否已逾期。
List<MineOrderSummaryCardColumnData> _buildOrderInfoColumns(
  OrderListItem order,
) {
  final orderStatus = order.orderStatus;
  final remainingDays = order.remainingDays;
  final dueDate = _formatDate(order.repayDateStr ?? order.repayDate);

  if (orderStatus == _MineOrderHistoryStatusCodes.waitingRepayment) {
    final baseColumns = [
      _loanAmountColumn(order),
      MineOrderSummaryCardColumnData(
        label: AppStrings.loanOrderRepayAmountLabel,
        value: (order.repayAmount ?? 0).formatAmount(),
      ),
    ];

    if (remainingDays != null && remainingDays < 0) {
      return [
        ...baseColumns,
        MineOrderSummaryCardColumnData(
          label: AppStrings.loanOrderOverdueDaysLabel,
          value: AppStrings.orderDetailDayValue(remainingDays.abs()),
        ),
        MineOrderSummaryCardColumnData(
          label: AppStrings.loanOrderDueDateLabel,
          value: dueDate,
        ),
      ];
    }

    return [
      ...baseColumns,
      MineOrderSummaryCardColumnData(
        label: AppStrings.loanOrderDueDateLabel,
        value: dueDate,
      ),
    ];
  }

  if (_MineOrderHistoryStatusCodes.usesDisbursementColumns(orderStatus)) {
    return _buildDisbursementColumns(order);
  }

  return _buildDisbursementColumns(order);
}

MineOrderSummaryCardColumnData _loanAmountColumn(OrderListItem order) {
  return MineOrderSummaryCardColumnData(
    label: AppStrings.loanOrderLoanAmountLabel,
    value: (order.loanAmount ?? 0).formatAmount(),
  );
}

List<MineOrderSummaryCardColumnData> _buildDisbursementColumns(
  OrderListItem order,
) {
  return [
    _loanAmountColumn(order),
    MineOrderSummaryCardColumnData(
      label: AppStrings.loanOrderReceiptAmountLabel,
      value: (order.receiptAmount ?? 0).formatAmount(),
    ),
    // TODO 借款日期暂时使用 createTime
    MineOrderSummaryCardColumnData(
      label: AppStrings.mineOrderLoanDateLabel,
      value: _formatDate(order.createTime),
    ),
  ];
}

class _MineOrderHistoryScrollableStateView extends StatelessWidget {
  const _MineOrderHistoryScrollableStateView({
    this.child,
    this.icon,
    this.text = '',
    this.actionText = '',
    this.onActionTap,
  });

  final Widget? child;
  final IconData? icon;
  final String text;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child:
                  child ??
                  _MineOrderHistoryStateView(
                    icon: icon,
                    text: text,
                    actionText: actionText,
                    onActionTap: onActionTap,
                  ),
            ),
          ),
        );
      },
    );
  }
}

class _MineOrderHistoryStateView extends StatelessWidget {
  const _MineOrderHistoryStateView({
    this.icon,
    this.text = '',
    this.actionText = '',
    this.onActionTap,
  });

  final IconData? icon;
  final String text;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 54, color: const Color(0xFFACACAC)),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF787878),
              height: 20 / 14,
            ),
          ),
        ],
        if (actionText.isNotEmpty && onActionTap != null) ...[
          const SizedBox(height: 16),
          TextButton(onPressed: onActionTap, child: Text(actionText)),
        ],
      ],
    );
  }
}

String _valueOrEmpty(String? value) {
  return value?.trim() ?? '';
}

String _formatDate(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return '';

  final datePart = trimmed.contains(' ') ? trimmed.split(' ').first : trimmed;
  return datePart.formatBackendDate();
}
