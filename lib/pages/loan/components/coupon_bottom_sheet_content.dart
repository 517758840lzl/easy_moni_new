import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../../entities/coupon_resp.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/extensions.dart';

// 优惠券弹窗内容：仅负责列表和选中态展示，确认按钮由 CommonBottomSheet 统一承载。
class CouponBottomSheetContent extends StatefulWidget {
  const CouponBottomSheetContent({super.key, required this.coupons});

  final List<CouponItem> coupons;

  @override
  State<CouponBottomSheetContent> createState() =>
      _CouponBottomSheetContentState();
}

class _CouponBottomSheetContentState extends State<CouponBottomSheetContent> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final coupons = widget.coupons;

    if (coupons.isEmpty) {
      return SizedBox(
        height: 268,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.loanOpen.image(width: 164, height: 164),
              const SizedBox(height: 8),
              const Text(
                AppStrings.couponString,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.couponEmptyDesc,
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8F98)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(coupons.length, (index) {
        final coupon = coupons[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == coupons.length - 1 ? 0 : 24,
          ),
          child: CouponTicketCard(
            coupon: coupon,
            selected: index == _selectedIndex,
            onTap: () => _toggleCouponSelection(index),
          ),
        );
      }),
    );
  }

  // 切换优惠券选中态：点击未选中的券进行选中，重复点击当前券则取消选择。
  void _toggleCouponSelection(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }
}

// 单张优惠券卡片：使用切图承载票券底形，展示类型标签、金额、摘要和选中图标。
class CouponTicketCard extends StatelessWidget {
  const CouponTicketCard({
    super.key,
    required this.coupon,
    required this.selected,
    required this.onTap,
  });

  final CouponItem coupon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = _nonEmpty(coupon.title, fallback: 'Coupon name');
    final summary = _nonEmpty(coupon.summary, fallback: 'details information');
    final discountValue = (coupon.discountValue ?? 0).toDouble().formatAmount();
    final couponType = _couponTypeText(coupon.discountType);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 104,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.couponBg.provider(),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                _CouponTitle(title: title, couponType: couponType),
                const SizedBox(height: 8),
                // amount
                Text(
                  'GHS $discountValue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 27 / 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF252629),
                  ),
                ),
                // summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 14 / 14,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    // check
                    _CouponCheckMark(selected: selected),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponTitle extends StatelessWidget {
  const _CouponTitle({required this.title, required this.couponType});

  final String title;
  final String couponType;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 15,
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: const BoxDecoration(
            color: Color(0xFF268470),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            couponType,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 8,
              height: 12 / 8,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: _CouponTitleText(title)),
      ],
    );
  }
}

// 标题文字装饰：根据单行文本实际宽度绘制底部圆角色块，避免装饰铺满整行。
class _CouponTitleText extends StatelessWidget {
  const _CouponTitleText(this.title);

  static const _style = TextStyle(
    fontSize: 16,
    height: 17 / 16,
    fontWeight: FontWeight.w800,
    color: Color(0xFF252629),
  );

  final String title;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: title, style: _style),
          maxLines: 1,
          ellipsis: '...',
          textDirection: textDirection,
        )..layout(maxWidth: constraints.maxWidth);

        return SizedBox(
          height: painter.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: constraints.maxWidth.isFinite ? null : 0,
                bottom: 0,
                child: Container(
                  width: constraints.maxWidth.isFinite
                      ? painter.width.clamp(0, constraints.maxWidth)
                      : null,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF268470).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _style,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CouponCheckMark extends StatelessWidget {
  const _CouponCheckMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF268470)),
        ),
      );
    }

    return const CircleAvatar(
      radius: 15,
      backgroundColor: Color(0xFF268470),
      child: Icon(Icons.check_rounded, color: Colors.white, size: 22),
    );
  }
}

String _nonEmpty(String? value, {required String fallback}) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}

// 优惠券类型入口先使用 discountType 字段，当前统一展示“提额券”。
String _couponTypeText(int? discountType) {
  if (discountType == null) return '提额券';
  return '提额券';
}

// 优惠券 UI 预览数据
const List<CouponItem> _mockCouponItems = [
  CouponItem(
    couponId: 1,
    discountType: 1,
    discountValue: 120,
    summary: 'Valid for loan amount increase',
    title: 'Limit increase',
    type: 'limit',
    status: 1,
  ),
  CouponItem(
    couponId: 1,
    discountType: 1,
    discountValue: 120,
    summary: 'Valid for loan amount increase',
    title: 'Limit increase',
    type: 'limit',
    status: 1,
  ),
];
