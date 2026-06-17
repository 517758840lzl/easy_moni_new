import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:easy_moni/gen/assets.gen.dart';

// 已选优惠券卡片：负责展示已选择的优惠券名称、金额和跳转入口。
class SelectedCouponCard extends StatelessWidget {
  const SelectedCouponCard({
    super.key,
    this.couponName = '',
    this.amountText = '',
    this.onTap,
    this.height = 53,
    this.iconSize = 17,
  });

  final String couponName;
  final String amountText;
  final VoidCallback? onTap;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.couponSelectedBg.provider(),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF58B589),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  Assets.images.couponIcon,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SelectedCouponText(
                  couponName: couponName,
                  amountText: amountText,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: Color(0xFF216A4A),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}

// 优惠券主要信息：上下两行排版与切图中间区域保持对齐。
class _SelectedCouponText extends StatelessWidget {
  const _SelectedCouponText({
    required this.couponName,
    required this.amountText,
  });

  final String couponName;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          couponName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2F2F2F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amountText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            height: 14 / 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF252629),
          ),
        ),
      ],
    );
  }
}
