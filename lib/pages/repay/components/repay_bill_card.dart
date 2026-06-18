import 'package:easy_moni/pages/repay/components/overdue_badge.dart';
import 'package:flutter/material.dart';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/utils/extensions.dart';

/// 还款账单卡片，负责展示单个产品的还款金额、到期日和逾期状态。
class RepayBillCard extends StatelessWidget {
  const RepayBillCard({
    super.key,
    required this.bill,
    this.showSelection = true,
    this.selected = true,
    this.onSelectionTap,
    this.onRepayTap,
    this.onTap,
  });

  final RepayResp bill;
  final bool showSelection;
  final bool selected;
  final VoidCallback? onSelectionTap;
  final VoidCallback? onRepayTap;
  final VoidCallback? onTap;

  bool get _isOverdue => (bill.remainingDays ?? 0) < 0;

  @override
  Widget build(BuildContext context) {
    final colors = _RepayBillCardColors.forOverdue(_isOverdue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 111,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: colors.gradientBegin,
            end: colors.gradientEnd,
            colors: colors.cardGradient,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _buildHeader(colors),
            const SizedBox(height: 8),
            _buildBody(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(_RepayBillCardColors colors) {
    return SizedBox(
      height: 21,
      child: Row(
        children: [
          const SizedBox(width: 4),
          _ProductLogo(
            brand: bill.productName ?? '',
            logoUrl: bill.productLogo,
            color: colors.logoText,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              bill.productName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 16 / 12,
              ),
            ),
          ),
          if (_isOverdue) ...[const SizedBox(width: 8), const OverdueBadge()],
          if (showSelection) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSelectionTap,
              behavior: HitTestBehavior.opaque,
              child: _SelectedIcon(selected: selected),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(_RepayBillCardColors colors) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              right: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _amountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 16 / 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _dueDateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF787878),
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _RepayButton(colors: colors, onTap: onRepayTap),
            ),
          ],
        ),
      ),
    );
  }

  String get _amountLabel {
    final amount = bill.repayAmount;
    if (amount == null) return '';
    return amount.formatAmount();
  }

  String get _dueDateLabel {
    final date = (bill.repayDateStr ?? '').formatBackendDate();
    return '${AppStrings.repayBillDueDateLabel}: $date';
  }
}

class _RepayBillCardColors {
  const _RepayBillCardColors({
    required this.cardGradient,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.logoText,
    required this.buttonGradient,
  });

  final List<Color> cardGradient;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final Color logoText;
  final List<Color> buttonGradient;

  factory _RepayBillCardColors.forOverdue(bool isOverdue) {
    if (isOverdue) {
      return const _RepayBillCardColors(
        cardGradient: [Color(0xFFFF5130), Color(0xFFFAEECA)],
        gradientBegin: Alignment.topCenter,
        gradientEnd: Alignment.bottomCenter,
        logoText: Color(0xFFFF5130),
        buttonGradient: [Color(0xFFFF9C2D), Color(0xFFFF4125)],
      );
    }

    return const _RepayBillCardColors(
      cardGradient: [Color(0xFF2792E9), Color(0xFF59CCEC)],
      gradientBegin: Alignment.topCenter,
      gradientEnd: Alignment.bottomCenter,
      logoText: Color(0xFF2792E9),
      buttonGradient: [Color(0xFF2792E9), Color(0xFF59CCEC)],
    );
  }
}

class _ProductLogo extends StatelessWidget {
  const _ProductLogo({
    required this.brand,
    required this.logoUrl,
    required this.color,
  });

  final String brand;
  final String? logoUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
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
    final initial = brand.isNotEmpty
        ? brand.characters.first
        : AppStrings.repayBillLogoFallback;

    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _SelectedIcon extends StatelessWidget {
  const _SelectedIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF50FFB2) : Colors.white,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(color: const Color(0xFFE1E1E1), width: 1),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Color(0xFF216A4A))
          : null,
    );
  }
}

class _RepayButton extends StatelessWidget {
  const _RepayButton({required this.colors, required this.onTap});

  final _RepayBillCardColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 73,
        height: 26,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.buttonGradient),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Text(
            AppStrings.repayBillRepayNow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 18 / 12,
            ),
          ),
        ),
      ),
    );
  }
}
