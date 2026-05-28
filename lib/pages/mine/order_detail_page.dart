import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 订单详情状态
enum DetailStatus {
  borrowing,    // 放款中
  waiting,      // 等待放款
  overdue,      // 已逾期
}

// 订单数据模型
class OrderData {
  final String id;
  final String productName;
  final double borrowAmount;
  final double arrivalAmount;
  final double interest;
  final double repayAmount;
  final int borrowDays;
  final String borrowDate;
  final String dueDate;
  final String momoAccount;
  final String walletType;
  final DetailStatus status;

  OrderData({
    required this.id,
    required this.productName,
    required this.borrowAmount,
    required this.arrivalAmount,
    required this.interest,
    required this.repayAmount,
    required this.borrowDays,
    required this.borrowDate,
    required this.dueDate,
    required this.momoAccount,
    required this.walletType,
    required this.status,
  });
}

class OrderDetailPage extends ConsumerStatefulWidget {
  final OrderData orderData;

  const OrderDetailPage({
    super.key,
    required this.orderData,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool get _showRepayButton =>
      widget.orderData.status == DetailStatus.waiting || widget.orderData.status == DetailStatus.overdue;

  String get _statusTitle {
    switch (widget.orderData.status) {
      case DetailStatus.borrowing:
        return '放款中（至MoMo）';
      case DetailStatus.waiting:
        return '等待放款';
      case DetailStatus.overdue:
        return '已逾期';
    }
  }

  String get _statusSubtitle {
    switch (widget.orderData.status) {
      case DetailStatus.borrowing:
        return 'Easy moni';
      case DetailStatus.waiting:
        return '商品由该商家代售';
      case DetailStatus.overdue:
        return 'Easy moni';
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        ),
                        const Expanded(
                          child: Text(
                            '账单详情',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  // 状态信息
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 0, 17, 24),
                    child: Row(
                      children: [
                        // 状态图标
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            _getStatusIcon(),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _statusTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _statusSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.orderData.status == DetailStatus.overdue)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5256), Color(0xFFFF8463)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '已逾期',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 订单信息卡片
                    _buildOrderInfoCard(),
                    const SizedBox(height: 16),
                    // 收款账户信息卡片
                    _buildAccountInfoCard(),
                  ],
                ),
              ),
            ),
          ),
          // 底部还款按钮
          if (_showRepayButton) _buildRepayButton(),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (widget.orderData.status) {
      case DetailStatus.borrowing:
        return Icons.hourglass_empty;
      case DetailStatus.waiting:
        return Icons.schedule;
      case DetailStatus.overdue:
        return Icons.warning_amber;
    }
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.receipt_long, size: 18, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Text(
                '订单信息',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E0E0E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 借款金额
          _buildInfoRow('借款金额', 'GHS ${widget.orderData.borrowAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          // 到账金额
          _buildInfoRow('到账金额', 'GHS ${widget.orderData.arrivalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          // 利息
          _buildInfoRow('利息', 'GHS ${widget.orderData.interest.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          // 应还金额
          _buildInfoRow('应还金额', 'GHS ${widget.orderData.repayAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          // 借款期限
          _buildInfoRow('借款期限', '${widget.orderData.borrowDays} Day'),
          const SizedBox(height: 10),
          // 借款日
          _buildInfoRow('借款日', widget.orderData.borrowDate),
          const SizedBox(height: 10),
          // 到期日
          _buildInfoRow('到期日', widget.orderData.dueDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0E0E0E),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.account_balance_wallet, size: 18, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Text(
                '收款账户信息',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E0E0E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // MOMO账户
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MOMO账户',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              Text(
                widget.orderData.momoAccount,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B0B0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 钱包类型
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '钱包类型',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              Text(
                widget.orderData.walletType,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B0B0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepayButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          debugPrint('点击了立即还款');
          // TODO: 跳转到还款页面
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF268470),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Center(
            child: Text(
              '立即还款',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
