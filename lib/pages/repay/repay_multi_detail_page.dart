import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/extensions.dart';
import 'repay_entry_page.dart';

class RepayMultiDetailPage extends ConsumerStatefulWidget {
  final List<BillItem> bills;

  const RepayMultiDetailPage({super.key, required this.bills});

  @override
  ConsumerState<RepayMultiDetailPage> createState() =>
      _RepayMultiDetailPageState();
}

class _RepayMultiDetailPageState extends ConsumerState<RepayMultiDetailPage> {
  double get _totalAmount =>
      widget.bills.fold(0, (sum, bill) => sum + bill.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF216A4A),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // 金额显示
                  const Column(
                    children: [
                      Text(
                        'GHS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _totalAmount.formatAmount(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Amount Due',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // 白色内容区域 - 左上右上圆角
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 账单详情标题
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '账单详情',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 账单列表
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: widget.bills.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildBillCard(widget.bills[index]);
                      },
                    ),
                  ),
                  // 底部按钮
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.bills.isNotEmpty) {
                                  context.push(
                                    '/extension-apply',
                                    extra: widget.bills.first.id,
                                  );
                                }
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF268470),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    '申请展期',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF268470),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.push(
                                  '/payment',
                                  extra: {
                                    'amount': _totalAmount,
                                    'phone': '234543234565432',
                                    'idNumber': '34323432****09098',
                                  },
                                );
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF268470),
                                  borderRadius: BorderRadius.circular(26),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillItem bill) {
    final isOverdue = bill.status == BillStatus.overdue;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Color(0xFF0E0E0E),
                ),
                const SizedBox(width: 8),
                Text(
                  bill.productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0E0E0E),
                  ),
                ),
                const Spacer(),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5265), Color(0xFFFF8463)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      '已逾期',
                      style: TextStyle(
                        fontSize: 5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 详情
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildDetailRow(
                  '借款金额',
                  'GHS ${bill.loanAmount.formatAmount()}',
                  isFirst: true,
                ),
                _buildDetailRow('利息', 'GHS ${bill.interest.formatAmount()}'),
                if (isOverdue) ...[
                  _buildDetailRow(
                    '逾期费',
                    'GHS ${bill.overdueFee.formatAmount()}',
                  ),
                  _buildDetailRow('逾期天数', '${bill.overdueDays} Day'),
                ],
                _buildDetailRow('到期日', bill.dueDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

}
