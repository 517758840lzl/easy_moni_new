import 'package:flutter/material.dart';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';

// 优惠券入口卡片：负责展示入口状态，并把点击事件交给确认页处理业务请求。
class CouponEntryCard extends StatelessWidget {
  const CouponEntryCard({
    super.key,
    required this.onTap,
    this.selectedCoupon,
    this.onClear,
  });

  final VoidCallback onTap;
  final CouponItem? selectedCoupon;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final selected = selectedCoupon;
    final hasSelectedCoupon = selected != null;

    return Material(
      color: const Color(0xFFFDF5EE),
      borderRadius: BorderRadius.circular(4.375),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.375),
        child: SizedBox(
          height: 53,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Assets.images.loanGhs.image(width: 48, height: 48),
                const SizedBox(width: 10),
                Expanded(child: _CouponEntryText(selectedCoupon: selected)),
                const SizedBox(width: 8),
                if (hasSelectedCoupon && onClear != null)
                  _CouponClearButton(onTap: onClear!)
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponEntryText extends StatelessWidget {
  const _CouponEntryText({required this.selectedCoupon});

  final CouponItem? selectedCoupon;

  @override
  Widget build(BuildContext context) {
    final selected = selectedCoupon;
    final title = _nonEmpty(selected?.title, fallback: AppStrings.couponString);
    final summary = _nonEmpty(
      selected?.summary,
      fallback: selected == null
          ? AppStrings.couponEntrySubtitle
          : AppStrings.couponSelectedFallback,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF131313),
          ),
        ),
        SizedBox(height: 3),
        Text(
          summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8A8F98)),
        ),
      ],
    );
  }
}

class _CouponClearButton extends StatelessWidget {
  const _CouponClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: Icon(Icons.close_rounded, size: 18, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

String _nonEmpty(String? value, {required String fallback}) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}
