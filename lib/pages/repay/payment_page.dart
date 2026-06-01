import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/extensions.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final double amount;
  final String? phone;
  final String? idNumber;

  const PaymentPage({
    super.key,
    required this.amount,
    this.phone,
    this.idNumber,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  static const _repayDate = '25/05/2026';

  List<_LoanDetailItem> get _loanDetails => [
    _LoanDetailItem(
      brand: 'Palm Loa',
      amount: 981287,
      termValue: 'GHS 110',
      serviceFee: 'GHS 110',
      interest: 'GHS 1',
      repayDate: _repayDate,
    ),
    _LoanDetailItem(
      brand: 'Palm Loa',
      amount: 981287,
      termValue: 'GHS 110',
      serviceFee: 'GHS 110',
      interest: 'GHS 1',
      repayDate: _repayDate,
    ),
  ];

  String get _amountText => 'GHS${widget.amount.formatAmount()}';
  String get _phoneText =>
      widget.phone?.trim().isNotEmpty == true ? widget.phone! : '2335*****1247';
  String get _accountTypeText => widget.idNumber?.trim().isNotEmpty == true
      ? widget.idNumber!
      : 'MoMo收款账户';

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final heroHeight = 304.0 + topInset;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _buildHero(heroHeight, topInset),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF7F7F7),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 126),
                    child: Column(
                      children: [
                        _buildBankCard(),
                        const SizedBox(height: 14),
                        _buildCouponCard(),
                        const SizedBox(height: 14),
                        ...List.generate(
                          _loanDetails.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _loanDetails.length - 1 ? 0 : 14,
                            ),
                            child: _buildLoanDetailCard(_loanDetails[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHero(double heroHeight, double topInset) {
    return Container(
      height: heroHeight,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, topInset + 8, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF287A59), Color(0xFF3ED29B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -4,
            top: 0,
            child: Opacity(opacity: 0.12, child: _buildDotPattern()),
          ),
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '确认借款',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                _amountText,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.account_balance_wallet_outlined,
                      value: 'GHS 338',
                      label: '到账金额',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.timelapse_rounded,
                      value: 'GHS 338',
                      label: '应还金额',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.calendar_today_outlined,
                      value: '20/05/2026',
                      label: '还款日期',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE29A), Color(0xFFF1C063)],
            ),
            border: Border.all(color: const Color(0x40B47D1E)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x229A6316),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildChipCard(),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Vodafone Cash',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A2603),
                            ),
                          ),
                        ),
                        Text(
                          _accountTypeText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5E360D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _phoneText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF351B05),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipCard() {
    return Container(
      width: 64,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xAAAD8222)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE78A), Color(0xFFE2BD52)],
        ),
      ),
      child: CustomPaint(painter: _BankCardPainter()),
    );
  }

  Widget _buildCouponCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFEDD8), Color(0xFFFFC6B3)],
              ),
            ),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA7A1), Color(0xFFFF637C)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'GHS!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '优惠券',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF282522),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '提升额度或享受利息减免',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF55504A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFB9B4AE),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailCard(_LoanDetailItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEE8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F5C4B),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.brand,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildDetailRow('借款金额', 'GHS ${item.amount.formatAmount()}'),
          const SizedBox(height: 22),
          _buildDetailRow('借款期限', item.termValue),
          const SizedBox(height: 22),
          _buildDetailRow('服务费', item.serviceFee),
          const SizedBox(height: 22),
          _buildDetailRow('利息', item.interest),
          const SizedBox(height: 22),
          _buildDetailRow('还款日期', item.repayDate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 14),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _showConfirmDialog,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF2E9479),
              borderRadius: BorderRadius.circular(29),
            ),
            child: const Center(
              child: Text(
                '确认借款',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotPattern() {
    return SizedBox(
      width: 108,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(
          96,
          (_) => Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认借款'),
        content: Text('确认借款 ${widget.amount.formatAmount()} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('借款申请已提交')));
              context.go('/');
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.16,
                child: CustomPaint(
                  size: const Size(62, 42),
                  painter: _MetricBurstPainter(),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanDetailItem {
  final String brand;
  final double amount;
  final String termValue;
  final String serviceFee;
  final String interest;
  final String repayDate;

  const _LoanDetailItem({
    required this.brand,
    required this.amount,
    required this.termValue,
    required this.serviceFee,
    required this.interest,
    required this.repayDate,
  });
}

class _BankCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xB5957018);

    final vertical1 = size.width * 0.28;
    final vertical2 = size.width * 0.56;
    final horizontal = size.height * 0.52;

    canvas.drawLine(
      Offset(vertical1, 0),
      Offset(vertical1, size.height),
      stroke,
    );
    canvas.drawLine(
      Offset(vertical2, 0),
      Offset(vertical2, size.height),
      stroke,
    );
    canvas.drawLine(
      Offset(0, horizontal),
      Offset(size.width, horizontal),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.22);

    final origin = Offset(size.width * 0.15, size.height * 0.25);
    for (var i = -2; i <= 6; i++) {
      final angle = (-0.95 + i * 0.22);
      final end = Offset(
        origin.dx + math.cos(angle) * size.width,
        origin.dy + math.sin(angle) * size.height * 1.4,
      );
      canvas.drawLine(origin, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
