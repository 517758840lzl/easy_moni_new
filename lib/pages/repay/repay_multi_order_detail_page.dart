import 'dart:async';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/entities/use_coupon_resp/use_coupon_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_loader.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/models/repay_multi_order_detail_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_detail_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/selected_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 多订单还款详情页
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
  UseCouponRespData? _couponAmountPreview;
  bool _isCouponAmountPreviewLoading = false;
  bool _isRepayActionLocked = false;
  int _couponPreviewRequestId = 0;

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
    final showCouponAmount = _shouldShowCouponRepaymentAmount(
      _couponAmountPreview,
    );
    final reserveCouponAmountSpace =
        _isCouponAmountPreviewLoading || showCouponAmount;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + (reserveCouponAmountSpace ? 204 : 180),
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayMultiHeader(
        detail: detail,
        isLoading: detailAsync.isLoading,
        couponAmountPreview: _couponAmountPreview,
        isCouponAmountLoading: _isCouponAmountPreviewLoading,
      ),
      content: detailAsync.when(
        data: (data) => _RepayMultiContent(
          detail: data,
          selectedCoupon: _selectedCoupon,
          onCouponTap: () => _showCoupons(data),
        ),
        error: (_, _) => AppErrorStateView(
          text: AppStrings.orderDetailLoadFailed,
          onReload: () => ref.invalidate(repayOrderDetailProvider(detailQuery)),
        ),
        loading: () => const AppStateView(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: detail != null && !_isRepayActionLocked,
        text: AppStrings.repayDetailRepayNow,
        onPressed: detail == null || _isRepayActionLocked
            ? null
            : () => _runRepayAction(() => _openPayment(detail)),
      ),
    );
  }

  // 还款入口加锁，避免重复点击造成重复跳转和支付接口频繁调用。
  Future<void> _runRepayAction(FutureOr<void> Function() action) async {
    if (_isRepayActionLocked) return;

    setState(() {
      _isRepayActionLocked = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isRepayActionLocked = false;
        });
      }
    }
  }

  Future<void> _openPayment(RepayDetailRespData detail) async {
    final requestParams = _buildPaymentParams(detail, _selectedCoupon);
    if (requestParams == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.paymentNoOrderData)),
      );
      return;
    }

    await context.push(AppRoutePaths.payment, extra: requestParams);
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
        content: CouponBottomSheetLoader(
          future: _loadCoupons(orders),
          initialSelectedCouponId: _selectedCoupon?.couponId,
          onSelectionChanged: (coupon) {
            tempSelectedCoupon = coupon;
          },
        ),
        actions: const [
          CommonBottomSheetAction<bool>(text: AppStrings.confirm, result: true),
        ],
      );

      if (mounted && confirmed == true) {
        _updateSelectedCoupon(data: detail, coupon: tempSelectedCoupon);
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

  // 确认多订单优惠券后，刷新顶部优惠金额试算结果。
  void _updateSelectedCoupon({
    required RepayDetailRespData data,
    required CouponItem? coupon,
  }) {
    _couponPreviewRequestId++;
    final couponId = coupon?.couponId;
    setState(() {
      _selectedCoupon = coupon;
      _couponAmountPreview = null;
      _isCouponAmountPreviewLoading = couponId != null && couponId > 0;
    });

    if (couponId == null || couponId <= 0) {
      return;
    }

    _loadCouponAmountPreview(data, couponId);
  }

  Future<void> _loadCouponAmountPreview(
    RepayDetailRespData detail,
    int couponId,
  ) async {
    final orders = detail.loanOrderDetails ?? const [];
    final requestId = ++_couponPreviewRequestId;
    try {
      final preview = await ref.read(
        useCouponPostProvider(
          UseCouponRequestParams(
            appOrderIds: _couponAppOrderIds(orders),
            couponIds: [couponId],
            productCodes: _couponProductCodes(orders),
          ),
        ).future,
      );
      if (!mounted || requestId != _couponPreviewRequestId) return;
      setState(() {
        _couponAmountPreview = preview;
        _isCouponAmountPreviewLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _couponPreviewRequestId) return;
      setState(() {
        _isCouponAmountPreviewLoading = false;
      });
      _showSnack(context, error.toString());
    }
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _RepayMultiHeader extends StatelessWidget {
  const _RepayMultiHeader({
    required this.detail,
    required this.isLoading,
    required this.couponAmountPreview,
    required this.isCouponAmountLoading,
  });

  final RepayDetailRespData? detail;
  final bool isLoading;
  final UseCouponRespData? couponAmountPreview;
  final bool isCouponAmountLoading;

  @override
  Widget build(BuildContext context) {
    final orders = detail?.loanOrderDetails ?? const [];
    final loanAmount = _sumOrderAmount(orders, (order) => order.loanAmount);
    final interest = _sumOrderAmount(orders, (order) => order.interest);
    final overdueFee = _sumOrderAmount(
      orders.where((order) => _isOverdue(order)).toList(),
      (order) => order.overdueInterest,
    );
    // 顶部主金额展示多订单确认还款总额
    final totalRepayAmount = detail?.totalSureRepayAmounts;
    final previewAmount = couponAmountPreview?.newRepaymentAmount;
    final originalAmount = couponAmountPreview?.repaymentAmount;
    final showCouponAmount = _shouldShowCouponRepaymentAmount(
      couponAmountPreview,
    );

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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(AppRoutePaths.customerService),
                    child: Assets.images.customer.image(width: 32, height: 32),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (isCouponAmountLoading)
                  Container(
                    margin: const EdgeInsets.all(14),
                    width: 32,
                    height: 32,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (showCouponAmount)
                  Column(
                    children: [
                      TotalRepayAmountDisplay(amount: previewAmount ?? 0),
                      const SizedBox(height: 4),
                      TotalRepayAmountDisplay(
                        amount: originalAmount ?? 0,
                        currencyStyle: _couponOriginalAmountStyle,
                        amountStyle: _couponOriginalAmountStyle,
                      ),
                    ],
                  )
                else if (totalRepayAmount != null)
                  TotalRepayAmountDisplay(amount: totalRepayAmount),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.amount, required this.label});

  final num? amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.repayHeaderRectangle.provider(),
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount == null
                  ? AppStrings.loanOrderEmptyValue
                  : amount!.formatAmount(),
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
      ),
    );
  }
}

const TextStyle _couponOriginalAmountStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  color: Color(0xCCFFFFFF),
  height: 24 / 20,
  decoration: TextDecoration.lineThrough,
  decorationColor: Color(0xCCFFFFFF),
);

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
            const AppEmptyStateView(text: AppStrings.orderDetailNoOrderData)
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
        value: _amountText(order.overdueInterest),
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

num? _sumOrderAmount(
  Iterable<RepayDetailRespDataLoanOrderDetails> orders,
  num? Function(RepayDetailRespDataLoanOrderDetails order) valueOf,
) {
  num? total;
  for (final order in orders) {
    final value = valueOf(order);
    if (value == null) continue;
    total = (total ?? 0) + value;
  }
  return total;
}

bool _isOverdue(RepayDetailRespDataLoanOrderDetails order) {
  return (order.remainingDay ?? 0) < 0;
}

String _amountText(num? value) {
  return (value ?? 0).formatAmount(showCurrencySymbol: true);
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

// 还款优惠券金额试算：仅当优惠后金额小于原始总还金额时展示双行金额。
bool _shouldShowCouponRepaymentAmount(UseCouponRespData? preview) {
  final previewAmount = preview?.newRepaymentAmount;
  final originalAmount = preview?.repaymentAmount;
  return previewAmount != null &&
      originalAmount != null &&
      previewAmount < originalAmount;
}

String _productName(RepayDetailRespDataLoanOrderDetails order) {
  return order.productName?.isNotEmpty == true
      ? order.productName!
      : AppStrings.loanOrderProductFallback;
}

PaymentRequestParams? _buildPaymentParams(
  RepayDetailRespData detail,
  CouponItem? selectedCoupon,
) {
  final orders = detail.loanOrderDetails ?? const [];
  final allocations = orders
      .map(_paymentAllocationFromOrder)
      .whereType<PaymentAllocation>()
      .toList();
  if (allocations.isEmpty) return null;

  return PaymentRequestParams(
    allocations: allocations,
    couponIds: _selectedCouponIds(selectedCoupon),
    orderType: PaymentOrderTypes.normal,
    repayAmount: detail.totalSureRepayAmounts ?? 0,
    originalTotalRepayAmount: 0,
    choseProductCodes: _paymentProductCodes(orders),
  );
}

PaymentAllocation? _paymentAllocationFromOrder(
  RepayDetailRespDataLoanOrderDetails order,
) {
  final appOrderId = _paymentOrderId(order.appOrderId);
  final installmentId = order.installmentId;
  if (appOrderId == null || installmentId == null || installmentId <= 0) {
    return null;
  }

  return PaymentAllocation(
    // 多订单分账金额逐笔取订单明细的应还金额。
    allocationAmount: order.repaymentAmount ?? 0,
    appOrderId: appOrderId,
    installmentId: installmentId,
  );
}

Object? _paymentOrderId(String? appOrderId) {
  final value = appOrderId?.trim();
  if (value == null || value.isEmpty) return null;
  return int.tryParse(value) ?? value;
}

List<int> _selectedCouponIds(CouponItem? coupon) {
  final couponId = coupon?.couponId;
  if (couponId == null || couponId <= 0) return const <int>[];
  return [couponId];
}

List<String> _paymentProductCodes(
  List<RepayDetailRespDataLoanOrderDetails> orders,
) {
  return orders
      .map((item) => item.productCode?.trim())
      .whereType<String>()
      .where((code) => code.isNotEmpty)
      .toSet()
      .toList();
}

// 优惠券接口参数
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
