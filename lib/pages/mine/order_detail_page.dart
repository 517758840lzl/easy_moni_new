import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../entities/bill_details_resp.dart';
import '../../entities/user_repayment_resp.dart';
import 'providers/bill_details_provider.dart';

class DetailStatus {
  static const int borrowing = 1;    // 放款中
  static const int waiting = 2;      // 等待放款
  static const int pending = 4;       // 待还款
  static const int overdue = 3;      // 已逾期
  static const int repayment = 5;     // 还款中(Reembolso)
  static const int repaid = 6;        // 已还款
  
  const DetailStatus._();
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
  final int status;

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
  final OrderData? orderData;
  final List<UserRepaymentResp>? orders;

  const OrderDetailPage({
    super.key,
    this.orderData,
    this.orders,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  BillDetailsResp? _billDetails;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  Future<void> _loadBillDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(billDetailsProvider);
      
      // 从订单列表获取 appOrderIds
      List<String> orderIds;
      if (widget.orders != null && widget.orders!.isNotEmpty) {
        orderIds = widget.orders!.map((o) => o.appOrderId).toList();
      } else if (widget.orderData != null) {
        orderIds = [widget.orderData!.id];
      } else {
        setState(() {
          _isLoading = false;
          _error = '没有订单数据';
        });
        return;
      }

      final result = await api.call(appOrderIds: orderIds);

      if (mounted) {
        setState(() {
          if (result.isSuccess && result.data != null) {
            _billDetails = result.data;
          } else {
            _error = result.message ?? '获取账单详情失败';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool get _showRepayButton {
    if (_billDetails == null) return false;
    // 根据 extensionSwitch 和订单状态判断是否显示还款按钮
    return _billDetails!.extensionSwitch || _billDetails!.loanOrderDetails.any(
      (o) => o.orderStatus == DetailStatus.pending || o.orderStatus == DetailStatus.overdue,
    );
  }

  String get _statusTitle {
    if (_billDetails == null) return '';
    
    final hasOverdue = _billDetails!.loanOrderDetails.any((o) => o.remainingDay < 0);
    if (hasOverdue) return '已逾期';
    
    final allRepayment = _billDetails!.loanOrderDetails.every((o) => o.orderStatus == DetailStatus.repayment);
    if (allRepayment) return '还款中';
    
    return '待还款';
  }

  String get _statusSubtitle => 'Easy moni';

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
                        if (_billDetails != null && _billDetails!.remainingDay < 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5256), Color(0xFFFF8463)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '已逾期${_billDetails!.remainingDay.abs()}天',
                              style: const TextStyle(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : _buildContent(),
            ),
          ),
          // 底部还款按钮
          if (_showRepayButton) _buildRepayButton(),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_billDetails == null) return Icons.help;
    
    final hasOverdue = _billDetails!.loanOrderDetails.any((o) => o.remainingDay < 0);
    if (hasOverdue) return Icons.warning_amber;
    
    return Icons.schedule;
  }

  Widget _buildContent() {
    if (_billDetails == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 汇总信息卡片
          _buildSummaryCard(),
          const SizedBox(height: 16),
          // 订单列表
          ..._billDetails!.loanOrderDetails.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOrderDetailCard(detail),
          )),
          // 收款账户信息卡片
          if (_billDetails!.loanOrderDetails.isNotEmpty)
            _buildAccountInfoCard(_billDetails!.loanOrderDetails.first),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '待还总金额',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0E0E0E),
                ),
              ),
              Text(
                'GHS ${_billDetails!.totalSureRepayAmounts.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF5256),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem('剩余天数', '${_billDetails!.remainingDay}天'),
              const SizedBox(width: 24),
              _buildSummaryItem('订单数量', '${_billDetails!.loanOrderDetails.length}个'),
              const SizedBox(width: 24),
              _buildSummaryItem('展期', _billDetails!.isExtensionSwitch ? '可展期' : '不可展期'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0E0E0E),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailCard(LoanOrderDetail detail) {
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
              Expanded(
                child: Text(
                  detail.productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0E0E0E),
                  ),
                ),
              ),
              _buildOrderStatusTag(detail.remainingDay),
            ],
          ),
          const SizedBox(height: 12),
          // 金额信息
          _buildInfoRow('借款金额', 'GHS ${detail.loanAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow('到账金额', 'GHS ${detail.receiptAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow('服务费', 'GHS ${detail.serviceFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow('利息', 'GHS ${detail.interest.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow('应还金额', 'GHS ${detail.repaymentAmount.toStringAsFixed(2)}', isHighlight: true),
          const SizedBox(height: 8),
          _buildInfoRow('借款期限', '${detail.term}期'),
          const SizedBox(height: 8),
          _buildInfoRow('到期日', detail.repayDate),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTag(int remainingDay) {
    final isOverdue = remainingDay < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue 
              ? [const Color(0xFFFF5256), const Color(0xFFFF8463)]
              : [const Color(0xFF45F3A6), const Color(0xFF268470)],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        isOverdue ? '已逾期${remainingDay.abs()}天' : '剩余$remainingDay天',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: isHighlight ? const Color(0xFFFF5256) : const Color(0xFF0E0E0E),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(LoanOrderDetail detail) {
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
          _buildInfoRow('MOMO账户', detail.bankCardNo),
          const SizedBox(height: 8),
          // 钱包类型
          _buildInfoRow('钱包类型', detail.bankName),
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
          child: Center(
            child: Text(
              '立即还款 GHS ${_billDetails?.totalSureRepayAmounts.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
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
