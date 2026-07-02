import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/entities/repay/repay_extension_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_loader.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_extension_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/selected_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 展期申请页，负责展示展期费用、优惠券选择和展期后的还款信息。
class RepayExtensionPage extends ConsumerStatefulWidget {
  const RepayExtensionPage({super.key, required this.requestData});

  final RepayExtensionRequestData requestData;

  @override
  ConsumerState<RepayExtensionPage> createState() => _RepayExtensionPageState();
}

class _RepayExtensionPageState extends ConsumerState<RepayExtensionPage> {
  bool _isCouponSheetOpen = false;
  CouponItem? _selectedCoupon;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final installmentId = widget.requestData.firstOrder?.installmentId;
    final detailQuery = buildRepayExtensionQuery(
      installmentId: installmentId,
      couponIds: [_selectedCoupon?.couponId],
    );
    final detailAsync = ref.watch(repayExtensionProvider(detailQuery));
    final detail = detailAsync.when(
      data: (data) => data,
      error: (_, _) => null,
      loading: () => null,
    );

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 140,
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayExtensionHeader(
        detail: detail,
        isLoading: detailAsync.isLoading,
        hasSelectedCoupon: _selectedCoupon != null,
      ),
      content: detailAsync.when(
        data: (data) => _RepayExtensionContent(
          detail: data,
          selectedCoupon: _selectedCoupon,
          onCouponTap: () => _showCoupons(),
        ),
        error: (_, _) => AppErrorStateView(
          text: AppStrings.repayExtensionLoadFailed,
          onReload: () => ref.invalidate(repayExtensionProvider(detailQuery)),
        ),
        loading: () => const AppStateView(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: detail != null,
        text: AppStrings.repayExtensionConfirm,
        onPressed: detail == null
            ? null
            : () => _submitExtension(context, detail),
      ),
    );
  }

  Future<void> _showCoupons() async {
    if (_isCouponSheetOpen) return;

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
          future: _loadCoupons(),
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

  Future<List<CouponItem>> _loadCoupons() async {
    return ref.read(
      couponListProvider(
        CouponRequestParams(
          appOrderIds: _couponAppOrderIds(widget.requestData.loanOrderDetails),
          productCodes: _couponProductCodes(
            widget.requestData.loanOrderDetails,
          ),
          couponType: CouponTypes.post,
          repaymentType: CouponRepaymentTypes.extension,
        ),
      ).future,
    );
  }

  void _submitExtension(BuildContext context, RepayExtensionRespData detail) {
    final requestParams = _buildPaymentParams(
      requestData: widget.requestData,
      detail: detail,
      selectedCoupon: _selectedCoupon,
    );
    if (requestParams == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.paymentNoOrderData)),
      );
      return;
    }

    context.push(AppRoutePaths.payment, extra: requestParams);
  }
}

class _RepayExtensionHeader extends StatelessWidget {
  const _RepayExtensionHeader({
    required this.detail,
    required this.isLoading,
    required this.hasSelectedCoupon,
  });

  final RepayExtensionRespData? detail;
  final bool isLoading;
  final bool hasSelectedCoupon;

  @override
  Widget build(BuildContext context) {
    final amount = hasSelectedCoupon
        ? detail?.newExtensionFee ?? detail?.extensionFee
        : detail?.extensionFee;

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
                  AppStrings.repayExtensionTitle,
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
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              children: [
                if (isLoading && detail == null)
                  const _RepayExtensionAmountLoading()
                else
                  TotalRepayAmountDisplay(amount: amount ?? 0),
                if (!isLoading && hasSelectedCoupon) ...[
                  const SizedBox(height: 2),
                  // 展示优惠前金额
                  TotalRepayAmountDisplay(
                    amount: detail?.extensionFee ?? 0,
                    currencyStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.white70,
                      height: 24 / 16,
                    ),
                    amountStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.white70,
                      height: 24 / 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 展期金额加载态，避免接口返回前展示默认金额造成误导。
class _RepayExtensionAmountLoading extends StatelessWidget {
  const _RepayExtensionAmountLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 38,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );
  }
}

class _RepayExtensionContent extends StatelessWidget {
  const _RepayExtensionContent({
    required this.detail,
    required this.selectedCoupon,
    required this.onCouponTap,
  });

  final RepayExtensionRespData detail;
  final CouponItem? selectedCoupon;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedCoupon;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        10,
        16,
        10,
        MediaQuery.of(context).padding.bottom + 92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.repayExtensionInfoTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 16),
          const _RepayExtensionNotice(),
          const SizedBox(height: 16),
          if (selected == null)
            CouponEntryCard(onTap: onCouponTap)
          else
            SelectedCouponCard(
              couponName: _couponName(selected),
              amountText: _couponAmountText(selected),
              onTap: onCouponTap,
            ),
          const SizedBox(height: 16),
          _RepayExtensionInfoCard(detail: detail),
        ],
      ),
    );
  }
}

// 展期提示横幅
class _RepayExtensionNotice extends StatelessWidget {
  const _RepayExtensionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF4DF),
      padding: const EdgeInsets.fromLTRB(9, 8, 12, 8),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFFFFAA00)),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              AppStrings.repayExtensionNotice,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFAA00),
                height: 12 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 展期字段展示卡片，集中承载延期后的核心账单字段。
class _RepayExtensionInfoCard extends StatelessWidget {
  const _RepayExtensionInfoCard({required this.detail});

  final RepayExtensionRespData detail;

  @override
  Widget build(BuildContext context) {
    final dueDate =
        detail.extensionRepaymentDate?.formatBackendDate() ??
        AppStrings.loanOrderEmptyValue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _RepayExtensionInfoRow(
            label: AppStrings.repayExtensionDaysLabel,
            value: AppStrings.orderDetailDayValue(detail.remainingDay ?? 0),
          ),
          const SizedBox(height: 16),
          _RepayExtensionInfoRow(
            label: AppStrings.repayExtensionNewDueDateLabel,
            value: dueDate,
          ),
          const SizedBox(height: 16),
          _RepayExtensionInfoRow(
            label: AppStrings.repayExtensionNewRepayAmountLabel,
            value: _amountText(detail.totalSureRepayAmounts),
          ),
        ],
      ),
    );
  }
}

class _RepayExtensionInfoRow extends StatelessWidget {
  const _RepayExtensionInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF252629),
              height: 20 / 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 16 / 12,
            ),
          ),
        ),
      ],
    );
  }
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

List<int> _couponAppOrderIds(List<RepayDetailRespDataLoanOrderDetails> orders) {
  return orders
      .map((item) => int.tryParse(item.appOrderId?.trim() ?? ''))
      .whereType<int>()
      .where((id) => id > 0)
      .toList();
}

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

// 构建请求参数
PaymentRequestParams? _buildPaymentParams({
  required RepayExtensionRequestData requestData,
  required RepayExtensionRespData detail,
  required CouponItem? selectedCoupon,
}) {
  final orders = requestData.loanOrderDetails;
  final allocationAmount = detail.extensionFee ?? 0;
  final allocations = orders
      .map(
        (order) => _paymentAllocationFromOrder(
          order: order,
          allocationAmount: allocationAmount,
        ),
      )
      .whereType<PaymentAllocation>()
      .toList();
  if (allocations.isEmpty) return null;

  return PaymentRequestParams(
    allocations: allocations,
    couponIds: _selectedCouponIds(selectedCoupon),
    orderType: PaymentOrderTypes.extension,
    repayAmount: detail.extensionFee ?? 0,
    choseProductCodes: _couponProductCodes(orders),
  );
}

PaymentAllocation? _paymentAllocationFromOrder({
  required RepayDetailRespDataLoanOrderDetails order,
  required num allocationAmount,
}) {
  final appOrderId = _paymentOrderId(order.appOrderId);
  final installmentId = order.installmentId;
  if (appOrderId == null || installmentId == null || installmentId <= 0) {
    return null;
  }

  return PaymentAllocation(
    allocationAmount: allocationAmount,
    appOrderId: appOrderId,
    installmentId: installmentId,
  );
}

Object? _paymentOrderId(String? appOrderId) {
  final value = appOrderId?.trim();
  if (value == null) return null;
  if (value.isEmpty) return null;
  return int.tryParse(value) ?? value;
}

List<int> _selectedCouponIds(CouponItem? coupon) {
  final couponId = coupon?.couponId;
  if (couponId == null || couponId <= 0) return const <int>[];
  return [couponId];
}
