import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/extensions.dart';

class BillStatus {
  static const int overdue = 1;
  static const int normal = 2;
  
  const BillStatus._();
}

class BillItem {
  final String id;
  final String productName;
  final double loanAmount;
  final double interest;
  final double overdueFee;
  final int overdueDays;
  final double amount;
  final String dueDate;
  final int status;

  BillItem({
    required this.id,
    required this.productName,
    required this.loanAmount,
    required this.interest,
    required this.overdueFee,
    required this.overdueDays,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

// 模拟数据
final List<BillItem> _mockBills = [
  BillItem(
    id: '1',
    productName: 'Palm Loa',
    loanAmount: 981287.00,
    interest: 1,
    overdueFee: 0,
    overdueDays: 3,
    amount: 57950.00,
    dueDate: '25/05/2026',
    status: BillStatus.overdue,
  ),
  BillItem(
    id: '2',
    productName: 'Easy Loan',
    loanAmount: 500000.00,
    interest: 500,
    overdueFee: 200,
    overdueDays: 5,
    amount: 500500.00,
    dueDate: '20/05/2026',
    status: BillStatus.overdue,
  ),
  BillItem(
    id: '3',
    productName: 'Quick Cash',
    loanAmount: 200000.00,
    interest: 200,
    overdueFee: 0,
    overdueDays: 0,
    amount: 200200.00,
    dueDate: '15/06/2026',
    status: BillStatus.normal,
  ),
  BillItem(
    id: '4',
    productName: 'Money Fast',
    loanAmount: 300000.00,
    interest: 300,
    overdueFee: 0,
    overdueDays: 0,
    amount: 300300.00,
    dueDate: '20/06/2026',
    status: BillStatus.normal,
  ),
];

class RepayEntryPage extends ConsumerStatefulWidget {
  const RepayEntryPage({super.key});

  @override
  ConsumerState<RepayEntryPage> createState() => _RepayEntryPageState();
}

class _RepayEntryPageState extends ConsumerState<RepayEntryPage> {
  List<BillItem> _bills = [];
  Set<String> _selectedIds = {};

  double get _totalAmount => _bills
      .where((bill) => _selectedIds.contains(bill.id))
      .fold(0, (sum, bill) => sum + bill.amount);

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() {
    setState(() {
      _bills = List.from(_mockBills);
      _selectedIds = _bills.map((b) => b.id).toSet();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          // 顶部绿色区域
          Container(
            width: double.infinity,
            color: const Color(0xFF216A4A),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '待还总额',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GHS ${_totalAmount.formatAmount()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  // 待还账单标题
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 17, 12, 0),
                    child: Text(
                      '待还账单',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 账单列表
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: _bills.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildBillCard(_bills[index]);
                      },
                    ),
                  ),
                  // 全部还款按钮
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedIds.isEmpty) return;
                        if (_selectedIds.length == 1) {
                          final bill = _bills.firstWhere((b) => b.id == _selectedIds.first);
                          context.push('/repay-detail', extra: bill);
                        } else {
                          final selectedBills = _bills.where((b) => _selectedIds.contains(b.id)).toList();
                          context.push('/repay-multi-detail', extra: selectedBills);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedIds.isEmpty
                              ? const Color(0xFFACACAC)
                              : const Color(0xFF268470),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Center(
                          child: Text(
                            '全部还款',
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
    );
  }

  Widget _buildBillCard(BillItem bill) {
    final isOverdue = bill.status == BillStatus.overdue;
    final isSelected = _selectedIds.contains(bill.id);

    return GestureDetector(
      onTap: () => _toggleSelection(bill.id),
      child: Container(
        height: 111,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isOverdue
                ? [const Color(0xFFFAEECA), const Color(0xFFFF5130)]
                : [const Color(0xFF2792E9), const Color(0xFF59CCEC)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.shopping_bag, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bill.productName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                        const SizedBox(width: 8),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3DCCC7) : Colors.transparent,
                            border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'GHS ${bill.amount.formatAmount()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '到期日: ${bill.dueDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF787878),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildRepayButton(isOverdue, bill),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepayButton(bool isOverdue, BillItem bill) {
    return GestureDetector(
      onTap: () {
        context.push('/repay-detail', extra: bill);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOverdue
                ? [const Color(0xFFFF9C2D), const Color(0xFFFF4137)]
                : [const Color(0xFF54C6EC), const Color(0xFF279AEA)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          '立即还款',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}
