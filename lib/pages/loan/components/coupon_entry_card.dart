import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';

// 优惠券入口卡片：负责展示入口状态，并把点击事件交给确认页处理业务请求。
class CouponEntryCard extends StatelessWidget {
  const CouponEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                const Expanded(child: _CouponEntryText()),
                const SizedBox(width: 8),
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
  const _CouponEntryText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '优惠券',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF131313),
          ),
        ),
        SizedBox(height: 3),
        Text(
          '提升额度或享受利息减免',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Color(0xFF8A8F98)),
        ),
      ],
    );
  }
}
