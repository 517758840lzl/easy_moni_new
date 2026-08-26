import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_moni/core/config/privacy_policy_config.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/loan_confirm/loan_confirm_resp.dart';
import 'package:easy_moni/entities/use_coupon_resp/use_coupon_resp.dart';
import 'package:easy_moni/entities/user_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_loader.dart';
import 'package:easy_moni/pages/loan/components/coupon_entry_card.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';
import 'package:easy_moni/pages/loan/providers/coupon_provider.dart';
import 'package:easy_moni/pages/loan/providers/loan_confirm_provider.dart';
import 'package:easy_moni/pages/loan/widgets/loan_confirm_agreement.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:easy_moni/pages/mine/providers/user_info_provider.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/services/upload_data/upload_data_sync_service.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/af_tracker/af_tracker.dart';
import 'package:easy_moni/utils/af_tracker/track_events.dart';
import 'package:easy_moni/utils/widgets/common_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/legal_web_view_page.dart';
import 'package:easy_moni/utils/non_repeatable_click.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/selected_coupon_card.dart';

class LoanConfirmPage extends ConsumerStatefulWidget {
  const LoanConfirmPage({super.key, required this.products});

  // 上个页面选中的借款产品，进入确认页后用它们请求确认信息。
  final List<LoanConfirmRequestProduct> products;

  @override
  ConsumerState<LoanConfirmPage> createState() => _LoanConfirmPageState();
}

class _LoanConfirmPageState extends ConsumerState<LoanConfirmPage> {
  // 页面级状态：分别控制首次加载、提交按钮、错误提示和接口返回数据。
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _agreedToContract = false;
  bool _isCouponSheetOpen = false;
  String? _loadError;
  LoanConfirmResp? _loanConfirmResp;
  CouponItem? _selectedCoupon;
  UseCouponRespData? _couponAmountPreview;
  bool _isCouponAmountPreviewLoading = false;
  int _couponPreviewRequestId = 0;

  // 业务数据统一从响应体中取，避免 build 里重复拆 nullable 链。
  LoanConfirmData? get _confirmData => _loanConfirmResp?.data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 没有产品时直接进入空数据态，避免发起没有意义的确认接口请求。
    if (widget.products.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = null;
        _loanConfirmResp = const LoanConfirmResp();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // 根据选中的产品向服务端拉取确认页金额、还款日、收款账户等信息。
      final api = ref.read(loanConfirmProvider);
      final confirmResult = await api.fetchConfirmInfo(
        products: widget.products,
      );
      if (!mounted) return;

      if (!confirmResult.isSuccess || confirmResult.data == null) {
        setState(() {
          _isLoading = false;
          _loadError = confirmResult.message ?? AppStrings.errorMessage;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _loanConfirmResp = confirmResult.data;
        _selectedCoupon = null;
        _couponAmountPreview = null;
        _isCouponAmountPreviewLoading = false;
        _couponPreviewRequestId++;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = AppStrings.errorMessage;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    if (!_agreedToContract) {
      context.showSnackBar(AppStrings.loanConfirmAgreeRequired, isError: true);
      return;
    }

    final data = _confirmData;
    final orders = data?.list ?? const <LoanConfirmOrder>[];
    if (data == null || orders.isEmpty) {
      return;
    }

    _isSubmitting = true;
    setState(() {});

    try {
      final uploadDataReady = await _checkUploadDataValidBeforeSubmit();
      if (!mounted || !uploadDataReady) return;

      final result = await ref
          .read(loanConfirmProvider)
          .confirmOrder(
            confirmData: data,
            couponIds: _selectedCouponIds(_selectedCoupon),
          );
      if (!mounted) return;
      if (result.isSuccess) {
        await AppsFlyerTracker.logAppsFlyerActionEvent(
          AppsFlyerEventNames.easWithdrawSuccess,
        );
        if (!mounted) return;
        context.go(AppRoutePaths.loanReviewing);
      } else {
        context.showSnackBar(
          result.message ?? AppStrings.loanConfirmErrorText,
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar(AppStrings.loanConfirmErrorText, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // 提交借款申请前检查风控采集数据；如有无效数据，必须先补传成功。
  Future<bool> _checkUploadDataValidBeforeSubmit() async {
    try {
      final checkDataResult = await ref
          .read(checkUploadDataValidProvider)
          .call();
      if (checkDataResult.isSuccess) {
        await ref
            .read(uploadDataSyncServiceProvider)
            .uploadInvalidDataBeforeSubmit(checkDataResult.data);
        return true;
      }

      if (mounted) {
        context.showSnackBar(
          checkDataResult.message ?? AppStrings.loanConfirmUploadDataFailedText,
          isError: true,
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          AppStrings.loanConfirmUploadDataFailedText,
          isError: true,
        );
      }
      return false;
    }
  }

  Future<void> _openLoanAgreement({String? url}) async {
    final target = url?.trim();
    if (target != null && target.isNotEmpty) {
      await LegalWebViewPage.open(
        context,
        title: AppStrings.loanAgreementTitle,
        url: target,
      );
      return;
    }

    final data = _confirmData;
    if (data == null) return;

    final couponPreview = _couponAmountPreview;
    final userInfoApi = ref.read(userInfoProvider);

    await LegalWebViewPage.open(
      context,
      title: AppStrings.loanAgreementTitle,
      resolveUrl: () async {
        final userInfoResult = await userInfoApi.call();
        return PrivacyPolicyConfig.buildLoanAgreementUrl(
          _loanAgreementQueryParamsFromConfirm(
            data: data,
            couponPreview: couponPreview,
            userInfo: userInfoResult.isSuccess ? userInfoResult.data : null,
          ),
        );
      },
    );
  }

  Future<void> _showCoupons() async {
    if (_isCouponSheetOpen) return;
    final orders = _confirmData?.list ?? const <LoanConfirmOrder>[];
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

      if (mounted && confirmed == true && _confirmData != null) {
        _updateSelectedCoupon(data: _confirmData!, coupon: tempSelectedCoupon);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCouponSheetOpen = false;
        });
      }
    }
  }

  Future<List<CouponItem>> _loadCoupons(List<LoanConfirmOrder> orders) async {
    // 点击入口后在弹层内实时拉取优惠券列表，避免用户看到过期券信息。
    return ref.read(
      couponListProvider(
        CouponRequestParams(
          appOrderIds: _couponAppOrderIds(orders),
          productCodes: _couponProductCodes(orders),
          couponType: CouponTypes.pre,
          repaymentType: CouponRepaymentTypes.fullAmount,
        ),
      ).future,
    );
  }

  // 确认优惠券选择后，刷新贷前优惠券金额试算。
  void _updateSelectedCoupon({
    required LoanConfirmData data,
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
    LoanConfirmData data,
    int couponId,
  ) async {
    final orders = data.list ?? const <LoanConfirmOrder>[];
    final requestId = ++_couponPreviewRequestId;
    try {
      final preview = await ref.read(
        useCouponPreProvider(
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
      context.showSnackBar(error.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _confirmData;
    final orders = data?.list ?? const <LoanConfirmOrder>[];
    final hasData = data != null && orders.isNotEmpty;
    final topInset = MediaQuery.of(context).padding.top;
    final reserveCouponAmountSpace =
        _isCouponAmountPreviewLoading ||
        _shouldShowCouponLoanAmount(_couponAmountPreview);
    final couponAmountOffset = reserveCouponAmountSpace ? 24.0 : 0.0;
    final cardTop = topInset + 202 + couponAmountOffset;
    final contentTop = topInset + 278 + couponAmountOffset;

    return Scaffold(
      backgroundColor: const Color(0xFF216A4A),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 背景层：绿色渐变兜底，上方叠加设计稿背景图。
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.loginBg.provider(),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF216A4A), Color(0xFF38B899)],
                  ),
                ),
              ),
            ),
            // 顶部信息层：导航、标题、借款金额和三项汇总数据。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Hero(
                data: data,
                isLoading: _isLoading,
                couponAmountPreview: _couponAmountPreview,
                isCouponAmountLoading: _isCouponAmountPreviewLoading,
                couponAmountOffset: couponAmountOffset,
              ),
            ),
            if (hasData)
              Positioned.fill(
                top: cardTop,
                child: _buildScrollableBody(
                  data: data,
                  orders: orders,
                ),
              )
            else
              Positioned.fill(
                top: contentTop,
                child: _buildContent(data: data, orders: orders),
              ),
          ],
        ),
      ),
      bottomNavigationBar: hasData
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFC3C6D5).withValues(alpha: 0.25),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 12, 17, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoanConfirmAgreement(
                        agreed: _agreedToContract,
                        onChanged: _isSubmitting
                            ? (_) {}
                            : (value) =>
                                  setState(() => _agreedToContract = value),
                        onOpenAgreement: _isSubmitting
                            ? () {}
                            : () => _openLoanAgreement(),
                      ),
                      const SizedBox(height: 12),
                      LoanBottomActionButton(
                        enabled: !_isSubmitting,
                        useSafeArea: false,
                        padding: EdgeInsets.zero,
                        text: _isSubmitting
                            ? AppStrings.loanConfirmButtonLoadingText
                            : AppStrings.loanConfirmButtonText,
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                NonRepeatableClick.checkClick(
                                  debounceDuration: const Duration(seconds: 1),
                                  click: _submitOrder,
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildScrollableBody({
    required LoanConfirmData data,
    required List<LoanConfirmOrder> orders,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadError = _loadError;
    if (loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loadError, style: const TextStyle(color: Color(0xFF909399))),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text(AppStrings.errorMessage),
            ),
          ],
        ),
      );
    }

    return _LoanConfirmScrollBody(
      data: data,
      orders: orders,
      selectedCoupon: _selectedCoupon,
      onCouponTap: _showCoupons,
    );
  }

  Widget _buildContent({
    required LoanConfirmData? data,
    required List<LoanConfirmOrder> orders,
  }) {
    return ColoredBox(
      color: Colors.white,
      child: _buildContentState(data: data, orders: orders),
    );
  }

  Widget _buildContentState({
    required LoanConfirmData? data,
    required List<LoanConfirmOrder> orders,
  }) {
    // 内容区根据加载结果切换订单列表、错误态和空态。
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadError = _loadError;
    if (loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loadError, style: const TextStyle(color: Color(0xFF909399))),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text(AppStrings.errorMessage),
            ),
          ],
        ),
      );
    }

    if (data == null || orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.loanConfirmEmptyText,
              style: TextStyle(fontSize: 14, color: Color(0xFF909399)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// 中间滚动区：固定白底 + MoMo / 优惠券 / 订单列表同步滚动。
class _LoanConfirmScrollBody extends StatelessWidget {
  const _LoanConfirmScrollBody({
    required this.data,
    required this.orders,
    required this.selectedCoupon,
    required this.onCouponTap,
  });

  static const _listTopPadding = 17.0;
  static const _momoBottomPadding = 7.0;

  final LoanConfirmData data;
  final List<LoanConfirmOrder> orders;
  final CouponItem? selectedCoupon;
  final VoidCallback onCouponTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
        ),
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, _momoBottomPadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _MomoAccountCard(data: data),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                10,
                _listTopPadding,
                10,
                16 + bottomInset,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (selectedCoupon == null)
                    CouponEntryCard(onTap: onCouponTap)
                  else
                    SelectedCouponCard(
                      couponName: _couponName(selectedCoupon!),
                      amountText: _couponAmountText(selectedCoupon!),
                      onTap: onCouponTap,
                    ),
                  const SizedBox(height: 14),
                  ...List.generate(orders.length, (index) {
                    final order = orders[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == orders.length - 1 ? 0 : 16,
                      ),
                      child: LoanOrderCard(
                        productName:
                            order.productName?.trim() ??
                            AppStrings.loanOrderProductFallback,
                        productLogo: order.productLogo,
                        rows: _loanConfirmOrderRows(order),
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 确认页订单字段：只展示确认借款需要核对的信息，不展示状态和底部操作。
List<LoanOrderCardRowData> _loanConfirmOrderRows(LoanConfirmOrder item) {
  final dueDate = _dateText(item.dueDate);

  return [
    LoanOrderCardRowData(
      label: AppStrings.loanOrderLoanAmountLabel,
      value: _amountText(item.loanAmount),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderLoanTermLabel,
      value: item.totalServiceDays == null
          ? AppStrings.loanOrderEmptyValue
          : '${item.totalServiceDays} ${AppStrings.loanOrderDaysUnit}',
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderServiceFeeLabel,
      value: _amountText(item.serviceFee),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderInterestLabel,
      value: _amountText(item.interest),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderRepaymentDateLabel,
      value: dueDate,
    ),
  ];
}

// 页面头图区域：展示导航、客服入口、借款总额和三项关键确认信息。
class _Hero extends StatelessWidget {
  const _Hero({
    required this.data,
    required this.isLoading,
    required this.couponAmountPreview,
    required this.isCouponAmountLoading,
    required this.couponAmountOffset,
  });

  final LoanConfirmData? data;
  final bool isLoading;
  final UseCouponRespData? couponAmountPreview;
  final bool isCouponAmountLoading;
  final double couponAmountOffset;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final orders = data?.list ?? const <LoanConfirmOrder>[];
    final repayTotal = _previewRepayTotal(
      orders: orders,
      preview: couponAmountPreview,
    );
    final actualToAccountMoney = _previewActualToAccountMoney(
      data: data,
      preview: couponAmountPreview,
    );
    final previewAmount = couponAmountPreview?.newLoanAmount;
    final originalAmount = couponAmountPreview?.loanAmount;
    final showCouponAmount = _shouldShowCouponLoanAmount(couponAmountPreview);

    return SizedBox(
      height: topInset + 249 + couponAmountOffset,
      child: Stack(
        children: [
          Positioned(
            top: topInset + 4,
            left: 6,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Positioned(
            top: topInset + 16,
            left: 64,
            right: 64,
            child: const Text(
              AppStrings.loanConfirmTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 20 / 16,
              ),
            ),
          ),
          Positioned(
            top: topInset + 11,
            right: 21,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutePaths.customerService),
              child: Assets.images.customer.image(width: 32, height: 32),
            ),
          ),
          Positioned(
            top: topInset + 52,
            left: 20,
            right: 20,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isLoading
                    ? const SizedBox(height: 32)
                    : showCouponAmount
                    ? Column(
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
                    : TotalRepayAmountDisplay(amount: data?.loanAmount ?? 0),
              ),
            ),
          ),
          Positioned(
            top: topInset + 112 + couponAmountOffset,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    icon: Assets.images.loanWallect.image(
                      width: 22,
                      height: 22,
                    ),
                    value: _amountText(actualToAccountMoney),
                    label: AppStrings.loanConfirmActualAmountLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    icon: Assets.images.loanMoney.image(width: 22, height: 22),
                    value: _amountText(repayTotal),
                    label: AppStrings.loanConfirmRepayAmountLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    icon: Assets.images.loanCalender.image(
                      width: 22,
                      height: 22,
                    ),
                    value: _dateText(data?.repayDate),
                    label: AppStrings.loanConfirmRepaymentDateLabel,
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

// 顶部三项摘要中的单个小卡片，如到账金额、应还金额、还款日期。
class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loanHeaderRectangle.provider(),
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              value.formatBackendDate(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 14 / 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.82),
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

// MoMo 收款账户卡：展示实际放款到账的钱包/手机号信息。
class _MomoAccountCard extends StatelessWidget {
  const _MomoAccountCard({required this.data});

  final LoanConfirmData data;

  @override
  Widget build(BuildContext context) {
    final accountName = _emptyWhenNull(data.bankCardName);
    final accountNo = _maskAccountNo(_emptyWhenNull(data.bankCardNo));
    final isCompactScreen = MediaQuery.sizeOf(context).height <= 667;
    final titleFontSize = isCompactScreen ? 15.0 : 16.0;

    return Container(
      height: 92,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFEE5B8), Color(0xFFFFCA7B)],
        ),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SimIcon(),
          const SizedBox(width: 1),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: const Color(0xFF5C2B0B),
                    fontWeight: FontWeight.w900,
                    height: 20 / 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accountNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF471A07),
                    fontWeight: FontWeight.w600,
                    height: 18 / 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppStrings.loanOrderAccountLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5C2B0B),
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 收款账户卡左侧的 SIM/钱包图标。
class _SimIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 57,
      height: 51,
      child: Assets.images.loanYellowCard.image(fit: BoxFit.cover),
    );
  }
}

// 金额展示统一加 GHS 前缀，并按项目扩展方法格式化小数。
String _amountText(num? value) {
  return value == null ? AppStrings.loanOrderEmptyValue : value.formatAmount();
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

// 贷前优惠券金额试算：选券后顶部展示优惠后借款金额及原始金额。
bool _shouldShowCouponLoanAmount(UseCouponRespData? preview) {
  return preview?.newLoanAmount != null && preview?.loanAmount != null;
}

// 实际到账金额：未选券取确认页数据，选券后取贷前优惠券试算结果。
num? _previewActualToAccountMoney({
  required LoanConfirmData? data,
  required UseCouponRespData? preview,
}) {
  return preview == null
      ? data?.actualToAccountMoney
      : preview.actualToAccountMoney;
}

// 贷前优惠券试算后的应还总额：未选券时取订单应还总和，选券后按新借款金额加租金计算。
num? _previewRepayTotal({
  required List<LoanConfirmOrder> orders,
  required UseCouponRespData? preview,
}) {
  if (preview != null) {
    final newLoanAmount = preview.newLoanAmount;
    final rent = preview.rent;
    if (newLoanAmount == null && rent == null) return null;
    return (newLoanAmount ?? 0) + (rent ?? 0);
  }

  num? total;
  for (final item in orders) {
    final amount = item.repayAmount;
    if (amount == null) continue;
    total = (total ?? 0) + amount;
  }
  return total;
}

List<int> _selectedCouponIds(CouponItem? coupon) {
  final couponId = coupon?.couponId;
  if (couponId == null || couponId <= 0) return const <int>[];
  return [couponId];
}

// 日期字段为空时展示空字符串，避免补充不真实的默认文案。
String _dateText(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty
      ? AppStrings.loanOrderEmptyValue
      : text.formatBackendDate();
}

Map<String, String> _loanAgreementQueryParamsFromConfirm({
  required LoanConfirmData data,
  UseCouponRespData? couponPreview,
  UserInfoResp? userInfo,
}) {
  final orders = data.list ?? const <LoanConfirmOrder>[];
  final loanAmount = couponPreview?.newLoanAmount ?? data.loanAmount ?? 0;
  final amountCredited =
      couponPreview?.actualToAccountMoney ?? data.actualToAccountMoney ?? 0;

  num? repayTotal = _previewRepayTotal(
    orders: orders,
    preview: couponPreview,
  );

  final middleName = userInfo?.middleName?.trim();
  final customerName = userInfo?.customerName?.trim();
  final userName = userInfo?.userName?.trim();
  final name = middleName != null && middleName.isNotEmpty
      ? middleName
      : customerName != null && customerName.isNotEmpty
      ? customerName
      : userName ?? '';

  final params = <String, String>{
    'loanAmount': loanAmount.toPlainAmountString(),
    'singleRepaymentAmount':
        repayTotal != null ? repayTotal.toPlainAmountString() : '',
    'amountCredited': amountCredited.toPlainAmountString(),
    'dueDate': _dateText(data.repayDate),
    'name': name,
    'idCardNumber': userInfo?.idCardNumber?.trim() ?? '',
    'receivingBankCardNumber': data.bankCardNo?.trim() ?? '',
    'loanMobilePhoneNumber': userInfo?.phone?.toString().trim() ?? '',
  };
  params.removeWhere((_, value) => value.isEmpty);
  return params;
}

// 字符串清理工具：处理接口返回 null、空串或全空格的情况。
String _emptyWhenNull(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? AppStrings.loanOrderEmptyValue : text;
}

// 银行卡号脱敏：超过 8 位时仅展示前四位和后四位，保护用户账户信息。
String _maskAccountNo(String value) {
  if (value.length <= 8) return value;

  return '${value.substring(0, 4)}****${value.substring(value.length - 4)}';
}

// 优惠券接口参数：只传有效订单 ID，避免把 0 或空值误认为真实订单。
List<int> _couponAppOrderIds(List<LoanConfirmOrder> orders) {
  return orders
      .map((item) => item.appOrderId)
      .whereType<int>()
      .where((id) => id > 0)
      .toList();
}

// 优惠券接口参数：按当前确认页产品去重，匹配后端筛券维度。
List<String> _couponProductCodes(List<LoanConfirmOrder> orders) {
  return orders
      .map((item) => item.productCode?.trim())
      .whereType<String>()
      .where((code) => code.isNotEmpty)
      .toSet()
      .toList();
}
