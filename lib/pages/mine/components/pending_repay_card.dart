import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/repay/components/overdue_badge.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/material.dart';

class PendingRepayCard extends StatelessWidget {
  const PendingRepayCard({
    super.key,
    required this.amount,
    required this.isOverdue,
    required this.onTap,
  });

  final double amount;
  final bool isOverdue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF5EE),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Assets.images.mineArrow.image(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        amount.formatAmount(
                          currencySymbol: AppStrings.orderDetailCurrencyCode,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isOverdue) const OverdueBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.mineCurrentPending,
                    style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
                  ),
                ],
              ),
            ),
            const Text(
              AppStrings.mineGoToRepay,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF808080), size: 16),
          ],
        ),
      ),
    );
  }
}
