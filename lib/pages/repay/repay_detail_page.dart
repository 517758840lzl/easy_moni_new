import 'package:easy_moni/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/extensions.dart';
import 'repay_entry_page.dart';

class RepayDetailPage extends ConsumerStatefulWidget {
  final BillItem bill;

  const RepayDetailPage({super.key, required this.bill});

  @override
  ConsumerState<RepayDetailPage> createState() => _RepayDetailPageState();
}

class _RepayDetailPageState extends ConsumerState<RepayDetailPage> {
  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final isOverdue = bill.status == BillStatus.overdue;

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
                    bill.amount.formatAmount(),
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
                children: [
                  const SizedBox(height: 16),
                  // 账单详情标题
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '账单详情',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 账单详情卡片
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF5EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // 优惠券行
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFEEEEEE),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Row(
                            children: [
                              // 优惠券图标
                              SizedBox(
                                width: 39,
                                height: 39,
                                child: Center(
                                  child: Text(
                                    '券',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFE4E68),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '优惠券',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '提额券或降息券',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF787878),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Color(0xFFACACAC),
                              ),
                            ],
                          ),
                        ),
                        // 账单详情列表
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                bill.productName,
                                '',
                                showIcon: true,
                              ),
                              _buildDetailRow(
                                '借款金额',
                                'GHS ${bill.loanAmount.formatAmount()}',
                              ),
                              _buildDetailRow(
                                '利息',
                                'GHS ${bill.interest.formatAmount()}',
                              ),
                              if (isOverdue) ...[
                                _buildDetailRow(
                                  '逾期费',
                                  'GHS ${bill.overdueFee.formatAmount()}',
                                ),
                                _buildDetailRow(
                                  '逾期天数',
                                  '${bill.overdueDays} Day',
                                ),
                              ],
                              _buildDetailRow('到期日', bill.dueDate),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 已逾期标签
                  if (isOverdue)
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
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
                  const Spacer(),
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
                                context.push(
                                  AppRoutePaths.extensionApply,
                                  extra: bill.id,
                                );
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
                                  AppRoutePaths.payment,
                                  extra: {
                                    'amount': bill.amount,
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

  Widget _buildDetailRow(String label, String value, {bool showIcon = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Color(0xFF0E0E0E),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
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
