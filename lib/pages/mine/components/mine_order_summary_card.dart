import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/utils/loan_order_status_visual.dart';
import 'package:flutter/material.dart';

class MineOrderSummaryCardColumnData {
  const MineOrderSummaryCardColumnData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class MineOrderSummaryCard extends StatelessWidget {
  const MineOrderSummaryCard({
    super.key,
    required this.productName,
    required this.columns,
    this.productLogo,
    this.statusCode,
    this.remainingDays,
    this.onTap,
    this.onLoanAgreementTap,
  });

  final String productName;
  final String? productLogo;
  final List<MineOrderSummaryCardColumnData> columns;
  final int? statusCode;
  final int? remainingDays;
  final VoidCallback? onTap;
  final VoidCallback? onLoanAgreementTap;

  @override
  Widget build(BuildContext context) {
    final visual = LoanOrderStatusVisual.forStatus(
      statusCode,
      remainingDays: remainingDays,
    );
    final card = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 91),
      padding: EdgeInsets.fromLTRB(
        15,
        10,
        15,
        onLoanAgreementTap != null ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4.375),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MineOrderHeader(
                productName: productName,
                productLogo: productLogo,
                reserveStatusSpace: statusCode != null,
              ),
              const SizedBox(height: 12),
              _MineOrderInfoColumns(columns: columns),
              if (onLoanAgreementTap != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onLoanAgreementTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF216A4A),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 14,
                            color: Color(0xFF216A4A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            AppStrings.loanConfirmAgreeLink,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF216A4A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (statusCode != null)
            Positioned(
              top: 2,
              right: 0,
              child: _MineOrderStatusBadge(visual: visual),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.375),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _MineOrderHeader extends StatelessWidget {
  const _MineOrderHeader({
    required this.productName,
    required this.productLogo,
    required this.reserveStatusSpace,
  });

  final String productName;
  final String? productLogo;
  final bool reserveStatusSpace;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MineOrderLogo(productName: productName, productLogo: productLogo),
        const SizedBox(width: 4),
        Flexible(
          fit: FlexFit.loose,
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
        const SizedBox(width: 2),
        const Icon(Icons.chevron_right, size: 14, color: Color(0xFF0E0E0E)),
        SizedBox(width: reserveStatusSpace ? 58 : 0),
      ],
    );
  }
}

class _MineOrderLogo extends StatelessWidget {
  const _MineOrderLogo({required this.productName, required this.productLogo});

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
    final initial = productName.isNotEmpty
        ? productName.characters.first
        : AppStrings.loanOrderLogoFallback;

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

class _MineOrderInfoColumns extends StatelessWidget {
  const _MineOrderInfoColumns({required this.columns});

  final List<MineOrderSummaryCardColumnData> columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _MineOrderInfoColumn(data: columns[i]),
        ],
      ],
    );
  }
}

class _MineOrderInfoColumn extends StatelessWidget {
  const _MineOrderInfoColumn({required this.data});

  final MineOrderSummaryCardColumnData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.6),
              height: 12 / 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 16 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _MineOrderStatusBadge extends StatelessWidget {
  const _MineOrderStatusBadge({required this.visual});

  final LoanOrderStatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
        visual.label,
        maxLines: 1,
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
