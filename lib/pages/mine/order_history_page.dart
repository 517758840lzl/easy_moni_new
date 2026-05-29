import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../gen/assets.gen.dart';
import 'order_detail_page.dart';

// 订单状态枚举
enum OrderStatus {
  all,       // 全部
  borrowing,  // 借款中
  pending,   // 待还款
  failed,    // 放款失败
}

// 订单状态标签
enum StatusTag {
  borrowing,   // 放款中 - 橙色
  pending,     // 待还款 - 橙色
  overdue,     // 已逾期 - 红色
  failed,      // 放款失败 - 灰色
  repaid,      // 已还款 - 绿色
}

// 订单数据模型
class OrderItem {
  final String id;
  final String productName;
  final double borrowAmount;
  final double arrivalAmount;
  final String borrowDate;
  final StatusTag statusTag;

  OrderItem({
    required this.id,
    required this.productName,
    required this.borrowAmount,
    required this.arrivalAmount,
    required this.borrowDate,
    required this.statusTag,
  });
}

// 模拟数据
final List<OrderItem> _mockOrders = [
  OrderItem(
    id: '1',
    productName: 'Palm Loa',
    borrowAmount: 100,
    arrivalAmount: 110,
    borrowDate: '25/05/2026',
    statusTag: StatusTag.borrowing,
  ),
  OrderItem(
    id: '2',
    productName: 'Palm Loa',
    borrowAmount: 100,
    arrivalAmount: 110,
    borrowDate: '25/05/2026',
    statusTag: StatusTag.borrowing,
  ),
  OrderItem(
    id: '3',
    productName: 'Palm Loa',
    borrowAmount: 100,
    arrivalAmount: 110,
    borrowDate: '25/05/2026',
    statusTag: StatusTag.pending,
  ),
  OrderItem(
    id: '4',
    productName: 'Palm Loa',
    borrowAmount: 100,
    arrivalAmount: 110,
    borrowDate: '25/05/2026',
    statusTag: StatusTag.pending,
  ),
  OrderItem(
    id: '5',
    productName: 'Palm Loa',
    borrowAmount: 100,
    arrivalAmount: 110,
    borrowDate: '25/05/2026',
    statusTag: StatusTag.failed,
  ),
];

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  OrderStatus _currentStatus = OrderStatus.all;
  List<OrderItem> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      if (_currentStatus == OrderStatus.all) {
        _orders = _mockOrders;
      } else if (_currentStatus == OrderStatus.borrowing) {
        _orders = _mockOrders.where((o) => o.statusTag == StatusTag.borrowing).toList();
      } else if (_currentStatus == OrderStatus.pending) {
        _orders = _mockOrders.where((o) => o.statusTag == StatusTag.pending).toList();
      } else if (_currentStatus == OrderStatus.failed) {
        _orders = _mockOrders.where((o) => o.statusTag == StatusTag.failed).toList();
      }
    });
  }

  void _onTabChanged(OrderStatus status) {
    if (_currentStatus != status) {
      setState(() {
        _currentStatus = status;
      });
      _loadOrders();
    }
  }

  DetailStatus _convertToDetailStatus(StatusTag tag) {
    switch (tag) {
      case StatusTag.borrowing:
        return DetailStatus.borrowing;
      case StatusTag.pending:
      case StatusTag.overdue:
        return DetailStatus.overdue;
      case StatusTag.failed:
        return DetailStatus.waiting;
      case StatusTag.repaid:
        return DetailStatus.borrowing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          // 顶部背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF288571), Color(0xFF216A4B)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop())
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          ),
                        const Expanded(
                          child: Text(
                            '历史订单',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Assets.images.customer.image(width: 28, height: 28),
                        // const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Tab 标签
                  _buildTabBar(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // 订单列表
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: _orders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrderList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final allCount = _mockOrders.length;
    final borrowingCount = _mockOrders.where((o) => o.statusTag == StatusTag.borrowing).length;
    final pendingCount = _mockOrders.where((o) => o.statusTag == StatusTag.pending).length;
    final failedCount = _mockOrders.where((o) => o.statusTag == StatusTag.failed).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _buildTabItem('全部（$allCount）', OrderStatus.all),
          const SizedBox(width: 17),
          _buildTabItem('借款中（$borrowingCount）', OrderStatus.borrowing),
          const SizedBox(width: 17),
          _buildTabItem('待还款（$pendingCount）', OrderStatus.pending),
          const SizedBox(width: 17),
          _buildTabItem('放款失败（$failedCount）', OrderStatus.failed),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, OrderStatus status) {
    final isSelected = _currentStatus == status;
    return GestureDetector(
      onTap: () => _onTabChanged(status),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFFACACAC),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFACACAC)),
          SizedBox(height: 16),
          Text(
            '暂无订单记录',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFACACAC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 13),
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    return GestureDetector(
      onTap: () {
        final orderData = OrderData(
          id: order.id,
          productName: order.productName,
          borrowAmount: order.borrowAmount,
          arrivalAmount: order.arrivalAmount,
          interest: order.borrowAmount * 0.1, // 模拟利息
          repayAmount: order.borrowAmount * 1.1, // 模拟应还
          borrowDays: 7,
          borrowDate: order.borrowDate,
          dueDate: order.borrowDate, // 模拟
          momoAccount: '2345676543',
          walletType: 'Vodafone Cash',
          status: _convertToDetailStatus(order.statusTag),
        );
        context.push('/order-detail', extra: orderData);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF5EE),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 产品名称
                Row(
                  children: [
                    Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.productName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0E0E0E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF0E0E0E)),
                  ],
                ),
                const SizedBox(height: 12),
                // 金额信息
                Row(
                  children: [
                    _buildAmountItem('借款金额', 'GHS ${order.borrowAmount.toStringAsFixed(0)}'),
                    const Spacer(),
                    _buildAmountItem('到账金额', 'GHS ${order.arrivalAmount.toStringAsFixed(0)}'),
                    const Spacer(),
                    _buildAmountItem('借款日期', order.borrowDate),
                  ],
                ),
              ],
            ),
            // 状态标签
            Positioned(
              top: 12,
              right: 0,
              child: _buildStatusTag(order.statusTag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountItem(String label, String value, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(StatusTag tag) {
    String label;
    Color textColor;
    List<Color>? gradientColors;

    switch (tag) {
      case StatusTag.borrowing:
        label = '放款中';
        gradientColors = [const Color(0xFFF9B072), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case StatusTag.pending:
        label = '待还款';
        gradientColors = [const Color(0xFFF9B072), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case StatusTag.overdue:
        label = '已逾期';
        gradientColors = [const Color(0xFFFF5256), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case StatusTag.failed:
        label = '放款失败';
        gradientColors = [const Color(0xFFACACAC), const Color(0xFF808080)];
        textColor = Colors.white;
        break;
      case StatusTag.repaid:
        label = '已还款';
        gradientColors = [const Color(0xFF45F3A6), const Color(0xFF268470)];
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
