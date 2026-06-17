import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/repay/repay_extension_resp.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_content.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/providers/loan_confirm_provider.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';
import 'package:easy_moni/pages/repay/providers/repay_extension_provider.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
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
    final installmentId = widget.requestData.installmentId;
    final detailAsync = ref.watch(repayExtensionProvider(installmentId));
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
        hasSelectedCoupon: _selectedCoupon != null,
      ),
      content: detailAsync.when(
        data: (data) => _RepayExtensionContent(
          detail: data,
          selectedCoupon: _selectedCoupon,
          onCouponTap: () => _showCoupons(),
          onCouponClear: () => setState(() => _selectedCoupon = null),
        ),
        error: (_, _) => _RepayExtensionStateView(
          icon: Icons.error_outline_rounded,
          text: AppStrings.repayExtensionLoadFailed,
          actionText: AppStrings.repayEntryRetry,
          onActionTap: () =>
              ref.invalidate(repayExtensionProvider(installmentId)),
        ),
        loading: () =>
            const _RepayExtensionStateView(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: detail != null,
        text: AppStrings.repayExtensionConfirm,
        onPressed: detail == null ? null : () => _submitExtension(context),
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
        content: _CouponBottomSheetLoader(
          future: _loadCoupons(),
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

  Future<List<CouponItem>> _loadCoupons() async {
    // TODO: 与后端确认展期场景是否需要独立的 couponType 或 repaymentType。
    final result = await ref
        .read(loanConfirmProvider)
        .fetchCoupons(
          appOrderIds: _couponAppOrderIds(widget.requestData.bill),
          productCodes: _couponProductCodes(widget.requestData.bill),
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

  void _submitExtension(BuildContext context) {
    // TODO: 确认展期提交接口、优惠券 couponIds 入参和支付跳转参数后替换为真实流程。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.repayExtensionSubmitPending)),
    );
  }
}

// 优惠券弹层内容加载：复用贷款确认页的优惠券列表样式，并将选择结果交回展期页。
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

class _RepayExtensionHeader extends StatelessWidget {
  const _RepayExtensionHeader({
    required this.detail,
    required this.hasSelectedCoupon,
  });

  final RepayExtensionRespData? detail;
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
                  child: Assets.images.customer.image(width: 32, height: 32),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
            child: Column(
              children: [
                Text(
                  // 展示优惠后金额
                  _amountText(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 38 / 32,
                  ),
                ),
                if (hasSelectedCoupon) ...[
                const SizedBox(height: 2),
                // 展示优惠前金额
                Text(
                  _amountText(detail?.extensionFee),
                  style: const TextStyle(
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

class _RepayExtensionContent extends StatelessWidget {
  const _RepayExtensionContent({
    required this.detail,
    required this.selectedCoupon,
    required this.onCouponTap,
    required this.onCouponClear,
  });

  final RepayExtensionRespData detail;
  final CouponItem? selectedCoupon;
  final VoidCallback onCouponTap;
  final VoidCallback onCouponClear;

  @override
  Widget build(BuildContext context) {
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
          CouponEntryCard(
            selectedCoupon: selectedCoupon,
            onClear: onCouponClear,
            onTap: onCouponTap,
          ),
          const SizedBox(height: 16),
          _RepayExtensionInfoCard(detail: detail),
        ],
      ),
    );
  }
}

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
        Expanded(
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

class _RepayExtensionStateView extends StatelessWidget {
  const _RepayExtensionStateView({
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

String _amountText(num? value) {
  return (value ?? 0).toDouble().formatAmount(showCurrencySymbol: true);
}

List<int> _couponAppOrderIds(RepayResp bill) {
  final id = int.tryParse(bill.appOrderId?.trim() ?? '');
  if (id == null || id <= 0) return const <int>[];
  return [id];
}

List<String> _couponProductCodes(RepayResp bill) {
  // TODO: 与后端确认展期优惠券筛选应使用 productSetCode 还是订单详情里的 productCode。
  final code = bill.productSetCode?.trim();
  if (code == null || code.isEmpty) return const <String>[];
  return [code];
}
