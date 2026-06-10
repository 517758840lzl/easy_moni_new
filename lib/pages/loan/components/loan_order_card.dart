import 'package:easy_moni/entities/home_resp.dart';
import 'package:flutter/material.dart';

import '../../../utils/extensions.dart';

class LoanOrderCard extends StatelessWidget {
  const LoanOrderCard({
    super.key,
    required this.productName,
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    required this.dueDate,
    this.productLogo,
    this.statusText = '\u653E\u6B3E\u4E2D',
    this.statusCode,
    this.footerText =
        '\u653E\u6B3E\u4E2D\uFF0C\u8D44\u91D1\u5373\u5C06\u62B5\u8FBE MoMo \u8D26\u6237 >',
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
      statusCode: item.appOrderStatus ?? item.productStatus,
      onTap: onTap,
    );
  }

  final String productName;
  final String? productLogo;
  final double loanAmount;
  final double receiptAmount;
  final double repayAmount;
  final String dueDate;
  final String statusText;
  final int? statusCode;
  final String footerText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusVisual = _LoanOrderStatusVisual.forStatus(statusCode);

    return GestureDetector(
      onTap: onTap,
      behavior: onTap == null
          ? HitTestBehavior.deferToChild
          : HitTestBehavior.opaque,
      child: SizedBox(
        height: 204,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 204,
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
                    label: '\u501F\u6B3E\u91D1\u989D',
                    value: _formatAmount(loanAmount),
                  ),
                  const SizedBox(height: 12),
                  _OrderInfoRow(
                    label: '\u5230\u8D26\u91D1\u989D',
                    value: _formatAmount(receiptAmount),
                  ),
                  const SizedBox(height: 12),
                  _OrderInfoRow(
                    label: '\u5E94\u8FD8\u91D1\u989D',
                    value: _formatAmount(repayAmount),
                  ),
                  const SizedBox(height: 12),
                  _OrderInfoRow(label: '\u5230\u671F\u65E5', value: dueDate),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x1A000000),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    footerText,
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
              ),
            ),
            Positioned(
              top: 13,
              right: 13,
              child: _OrderStatusBadge(text: statusText, visual: statusVisual),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double value) => 'GHS ${value.formatAmount()}';
}

class _LoanOrderStatusVisual {
  const _LoanOrderStatusVisual({required this.gradient});

  final List<Color> gradient;

  factory _LoanOrderStatusVisual.forStatus(int? statusCode) {
    switch (statusCode) {
      default:
        return const _LoanOrderStatusVisual(
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
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
