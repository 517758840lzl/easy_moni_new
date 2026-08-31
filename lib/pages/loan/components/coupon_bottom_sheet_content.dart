import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:flutter/material.dart';

// 优惠券弹窗内容：仅负责列表和选中态展示，确认按钮由 CommonBottomSheet 统一承载。
class CouponBottomSheetContent extends StatefulWidget {
  const CouponBottomSheetContent({
    super.key,
    required this.coupons,
    this.initialSelectedCouponId,
    this.onSelectionChanged,
  });

  final List<CouponItem> coupons;
  final int? initialSelectedCouponId;
  final ValueChanged<CouponItem?>? onSelectionChanged;

  @override
  State<CouponBottomSheetContent> createState() =>
      _CouponBottomSheetContentState();
}

class _CouponBottomSheetContentState extends State<CouponBottomSheetContent> {
  int? _selectedIndex;
  bool _initializedSelection = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncInitialSelection();
  }

  @override
  void didUpdateWidget(covariant CouponBottomSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedCouponId != widget.initialSelectedCouponId ||
        oldWidget.coupons != widget.coupons) {
      _initializedSelection = false;
      _syncInitialSelection();
    }
  }

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
            selected: coupon.isUsable && index == _selectedIndex,
            onTap: () => _toggleCouponSelection(index),
          ),
        );
      }),
    );
  }

  // 切换优惠券选中态：仅可用券允许选中，重复点击当前券则取消选择。
  void _toggleCouponSelection(int index) {
    if (!widget.coupons[index].isUsable) return;

    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
    final selectedIndex = _selectedIndex;
    widget.onSelectionChanged?.call(
      selectedIndex == null ? null : widget.coupons[selectedIndex],
    );
  }

  // 弹窗重新打开时恢复页面外部保存的优惠券选择状态。
  void _syncInitialSelection() {
    if (_initializedSelection) return;
    _initializedSelection = true;

    final couponId = widget.initialSelectedCouponId;
    if (couponId == null) return;

    final index = widget.coupons.indexWhere(
      (item) => item.isUsable && item.couponId == couponId,
    );
    if (index >= 0) {
      _selectedIndex = index;
    }
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
    final title = _nonEmpty(coupon.title, fallback: '');
    final summary = _nonEmpty(coupon.summary, fallback: '');
    final desc = _nonEmpty(coupon.description, fallback: '');
    final couponType = _couponTypeText(coupon.type);
    final isUsable = coupon.isUsable;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isUsable ? onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                _CouponTitle(title: title),
                const SizedBox(height: 8),
                // 金额与类型标签同排展示，金额按内容宽度自然渲染。
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 27 / 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF252629),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    CouponBadge(couponType: couponType),
                  ],
                ),
                const SizedBox(height: 8),
                // 描述随内容自适应换行，右侧保留选中态入口。
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 14 / 12,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                    ),
                    if (isUsable) ...[
                      const SizedBox(width: 8),
                      _CouponCheckMark(selected: selected),
                    ],
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
  const _CouponTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _CouponTitleText(title);
  }
}

class CouponBadge extends StatelessWidget {
  const CouponBadge({super.key, required this.couponType});

  final String couponType;

  @override
  Widget build(BuildContext context) {
    return Container(
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

// 优惠券类型文案：后端 type 为 PRE 时展示提额券，POST 时展示减免券。
String _couponTypeText(String? type) {
  switch (type) {
    case CouponTypes.pre:
      return AppStrings.couponTypePre;
    case CouponTypes.post:
      return AppStrings.couponTypePost;
    default:
      return '';
  }
}
