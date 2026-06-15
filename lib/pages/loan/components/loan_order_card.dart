import 'package:easy_moni/entities/home_resp.dart';
import 'package:easy_moni/entities/loan_confirm/loan_confirm_resp.dart';
import 'package:flutter/material.dart';

import '../../../utils/extensions.dart';

enum LoanOrderCardMode { repaymentStatus, loanConfirm }

class LoanOrderCard extends StatelessWidget {
  const LoanOrderCard({
    super.key,
    required this.productName,
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    required this.dueDate,
    this.productLogo,
    this.statusText,
    this.statusCode,
    this.totalServiceDays,
    this.serviceFee,
    this.interest,
    this.mode = LoanOrderCardMode.repaymentStatus,
    this.footerText,
    this.onTap,
  });

  factory LoanOrderCard.fromHomeProductItem(
    HomeProductItem item, {
    Key? key,
    VoidCallback? onTap,
  }) {
    final dueDate = item.dueDate?.isNotEmpty == true
        ? item.dueDate!
        : item.repayDateStr?.isNotEmpty == true
        ? item.repayDateStr!
        : item.repayDate ?? '-';

    return LoanOrderCard(
      key: key,
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : 'Product',
      productLogo: item.productLogo,
      loanAmount: item.loanAmount ?? 0,
      receiptAmount: item.receiptAmount ?? 0,
      repayAmount: item.repayAmount ?? 0,
      dueDate: dueDate,
      statusCode: item.appOrderStatus,
      totalServiceDays: item.totalServiceDays,
      onTap: onTap,
    );
  }

  factory LoanOrderCard.confirmFromLoanConfirmOrder(
    LoanConfirmOrder item, {
    Key? key,
    VoidCallback? onTap,
  }) {
    final dueDate = item.repayDateStr?.isNotEmpty == true
        ? item.repayDateStr!
        : item.repayDate?.isNotEmpty == true
        ? item.repayDate!
        : '-';

    return LoanOrderCard(
      key: key,
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : 'Product',
      productLogo: item.productLogo,
      loanAmount: (item.loanAmount ?? 0).toDouble(),
      receiptAmount: (item.actualToAccount ?? item.receiptAmount ?? 0)
          .toDouble(),
      repayAmount: (item.repayAmount ?? 0).toDouble(),
      dueDate: item.dueDate,
      totalServiceDays: item.totalServiceDays,
      serviceFee: (item.serviceFee ?? 0).toDouble(),
      interest: (item.interest ?? 0).toDouble(),
      mode: LoanOrderCardMode.loanConfirm,
      onTap: onTap,
    );
  }

  final String productName;
  final String? productLogo;
  final double loanAmount;
  final double receiptAmount;
  final double repayAmount;
  final String? dueDate;
  final String? statusText;
  final int? statusCode;
  final int? totalServiceDays;
  final double? serviceFee;
  final double? interest;
  final LoanOrderCardMode mode;
  final String? footerText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusVisual = _LoanOrderStatusVisual.forStatus(
      statusCode,
      totalServiceDays: totalServiceDays,
    );
    final effectiveStatusText = statusText ?? statusVisual.label;
    final effectiveFooterText = footerText ?? statusVisual.footerText;
    final isLoanConfirm = mode == LoanOrderCardMode.loanConfirm;
    final cardHeight = isLoanConfirm ? 198.0 : 204.0;

    return GestureDetector(
      onTap: onTap,
      behavior: onTap == null
          ? HitTestBehavior.deferToChild
          : HitTestBehavior.opaque,
      child: SizedBox(
        height: cardHeight,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: cardHeight,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5EE),
                borderRadius: BorderRadius.circular(4.375),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderHeader(
                    productName: productName,
                    productLogo: productLogo,
                  ),
                  const SizedBox(height: 7),
                  _OrderInfoRow(
                    label: '借款金额',
                    value: _formatAmount(loanAmount),
                  ),
                  const SizedBox(height: 12),
                  if (isLoanConfirm) ...[
                    _OrderInfoRow(
                      label: '借款期限',
                      value: totalServiceDays == null
                          ? '-'
                          : '$totalServiceDays days',
                    ),
                    const SizedBox(height: 12),
                    _OrderInfoRow(
                      label: '服务费',
                      value: _formatAmount(serviceFee ?? 0),
                    ),
                    const SizedBox(height: 12),
                    _OrderInfoRow(
                      label: '利息',
                      value: _formatAmount(interest ?? 0),
                    ),
                    const SizedBox(height: 12),
                    _OrderInfoRow(label: '还款日期', value: dueDate ?? ''),
                  ] else ...[
                    _OrderInfoRow(
                      label: '到账金额',
                      value: _formatAmount(receiptAmount),
                    ),
                    const SizedBox(height: 12),
                    _OrderInfoRow(
                      label: '应还金额',
                      value: _formatAmount(repayAmount),
                    ),
                    const SizedBox(height: 12),
                    _OrderInfoRow(label: '到期日', value: dueDate ?? ''),
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0x1A000000),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      effectiveFooterText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF216A4A),
                        height: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isLoanConfirm)
              Positioned(
                top: 13,
                right: 13,
                child: _OrderStatusBadge(
                  text: effectiveStatusText,
                  visual: statusVisual,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double value) => 'GHS ${value.formatAmount()}';
}

class _LoanOrderStatusVisual {
  const _LoanOrderStatusVisual({
    required this.label,
    required this.gradient,
    required this.footerText,
  });

  final String label;
  final List<Color> gradient;
  final String footerText;

  factory _LoanOrderStatusVisual.forStatus(
    int? statusCode, {
    int? totalServiceDays,
  }) {
    if (statusCode == 4 && totalServiceDays != null && totalServiceDays < 0) {
      return const _LoanOrderStatusVisual(
        label: '已逾期',
        gradient: [Color(0xFFFF5265), Color(0xFFFF843F)],
        footerText: '已逾期，请尽快完成还款 >',
      );
    }

    switch (statusCode) {
      case 20:
        return const _LoanOrderStatusVisual(
          label: '借款审核中',
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: '借款审核中，请耐心等待 >',
        );
      case 3:
        return const _LoanOrderStatusVisual(
          label: '放款中',
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: '放款中，资金即将抵达 MoMo 账户 >',
        );
      case 4:
        return const _LoanOrderStatusVisual(
          label: '等待还款',
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: '等待还款，请按时完成还款 >',
        );
      case 5:
        return const _LoanOrderStatusVisual(
          label: '转账失败',
          gradient: [Color(0xFFC1C3C6), Color(0xFFC1C3C6)],
          footerText: '转账失败，请查看订单详情 >',
        );
      default:
        return const _LoanOrderStatusVisual(
          label: '借款审核中',
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: '借款审核中，请耐心等待 >',
        );
    }
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.productName, required this.productLogo});

  final String productName;
  final String? productLogo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrderLogo(productName: productName, productLogo: productLogo),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0E0E0E),
              height: 16 / 12,
            ),
          ),
        ),
        const SizedBox(width: 62),
      ],
    );
  }
}

class _OrderLogo extends StatelessWidget {
  const _OrderLogo({required this.productName, required this.productLogo});

  final String productName;
  final String? productLogo;

  @override
  Widget build(BuildContext context) {
    final logo = productLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logo,
          width: 21,
          height: 21,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final initial = productName.isNotEmpty ? productName.characters.first : 'P';

    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Color(0xFF216A4A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.text, required this.visual});

  final String text;
  final _LoanOrderStatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: visual.gradient,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 16 / 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF131313),
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
