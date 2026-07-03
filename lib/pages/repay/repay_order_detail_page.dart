import 'dart:async';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/entities/use_coupon_resp/use_coupon_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_loader.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:easy_moni/pages/repay/components/overdue_badge.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/models/repay_order_detail_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_detail_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:easy_moni/utils/widgets/selected_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 单笔订单还款详情页，承接待还账单列表进入后的订单确认与还款操作。
class RepayOrderDetailPage extends ConsumerStatefulWidget {
  const RepayOrderDetailPage({super.key, required this.requestData});

  final RepayOrderDetailRequestData requestData;

  @override
  ConsumerState<RepayOrderDetailPage> createState() =>
      _RepayOrderDetailPageState();
}

class _RepayOrderDetailPageState extends ConsumerState<RepayOrderDetailPage> {
  bool _isCouponSheetOpen = false;
  CouponItem? _selectedCoupon;
  UseCouponRespData? _couponAmountPreview;
  bool _isCouponAmountPreviewLoading = false;
  bool _isBottomActionLocked = false;
  int _couponPreviewRequestId = 0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final detailQuery = buildRepayDetailQuery(
      appOrderIds: widget.requestData.appOrderIds,
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
    final showExtensionButton =
        detail?.isExtensionSwitch == true && _firstOrder(detail) != null;
    final isActionReady = detail != null;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + (reserveCouponAmountSpace ? 138 : 114),
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayDetailHeader(
        detail: detail,
        couponAmountPreview: _couponAmountPreview,
        isCouponAmountLoading: _isCouponAmountPreviewLoading,
      ),
      content: detailAsync.when(
        data: (data) => _RepayDetailContent(
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
      bottomNavigationBar: _RepayDetailActions(
        isActionReady: isActionReady,
        isActionLocked: _isBottomActionLocked,
        showExtensionButton: showExtensionButton,
        onExtensionTap: () => _runBottomAction(() => _openExtension(detail)),
        onRepayTap: () => _runBottomAction(() => _openPayment(detail)),
      ),
    );
  }

  Future<void> _showCoupons(RepayDetailRespData detail) async {
    if (_isCouponSheetOpen) return;
    final orders = detail.loanOrderDetails ?? const [];
    if (orders.isEmpty) return;

    setState(() {
      _isCouponSheetOpen = true;
    });

    try {
      CouponItem? tempSelectedCoupon = _selectedCoupon;

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
        _updateSelectedCoupon(detail, tempSelectedCoupon);
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
  ) async {
    // 点击入口后实时拉取优惠券列表，确保还款前看到的是当前订单可用券。
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

  // 确认优惠券选择后更新页面状态，并拉取优惠后的金额预览。
  void _updateSelectedCoupon(RepayDetailRespData detail, CouponItem? coupon) {
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
    _loadCouponAmountPreview(detail, couponId);
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

  // 底部操作加锁，避免用户连续点击造成重复跳转和后续接口频繁调用。
  Future<void> _runBottomAction(FutureOr<void> Function() action) async {
    if (_isBottomActionLocked) return;

    setState(() {
      _isBottomActionLocked = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isBottomActionLocked = false;
        });
      }
    }
  }

  Future<void> _openPayment(RepayDetailRespData? detail) async {
    final requestParams = _buildPaymentParams(detail, _selectedCoupon);
    if (requestParams == null) {
      _showSnack(context, AppStrings.paymentNoOrderData);
      return;
    }

    await context.push(AppRoutePaths.payment, extra: requestParams);
  }

  Future<void> _openExtension(RepayDetailRespData? detail) async {
    final order = _firstOrder(detail);
    if (order == null) return;

    await context.push(
      AppRoutePaths.repayExtensionWithParams(
        appOrderId: order.appOrderId,
        productCode: order.productCode,
        installmentId: order.installmentId,
      ),
    );
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _RepayDetailHeader extends StatelessWidget {
  const _RepayDetailHeader({
    required this.detail,
    required this.couponAmountPreview,
    required this.isCouponAmountLoading,
  });

  final RepayDetailRespData? detail;
  final UseCouponRespData? couponAmountPreview;
  final bool isCouponAmountLoading;

  @override
  Widget build(BuildContext context) {
    final firstOrder = _firstOrder(detail);
    final repaymentAmount = firstOrder?.repaymentAmount ?? 0;
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
                const Text(
                  AppStrings.repayDetailTitle,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isCouponAmountLoading)
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
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
                            currencyStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xCCFFFFFF),
                              height: 24 / 20,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xCCFFFFFF),
                            ),
                            amountStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xCCFFFFFF),
                              height: 24 / 20,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xCCFFFFFF),
                            ),
                          ),
                        ],
                      )
                    else
                      TotalRepayAmountDisplay(amount: repaymentAmount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 白色内容区域
class _RepayDetailContent extends StatelessWidget {
  const _RepayDetailContent({
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
    final showOverdueBadge = _hasOverdueOrder(detail);
    final selected = selectedCoupon;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        14,
        16,
        14,
        MediaQuery.of(context).padding.bottom + 92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                AppStrings.orderDetailTitle,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              if (showOverdueBadge) ...[
                const SizedBox(width: 8),
                const OverdueBadge(),
              ],
            ],
          ),

          const SizedBox(height: 8),
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
                  rows: _repayOrderRows(order),
                ),
              );
            }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// 还款详情订单字段：页面适配层负责决定展示哪些账单信息。
List<LoanOrderCardRowData> _repayOrderRows(
  RepayDetailRespDataLoanOrderDetails order,
) {
  final remainingDay = order.remainingDay ?? 0;
  final isOverdue = _isOrderOverdue(order);
  final dueDate =
      order.repayDate?.formatBackendDate() ?? AppStrings.loanOrderEmptyValue;

  return [
    LoanOrderCardRowData(
      label: AppStrings.loanOrderLoanAmountLabel,
      value: _amountText(order.loanAmount),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderInterestLabel,
      value: _amountText(order.interest),
    ),
    if (isOverdue) ...[
      LoanOrderCardRowData(
        label: AppStrings.loanOrderOverdueFeeLabel,
        value: _amountText(order.overdueInterest),
      ),
      LoanOrderCardRowData(
        label: AppStrings.loanOrderOverdueDaysLabel,
        value: AppStrings.orderDetailDayValue(remainingDay.abs()),
      ),
    ] else
      LoanOrderCardRowData(
        label: AppStrings.loanOrderRemainingDayLabel,
        value: AppStrings.orderDetailDayValue(remainingDay),
      ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderDueDateLabel,
      value: dueDate,
    ),
  ];
}

bool _isOrderOverdue(RepayDetailRespDataLoanOrderDetails order) {
  return (order.remainingDay ?? 0) < 0;
}

bool _hasOverdueOrder(RepayDetailRespData detail) {
  final orders = detail.loanOrderDetails ?? const [];
  if (orders.isEmpty) return (detail.remainingDay ?? 0) < 0;
  return orders.any(_isOrderOverdue);
}

String _amountText(num? value) {
  return (value ?? 0).formatAmount(showCurrencySymbol: true);
}

String _productName(RepayDetailRespDataLoanOrderDetails order) {
  return order.productName?.isNotEmpty == true
      ? order.productName!
      : AppStrings.loanOrderProductFallback;
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

// 还款优惠券金额预览：仅在新应还金额小于原应还金额时展示优惠态。
bool _shouldShowCouponRepaymentAmount(UseCouponRespData? preview) {
  final previewAmount = preview?.newRepaymentAmount;
  final originalAmount = preview?.repaymentAmount;
  return previewAmount != null &&
      originalAmount != null &&
      previewAmount < originalAmount;
}

// 优惠券接口参数：还款详情返回的订单 ID 为字符串，这里仅保留可转换的有效 ID。
List<int> _couponAppOrderIds(List<RepayDetailRespDataLoanOrderDetails> orders) {
  return orders
      .map((item) => int.tryParse(item.appOrderId?.trim() ?? ''))
      .whereType<int>()
      .where((id) => id > 0)
      .toList();
}

// 优惠券接口参数：按当前待还产品去重，后端会根据产品维度筛选可用券。
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

RepayDetailRespDataLoanOrderDetails? _firstOrder(RepayDetailRespData? detail) {
  final orders = detail?.loanOrderDetails;
  if (orders == null || orders.isEmpty) return null;
  return orders.first;
}

PaymentRequestParams? _buildPaymentParams(
  RepayDetailRespData? detail,
  CouponItem? selectedCoupon,
) {
  final orders = detail?.loanOrderDetails ?? const [];
  final allocations = orders
      .map(_paymentAllocationFromOrder)
      .whereType<PaymentAllocation>()
      .toList();
  if (allocations.isEmpty) return null;

  final repayAmount = detail?.totalSureRepayAmounts ?? 0;

  return PaymentRequestParams(
    allocations: allocations,
    couponIds: _selectedCouponIds(selectedCoupon),
    orderType: PaymentOrderTypes.normal,
    repayAmount: repayAmount,
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

class _RepayDetailActions extends StatelessWidget {
  const _RepayDetailActions({
    required this.isActionReady,
    required this.isActionLocked,
    required this.showExtensionButton,
    required this.onExtensionTap,
    required this.onRepayTap,
  });

  final bool isActionReady;
  final bool isActionLocked;
  final bool showExtensionButton;
  final VoidCallback onExtensionTap;
  final VoidCallback onRepayTap;

  @override
  Widget build(BuildContext context) {
    // 底部按钮需等待订单详情接口完成后才允许点击，避免加载中提前进入支付流程。
    final enabled = isActionReady && !isActionLocked;

    if (showExtensionButton) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: PermissionActionButtons(
            secondaryText: AppStrings.repayDetailApplyExtension,
            primaryText: AppStrings.repayDetailRepayNow,
            onSecondaryPressed: enabled ? onExtensionTap : null,
            onPrimaryPressed: enabled ? onRepayTap : null,
          ),
        ),
      );
    }

    return LoanBottomActionButton(
      enabled: enabled,
      text: AppStrings.repayDetailRepayNow,
      onPressed: enabled ? onRepayTap : null,
    );
  }
}
