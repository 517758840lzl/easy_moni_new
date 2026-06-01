import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../gen/assets.gen.dart';
import '../../entities/user_repayment_resp.dart';
import 'order_detail_page.dart';
import 'providers/user_repayment_provider.dart';

class OrderStatus {
  static const int all = 0;       // 全部
  static const int borrowing = 1;  // 借款中
  static const int pending = 2;     // 待还款
  static const int failed = 3;     // 放款失败
  static const int repaided = 4;     // 还款中

  const OrderStatus._();
}

class StatusTag {
  static const int borrowing = 1;   // 放款中 - 橙色
  static const int pending = 2;      // 待还款 - 橙色
  static const int overdue = 3;      // 已逾期 - 红色
  static const int failed = 4;       // 放款失败 - 灰色 (Reembolso)
  static const int repaid = 5;       // 已还款 - 绿色
  
  const StatusTag._();
}

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  int _currentStatus = OrderStatus.all;
  List<UserRepaymentResp> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    try {
      final api = ref.read(userRepaymentProvider);
      final result = await api.call(statusList: [_currentStatus]); //_currentStatus statusList: [4] = Reembolso
      
      if (mounted) {
        setState(() {
          if (result.isSuccess && result.data != null) {
            _orders = result.data!;
          } else {
            _orders = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onTabChanged(int status) {
    if (_currentStatus != status) {
      setState(() {
        _currentStatus = status;
      });
      _loadOrders();
    }
  }

  int _convertToDetailStatus(int orderStatus) {
    switch (orderStatus) {
      case 1:
        return DetailStatus.borrowing;
      case 2:
        return DetailStatus.pending;
      case 3:
        return DetailStatus.overdue;
      case 4:
        return DetailStatus.repayment; // Reembolso
      case 5:
        return DetailStatus.repaid;
      default:
        return DetailStatus.borrowing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
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
                      ],
                    ),
                  ),
                  _buildTabBar(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                      ? _buildEmptyState()
                      : _buildOrderList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    // 计算各状态数量
    int allCount = _orders.length;
    int borrowingCount = _orders.where((o) => o.orderStatus == 1).length;
    int pendingCount = _orders.where((o) => o.orderStatus == 2).length;
    int overdueCount = _orders.where((o) => o.orderStatus == 3).length;
    int failedCount = _orders.where((o) => o.orderStatus == 4).length;

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
          _buildTabItem('已逾期（$overdueCount）', OrderStatus.failed),
          const SizedBox(width: 17),
          _buildTabItem('还款中（$failedCount）', OrderStatus.repaided),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int status) {
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

  Widget _buildOrderCard(UserRepaymentResp order) {
    return GestureDetector(
      onTap: () {
        final orderData = OrderData(
          id: order.appOrderId,
          productName: order.productName,
          borrowAmount: order.loanAmount,
          arrivalAmount: order.receiptAmount,
          interest: order.interest,
          repayAmount: order.repayAmount,
          borrowDays: order.term,
          borrowDate: _formatDate(order.createTime),
          dueDate: order.repayDateStr,
          momoAccount: order.bankCardNo,
          walletType: order.bankCardName,
          status: _convertToDetailStatus(order.orderStatus),
        );
        context.push('/order-detail', extra: {
          'orderData': orderData,
          'orders': _orders,
        });
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
                Row(
                  children: [
                    _buildAmountItem('借款金额', 'GHS ${order.loanAmount.toStringAsFixed(2)}'),
                    const Spacer(),
                    _buildAmountItem('到账金额', 'GHS ${order.receiptAmount.toStringAsFixed(2)}'),
                    const Spacer(),
                    _buildAmountItem('借款日期', _formatDate(order.createTime)),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              right: 0,
              child: _buildStatusTag(order.orderStatus),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    // 将 2026-04-29 19:13:01 转换为 29/04/2026
    try {
      final parts = dateStr.split(' ')[0].split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
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

  Widget _buildStatusTag(int orderStatus) {
    String label;
    Color textColor;
    List<Color> gradientColors;

    switch (orderStatus) {
      case 1:
        label = '放款中';
        gradientColors = [const Color(0xFFF9B072), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case 2:
        label = '待还款';
        gradientColors = [const Color(0xFFF9B072), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case 3:
        label = '已逾期';
        gradientColors = [const Color(0xFFFF5256), const Color(0xFFFF8463)];
        textColor = Colors.white;
        break;
      case 4:
        label = '还款中';
        gradientColors = [const Color(0xFF45F3A6), const Color(0xFF268470)];
        textColor = Colors.white;
        break;
      case 5:
        label = '已还款';
        gradientColors = [const Color(0xFF45F3A6), const Color(0xFF268470)];
        textColor = Colors.white;
        break;
      default:
        label = '未知';
        gradientColors = [const Color(0xFFACACAC), const Color(0xFF808080)];
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
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
