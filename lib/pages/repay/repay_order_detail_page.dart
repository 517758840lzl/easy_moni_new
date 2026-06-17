import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_content.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/loan_confirm_provider.dart';
import 'package:easy_moni/pages/repay/components/overdue_badge.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_detail_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 单笔订单还款详情页，承接待还账单列表进入后的订单确认与还款操作。
class RepayOrderDetailPage extends ConsumerStatefulWidget {
  const RepayOrderDetailPage({super.key, required this.bill});

  final RepayResp bill;

  @override
  ConsumerState<RepayOrderDetailPage> createState() =>
      _RepayOrderDetailPageState();
}

class _RepayOrderDetailPageState extends ConsumerState<RepayOrderDetailPage> {
  bool _isCouponSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final appOrderIdsParam = buildRepayDetailAppOrderIdsParam([
      widget.bill.appOrderId,
    ]);
    final detailAsync = ref.watch(repayOrderDetailProvider(appOrderIdsParam));
    final detail = detailAsync.when(
      data: (data) => data,
      error: (_, _) => null,
      loading: () => null,
    );
    final showExtensionButton =
        detail?.isExtensionSwitch ?? widget.bill.isExtensionSwitch ?? false;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 114,
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayDetailHeader(bill: widget.bill, detail: detail),
      content: detailAsync.when(
        data: (data) => _RepayDetailContent(
          detail: data,
          onCouponTap: () => _showCoupons(data),
        ),
        error: (_, _) => _RepayDetailStateView(
          icon: Icons.error_outline_rounded,
          text: AppStrings.orderDetailLoadFailed,
          actionText: AppStrings.repayEntryRetry,
          onActionTap: () =>
              ref.invalidate(repayOrderDetailProvider(appOrderIdsParam)),
        ),
        loading: () =>
            const _RepayDetailStateView(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: _RepayDetailActions(
        showExtensionButton: showExtensionButton,
        onExtensionTap: () => _openExtension(context, detail),
        onRepayTap: () => _openPayment(context),
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
      await CommonBottomSheet.show<void>(
        context: context,
        title: '',
        description: '',
        content: _CouponBottomSheetLoader(future: _loadCoupons(orders)),
        actions: const [
          CommonBottomSheetAction<void>(
            text: AppStrings.couponConfirmButtonText,
          ),
        ],
      );
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
    final result = await ref
        .read(loanConfirmProvider)
        .fetchCoupons(
          // TODO: 与后端确认还款场景是否需要独立的 couponType 或 repaymentType。
          appOrderIds: _couponAppOrderIds(orders),
          productCodes: _couponProductCodes(orders),
        );

    if (!result.isSuccess || result.data == null) {
      throw result.message ?? AppStrings.couponLoadFailed;
    }

    final couponData = result.data?.data;
    if (couponData?.showCouponCard != 1) {
      return const <CouponItem>[];
    }

    return couponData?.coupons ?? const <CouponItem>[];
  }

  void _openPayment(BuildContext context) {
    // TODO: 支付页尚未在路由表中注册，确认单笔还款支付页面参数后替换为真实跳转。
    _showSnack(context, AppStrings.repayDetailPaymentPending);
  }

  void _openExtension(BuildContext context, RepayDetailRespData? detail) {
    final installmentId = _firstOrder(detail)?.installmentId;
    context.pushNamed(
      AppRouteNames.repayExtension,
      extra: RepayExtensionRequestData(
        bill: widget.bill,
        installmentId: installmentId,
      ),
    );
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

// 优惠券弹层内容加载：保持与确认借款页相同的加载、失败和内容展示流程。
class _CouponBottomSheetLoader extends StatelessWidget {
  const _CouponBottomSheetLoader({required this.future});

  final Future<List<CouponItem>> future;

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
        );
      },
    );
  }
}

class _RepayDetailHeader extends StatelessWidget {
  const _RepayDetailHeader({required this.bill, required this.detail});

  final RepayResp bill;
  final RepayDetailRespData? detail;

  @override
  Widget build(BuildContext context) {
    final firstOrder = _firstOrder(detail);
    // 顶部区域突出展示当前单笔订单应还金额，详情未返回前使用列表金额兜底。
    final repaymentAmount =
        firstOrder?.repaymentAmount ?? bill.repayAmount ?? 0;

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
                  child: Assets.images.customer.image(width: 32, height: 32),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _amountText(repaymentAmount),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 38 / 32,
                      ),
                    ),
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
  const _RepayDetailContent({required this.detail, required this.onCouponTap});

  final RepayDetailRespData detail;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    final orders = detail.loanOrderDetails ?? const [];
    final showOverdueBadge = _hasOverdueOrder(detail);

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
          CouponEntryCard(onTap: onCouponTap),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const _RepayDetailStateView(
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
        value: _amountText(order.serviceFee),
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

/// 订单 remainingDay 小于 0 时视为逾期。
bool _isOrderOverdue(RepayDetailRespDataLoanOrderDetails order) {
  return (order.remainingDay ?? 0) < 0;
}

bool _hasOverdueOrder(RepayDetailRespData detail) {
  final orders = detail.loanOrderDetails ?? const [];
  if (orders.isEmpty) return (detail.remainingDay ?? 0) < 0;
  return orders.any(_isOrderOverdue);
}

String _amountText(num? value) {
  return (value ?? 0).toDouble().formatAmount(showCurrencySymbol: true);
}

String _productName(RepayDetailRespDataLoanOrderDetails order) {
  return order.productName?.isNotEmpty == true
      ? order.productName!
      : AppStrings.loanOrderProductFallback;
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

class _RepayDetailActions extends StatelessWidget {
  const _RepayDetailActions({
    required this.showExtensionButton,
    required this.onExtensionTap,
    required this.onRepayTap,
  });

  final bool showExtensionButton;
  final VoidCallback onExtensionTap;
  final VoidCallback onRepayTap;

  @override
  Widget build(BuildContext context) {
    if (showExtensionButton) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: PermissionActionButtons(
            secondaryText: AppStrings.repayDetailApplyExtension,
            primaryText: AppStrings.repayDetailRepayNow,
            onSecondaryPressed: onExtensionTap,
            onPrimaryPressed: onRepayTap,
          ),
        ),
      );
    }

    return LoanBottomActionButton(
      enabled: true,
      text: AppStrings.repayDetailRepayNow,
      onPressed: onRepayTap,
    );
  }
}

class _RepayDetailStateView extends StatelessWidget {
  const _RepayDetailStateView({
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
    if (customChild != null) {
      return Center(child: customChild);
    }

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
