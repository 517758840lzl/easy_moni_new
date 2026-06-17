import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_content.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:easy_moni/pages/repay/models/repay_multi_order_detail_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_detail_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/selected_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 多订单还款详情页，复用 billDetails 接口并按聚合订单展示多笔待还信息。
class RepayMultiOrderDetailPage extends ConsumerStatefulWidget {
  const RepayMultiOrderDetailPage({super.key, required this.requestData});

  final RepayMultiOrderDetailRequestData requestData;

  @override
  ConsumerState<RepayMultiOrderDetailPage> createState() =>
      _RepayMultiOrderDetailPageState();
}

class _RepayMultiOrderDetailPageState
    extends ConsumerState<RepayMultiOrderDetailPage> {
  bool _isCouponSheetOpen = false;
  CouponItem? _selectedCoupon;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final detailQuery = buildRepayDetailQuery(
      appOrderIds: widget.requestData.appOrderIds,
      couponIds: [_selectedCoupon?.couponId],
    );
    final detailAsync = ref.watch(repayOrderDetailProvider(detailQuery));
    final detail = detailAsync.when(
      data: (data) => data,
      error: (_, _) => null,
      loading: () => null,
    );

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 180,
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayMultiHeader(detail: detail),
      content: detailAsync.when(
        data: (data) => _RepayMultiContent(
          detail: data,
          selectedCoupon: _selectedCoupon,
          onCouponTap: () => _showCoupons(data),
        ),
        error: (_, _) => _RepayMultiStateView(
          icon: Icons.error_outline_rounded,
          text: AppStrings.orderDetailLoadFailed,
          actionText: AppStrings.repayEntryRetry,
          onActionTap: () =>
              ref.invalidate(repayOrderDetailProvider(detailQuery)),
        ),
        loading: () =>
            const _RepayMultiStateView(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: detail != null,
        text: AppStrings.repayDetailRepayNow,
        onPressed: detail == null ? null : () => _openPayment(context, detail),
      ),
    );
  }

  void _openPayment(BuildContext context, RepayDetailRespData detail) {
    final couponId = _selectedCoupon?.couponId;
    // TODO: 确认多订单还款提交接口联调细节后，调用 generatesUrl 并随请求传递 couponId。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.repayDetailPaymentPending)),
    );
    debugPrint('Repay coupon id for submit: $couponId');
  }

  Future<void> _showCoupons(RepayDetailRespData detail) async {
    if (_isCouponSheetOpen) return;
    final orders = detail.loanOrderDetails ?? const [];
    if (orders.isEmpty) return;

    setState(() {
      _isCouponSheetOpen = true;
    });

    CouponItem? tempSelectedCoupon = _selectedCoupon;

    try {
      final confirmed = await CommonBottomSheet.show<bool>(
        context: context,
        title: '',
        description: '',
        content: _CouponBottomSheetLoader(
          future: _loadCoupons(orders),
          initialSelectedCouponId: _selectedCoupon?.couponId,
          onSelectionChanged: (coupon) {
            tempSelectedCoupon = coupon;
          },
        ),
        actions: const [
          CommonBottomSheetAction<bool>(
            text: AppStrings.couponConfirmButtonText,
            result: true,
          ),
        ],
      );

      if (mounted && confirmed == true) {
        setState(() {
          _selectedCoupon = tempSelectedCoupon;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCouponSheetOpen = false;
        });
      }
    }
  }

  Future<List<CouponItem>> _loadCoupons(
    List<RepayDetailRespDataLoanOrderDetails> orders,
  ) {
    // 多订单还款按订单和产品维度筛选可用的贷后全额还款优惠券。
    return ref.read(
      couponListProvider(
        CouponRequestParams(
          appOrderIds: _couponAppOrderIds(orders),
          productCodes: _couponProductCodes(orders),
          couponType: CouponTypes.post,
          repaymentType: CouponRepaymentTypes.fullAmount,
        ),
      ).future,
    );
  }
}

// 优惠券弹层内容加载：多订单页复用统一券列表样式并回传单选结果。
class _CouponBottomSheetLoader extends StatelessWidget {
  const _CouponBottomSheetLoader({
    required this.future,
    required this.onSelectionChanged,
    this.initialSelectedCouponId,
  });

  final Future<List<CouponItem>> future;
  final int? initialSelectedCouponId;
  final ValueChanged<CouponItem?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 104,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF268470),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error?.toString();
          return SizedBox(
            height: 104,
            child: Center(
              child: Text(
                (message == null || message.isEmpty)
                    ? AppStrings.couponLoadFailed
                    : message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8A8F98)),
              ),
            ),
          );
        }

        return CouponBottomSheetContent(
          coupons: snapshot.data ?? const <CouponItem>[],
          initialSelectedCouponId: initialSelectedCouponId,
          onSelectionChanged: onSelectionChanged,
        );
      },
    );
  }
}

class _RepayMultiHeader extends StatelessWidget {
  const _RepayMultiHeader({required this.detail});

  final RepayDetailRespData? detail;

  @override
  Widget build(BuildContext context) {
    final orders = detail?.loanOrderDetails ?? const [];
    final loanAmount = _sumOrderAmount(orders, (order) => order.loanAmount);
    final interest = _sumOrderAmount(orders, (order) => order.interest);
    final overdueFee = _sumOrderAmount(
      orders.where((order) => _isOverdue(order)).toList(),
      (order) => order.serviceFee,
    );
    // 顶部主金额展示多订单确认还款总额
    final totalRepayAmount = detail?.totalSureRepayAmounts ?? 0;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 10,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                // title
                const Text(
                  AppStrings.repayMultiDetailTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 20 / 16,
                  ),
                ),
                Positioned(
                  right: 18,
                  child: Assets.images.customer.image(width: 32, height: 32),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 16),
          _TotalRepayAmountDisplay(amount: totalRepayAmount),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    amount: loanAmount,
                    label: AppStrings.repayMultiTotalLoanAmountLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    amount: interest,
                    label: AppStrings.repayMultiTotalInterestLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    amount: overdueFee,
                    label: AppStrings.repayMultiTotalOverdueFeeLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRepayAmountDisplay extends StatelessWidget {
  const _TotalRepayAmountDisplay({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: AppStrings.orderDetailCurrencyCode,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 36 / 26,
            ),
          ),
          TextSpan(
            text: amount.toDouble().formatAmount(showCurrencySymbol: false),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 38 / 32,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.amount, required this.label});

  final num amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount.toDouble().formatAmount(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 16 / 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
              height: 12 / 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepayMultiContent extends StatelessWidget {
  const _RepayMultiContent({
    required this.detail,
    required this.selectedCoupon,
    required this.onCouponTap,
  });

  final RepayDetailRespData detail;
  final CouponItem? selectedCoupon;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    final orders = detail.loanOrderDetails ?? const [];
    final selected = selectedCoupon;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        10,
        16,
        10,
        MediaQuery.of(context).padding.bottom + 92,
      ),
      child: Column(
        children: [
          if (selected == null)
            CouponEntryCard(onTap: onCouponTap)
          else
            SelectedCouponCard(
              couponName: _couponName(selected),
              amountText: _couponAmountText(selected),
              onTap: onCouponTap,
            ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const _RepayMultiStateView(
              icon: Icons.receipt_long_outlined,
              text: AppStrings.orderDetailNoOrderData,
            )
          else
            ...List.generate(orders.length, (index) {
              final order = orders[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == orders.length - 1 ? 0 : 12,
                ),
                child: LoanOrderCard(
                  productName: _productName(order),
                  productLogo: order.productLogo,
                  statusBadge: _overdueStatusBadge(order),
                  rows: _multiOrderRows(order),
                ),
              );
            }),
        ],
      ),
    );
  }
}

List<LoanOrderCardRowData> _multiOrderRows(
  RepayDetailRespDataLoanOrderDetails order,
) {
  final rows = <LoanOrderCardRowData>[
    LoanOrderCardRowData(
      label: AppStrings.loanOrderLoanAmountLabel,
      value: _amountText(order.loanAmount),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderInterestLabel,
      value: _amountText(order.interest),
    ),
  ];

  if (_isOverdue(order)) {
    rows.add(
      LoanOrderCardRowData(
        label: AppStrings.loanOrderOverdueFeeLabel,
        value: _amountText(order.serviceFee),
      ),
    );
  }

  rows.addAll([
    LoanOrderCardRowData(
      label: AppStrings.loanOrderRepayAmountLabel,
      value: _amountText(order.repaymentAmount),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderDueDateLabel,
      value:
          order.repayDate?.formatBackendDate() ??
          AppStrings.loanOrderEmptyValue,
    ),
  ]);

  return rows;
}

LoanOrderCardStatusBadgeData? _overdueStatusBadge(
  RepayDetailRespDataLoanOrderDetails order,
) {
  if (!_isOverdue(order)) return null;

  return const LoanOrderCardStatusBadgeData(
    text: AppStrings.loanOrderStatusOverdue,
    gradient: [Color(0xFFEA4335), Color(0xFFFF8A65)],
  );
}

class _RepayMultiStateView extends StatelessWidget {
  const _RepayMultiStateView({
    this.child,
    this.icon,
    this.text = '',
    this.actionText = '',
    this.onActionTap,
  });

  final Widget? child;
  final IconData? icon;
  final String text;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final customChild = child;
    if (customChild != null) return Center(child: customChild);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 54, color: const Color(0xFFACACAC)),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF787878),
                height: 20 / 14,
              ),
            ),
          ],
          if (actionText.isNotEmpty && onActionTap != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onActionTap, child: Text(actionText)),
          ],
        ],
      ),
    );
  }
}

num _sumOrderAmount(
  Iterable<RepayDetailRespDataLoanOrderDetails> orders,
  num? Function(RepayDetailRespDataLoanOrderDetails order) valueOf,
) {
  return orders.fold<num>(0, (sum, order) => sum + (valueOf(order) ?? 0));
}

bool _isOverdue(RepayDetailRespDataLoanOrderDetails order) {
  return (order.remainingDay ?? 0) < 0;
}

String _amountText(num? value) {
  return (value ?? 0).toDouble().formatAmount(showCurrencySymbol: true);
}

String _couponName(CouponItem coupon) {
  final title = coupon.title?.trim();
  return title == null || title.isEmpty ? AppStrings.couponString : title;
}

String _couponAmountText(CouponItem coupon) {
  final summary = coupon.summary?.trim();
  return summary == null || summary.isEmpty
      ? AppStrings.couponSelectedFallback
      : summary;
}

String _productName(RepayDetailRespDataLoanOrderDetails order) {
  return order.productName?.isNotEmpty == true
      ? order.productName!
      : AppStrings.loanOrderProductFallback;
}

// 优惠券接口参数：多订单只传可解析且大于 0 的订单 ID。
List<int> _couponAppOrderIds(List<RepayDetailRespDataLoanOrderDetails> orders) {
  return orders
      .map((item) => int.tryParse(item.appOrderId?.trim() ?? ''))
      .whereType<int>()
      .where((id) => id > 0)
      .toList();
}

// 优惠券接口参数：按多订单涉及的产品编码去重。
List<String> _couponProductCodes(
  List<RepayDetailRespDataLoanOrderDetails> orders,
) {
  return orders
      .map((item) => item.productCode?.trim())
      .whereType<String>()
      .where((code) => code.isNotEmpty)
      .toSet()
      .toList();
}
