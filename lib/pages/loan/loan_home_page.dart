import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_product_card.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/pages/loan/providers/home_provider.dart';
import 'package:easy_moni/entities/home_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:easy_moni/utils/loan_order_status_visual.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

class LoanHomePage extends StatelessWidget {
  const LoanHomePage({super.key, this.refreshRequestId = ''});

  final String refreshRequestId;

  @override
  Widget build(BuildContext context) {
    return LoanHomeScaffold(refreshRequestId: refreshRequestId);
  }
}

// 借款首页通用容器
class LoanHomeScaffold extends ConsumerStatefulWidget {
  const LoanHomeScaffold({
    super.key,
    this.bottomContent,
    this.refreshRequestId = '',
    this.showAvailableProductCount = true,
  });

  final Widget? bottomContent;
  final String refreshRequestId;
  final bool showAvailableProductCount;

  @override
  ConsumerState<LoanHomeScaffold> createState() => _LoanHomeScaffoldState();
}

class _LoanHomeScaffoldState extends ConsumerState<LoanHomeScaffold> {
  final Set<int> _selectedProductIndexes = {};
  bool _isLoading = true;
  bool _isApplyButtonLocked = false;
  String? _loadError;

  List<_LoanProduct> _products = [];
  bool _hasAvailableCoupons = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void didUpdateWidget(covariant LoanHomeScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshRequestId.isEmpty ||
        widget.refreshRequestId == oldWidget.refreshRequestId) {
      return;
    }

    // 还款完成回到首页时，页面状态可能被 IndexedStack 复用，需要按路由刷新信号重新拉取数据。
    _refreshHomeData();
  }

  Future<void> _loadHomeData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final result = await ref.read(homeProvider).call();
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        _applyHomeData(result.data!);
      } else {
        _handleHomeLoadFailed(
          result.message ?? AppStrings.errorMessage,
          showErrorPage: showLoading,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _handleHomeLoadFailed(
        AppStrings.errorMessage,
        showErrorPage: showLoading,
      );
    }
  }

  // 首页下拉刷新：复用首屏接口请求，刷新过程中保留当前页面内容。
  Future<void> _refreshHomeData() {
    return _loadHomeData(showLoading: false);
  }

  void _handleHomeLoadFailed(String message, {required bool showErrorPage}) {
    if (!mounted) return;

    if (showErrorPage || _products.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = message;
      });
      return;
    }

    AppLogger.debug('首页刷新失败: $message');
  }

  void _applyHomeData(HomeResp data) {
    final items = data.confirmData?.list ?? [];
    final products = items
        .asMap()
        .entries
        .map((e) => _LoanProduct.fromApi(e.value, e.key))
        .toList();

    final availableCount = products.where((p) => p.state.canConfirm).length;
    final defaultSelectedIndexes = products
        .asMap()
        .entries
        .where((entry) => entry.value.state.canConfirm)
        .map((entry) => entry.key)
        .toSet();

    setState(() {
      _products = products;
      _hasAvailableCoupons = data.hasAvailableCoupons ?? false;
      _isLoading = false;
      _loadError = null;
      _selectedProductIndexes
        ..clear()
        ..addAll(defaultSelectedIndexes);
    });

    AppLogger.debug('首页加载成功: ${products.length} 个产品，可借 $availableCount 个');
  }

  int get _availableProductCount =>
      _products.where((p) => p.state.canConfirm).length;

  bool get _canSelectMultipleProducts {
    return _products
            .where((p) => !p.shouldUseOrderCard && p.state.canConfirm)
            .length >
        1;
  }

  // 首页展示优先级：可借款产品卡片置顶，其余卡片继续保持后端返回顺序。
  List<int> get _orderedHomeIndexes {
    final availableProductIndexes = <int>[];
    final remainingIndexes = <int>[];

    for (var index = 0; index < _products.length; index++) {
      final product = _products[index];
      if (!product.shouldUseOrderCard && product.state.canConfirm) {
        availableProductIndexes.add(index);
      } else {
        remainingIndexes.add(index);
      }
    }

    return [...availableProductIndexes, ...remainingIndexes];
  }

  double get _selectedLoanAmount {
    return _selectedProductIndexes.fold<double>(0, (total, index) {
      if (index < 0 || index >= _products.length) return total;
      final product = _products[index];
      if (!product.state.canConfirm) return total;
      return total + product.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: AppStateView(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: AppErrorStateView(
          text: _loadError!,
          onReload: () => _loadHomeData(),
        ),
      );
    }

    final selectedLoanAmount = _selectedLoanAmount;
    final canApply = selectedLoanAmount > 0 && !_isApplyButtonLocked;

    return Scaffold(
      backgroundColor: const Color(0xFF216A4A),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: _buildTopHero()),
            Positioned.fill(
              top: _contentPanelTop(context),
              child: _buildWhiteContentPanel(),
            ),
          ],
        ),
      ),
      // 底部固定按钮
      bottomNavigationBar: LoanBottomActionButton(
        text: AppStrings.homeButtonText,
        enabled: canApply,
        onPressed: canApply ? () => _handleApply(selectedLoanAmount) : null,
      ),
    );
  }

  double _contentPanelTop(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return topInset + 154;
  }

  // 跳转确认借款页面
  Future<void> _handleApply(double selectedLoanAmount) async {
    if (_isApplyButtonLocked) return;

    // 防止确认页跳转未完成前重复触发底部主按钮。
    setState(() {
      _isApplyButtonLocked = true;
    });

    final selectedConfirmProducts = _selectedProductIndexes
        .where((index) => index >= 0 && index < _products.length)
        .map((index) => _products[index].apiItem)
        .whereType<HomeProductItem>()
        .map((item) {
          return LoanConfirmRequestProduct(
            appOrderId: item.appOrderId ?? 0,
            feeId: '',
            loanAmount: item.productAccount ?? 0,
            productCode: item.productCode ?? '',
          );
        })
        .where((item) => item.productCode.isNotEmpty)
        .toList();

    try {
      await context.push(
        AppRoutePaths.loanConfirm,
        extra: {'products': selectedConfirmProducts},
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplyButtonLocked = false;
        });
      }
    }
  }

  Widget _buildWhiteContentPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildHomeScrollableContent(),
    );
  }

  Widget _buildHomeScrollableContent() {
    if (_products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshHomeData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(10, 17, 10, 92),
          children: [
            const _SelectionHint(canSelectMultiple: false),
            const SizedBox(height: 24),
            const AppEmptyStateView(text: AppStrings.noLoanProducts),
            if (widget.bottomContent != null) ...[
              const SizedBox(height: 16),
              widget.bottomContent!,
            ],
          ],
        ),
      );
    }

    final orderedHomeIndexes = _orderedHomeIndexes;

    return RefreshIndicator(
      onRefresh: _refreshHomeData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 17, 10, 92),
        itemCount:
            orderedHomeIndexes.length +
            1 +
            (widget.bottomContent == null ? 0 : 1),
        separatorBuilder: (context, index) {
          return SizedBox(height: index == 0 ? 12 : 16);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SelectionHint(
              canSelectMultiple: _canSelectMultipleProducts,
            );
          }
          if (index <= orderedHomeIndexes.length) {
            return _buildHomeListItem(orderedHomeIndexes[index - 1]);
          }
          return widget.bottomContent!;
        },
      ),
    );
  }

  Widget _buildHomeListItem(int index) {
    final product = _products[index];

    if (product.shouldUseOrderCard) {
      return _buildOrderCard(product);
    }

    return LoanProductCard(
      brand: product.brand,
      level: product.level,
      amountLabel: product.amountLabel,
      interestLabel: product.interestLabel.formatDailyInterestLabel(),
      termLabel: product.termLabel,
      state: product.state,
      logoUrl: product.logoUrl,
      isSelected: _selectedProductIndexes.contains(index),
      isConfirmed: _selectedProductIndexes.contains(index),
      onTap: () => _onProductTap(index),
      onToggleConfirmed: product.state.canConfirm
          ? () => _toggleProductSelection(index)
          : null,
    );
  }

  Widget _buildOrderCard(_LoanProduct product) {
    final item = product.apiItem;

    if (item == null) {
      return const SizedBox.shrink();
    }

    return LoanOrderCard(
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : AppStrings.loanOrderProductFallback,
      productLogo: item.productLogo,
      rows: _homeOrderRows(item),
      statusBadge: _homeOrderStatusBadge(item),
      footer: _homeOrderFooter(item, _hasAvailableCoupons),
      onFooterTap: _homeOrderFooterTap(context, item),
      onTap: () => context.push(
        AppRoutePaths.loanOrderDetail,
        extra: LoanOrderDetailData.fromHomeProductItem(item),
      ),
    );
  }

  void _onProductTap(int index) {
    _toggleProductSelection(index);
  }

  void _toggleProductSelection(int index) {
    if (index < 0 || index >= _products.length) return;
    if (!_products[index].state.canConfirm) return;

    setState(() {
      if (_selectedProductIndexes.contains(index)) {
        _selectedProductIndexes.remove(index);
      } else {
        _selectedProductIndexes.add(index);
      }
    });
  }

  Widget _buildTopHero() {
    final selectedLoanAmount = _selectedLoanAmount;
    final topInset = MediaQuery.of(context).padding.top;
    final heroHeight = topInset + 172 < 216 ? 216.0 : topInset + 172;

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.loginBg.provider(),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: topInset + 13,
              left: 56,
              right: 56,
              child: const Text(
                AppStrings.homeHeaderTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 20 / 16,
                ),
              ),
            ),
            Positioned(
              top: topInset + 11,
              right: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(AppRoutePaths.customerService),
                child: Assets.images.customer.image(width: 32, height: 32),
              ),
            ),
            Positioned(
              top: topInset + 63,
              left: 20,
              right: 20,
              child: TotalRepayAmountDisplay(amount: selectedLoanAmount),
            ),
            // 审核首页复用普通首页时，需要隐藏顶部可借产品数量提示。
            if (widget.showAvailableProductCount)
              Positioned(
                top: topInset + 107,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.images.loanCheck.image(
                          width: 22.5,
                          height: 22.5,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${AppStrings.homeAvailableString} $_availableProductCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionHint extends StatelessWidget {
  const _SelectionHint({required this.canSelectMultiple});

  final bool canSelectMultiple;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          AppStrings.selectProucts,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.41,
          ),
        ),
        if (canSelectMultiple) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F6EF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              AppStrings.homeMultiSelectHint,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF216A4A),
                height: 14 / 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

VoidCallback? _homeOrderFooterTap(BuildContext context, HomeProductItem item) {
  if (item.appOrderStatus != 4) return null;

  final appOrderId = _resolveHomeAppOrderId(item);
  if (appOrderId.isEmpty) return null;

  return () =>
      context.push(AppRoutePaths.repayOrderDetailWithIds([appOrderId]));
}

// 首页订单卡片字段：页面负责把接口数据转换成展示文案。
List<LoanOrderCardRowData> _homeOrderRows(HomeProductItem item) {
  final dueDate = _resolveHomeDueDate(item);

  final baseRows = <LoanOrderCardRowData>[
    LoanOrderCardRowData(
      label: AppStrings.loanOrderLoanAmountLabel,
      value: _amountText(item.loanAmount),
    ),
  ];

  // 首页订单摘要按订单状态展示不同的金额与还款字段。
  if (item.appOrderStatus == 4 &&
      item.remainingDays != null &&
      item.remainingDays! < 0) {
    return [
      ...baseRows,
      LoanOrderCardRowData(
        label: AppStrings.loanOrderRepayAmountLabel,
        value: _amountText(item.repayAmount),
      ),
      LoanOrderCardRowData(
        label: AppStrings.loanOrderOverdueDaysLabel,
        value: _daysText(item.remainingDays!.abs()),
      ),
      LoanOrderCardRowData(
        label: AppStrings.loanOrderOverdueFeeLabel,
        // 逾期费overdueInterest
        value: _amountText(item.overdueInterest),
      ),
    ];
  }

  if (item.appOrderStatus == 4) {
    return [
      ...baseRows,
      LoanOrderCardRowData(
        label: AppStrings.loanOrderRepayAmountLabel,
        value: _amountText(item.repayAmount),
      ),
      LoanOrderCardRowData(
        label: AppStrings.loanOrderDueDateLabel,
        value: dueDate,
      ),
    ];
  }

  return [
    ...baseRows,
    LoanOrderCardRowData(
      label: AppStrings.loanOrderReceiptAmountLabel,
      value: _amountText(item.receiptAmount),
    ),
    LoanOrderCardRowData(
      label: AppStrings.loanOrderDueDateLabel,
      value: dueDate,
    ),
  ];
}

String _resolveHomeAppOrderId(HomeProductItem item) {
  final appOrderIdStr = item.appOrderIdStr?.trim();
  if (appOrderIdStr != null && appOrderIdStr.isNotEmpty) {
    return appOrderIdStr;
  }
  return item.appOrderId?.toString() ?? '';
}

// 放款中/待还款等后端不下发 dueDate，可以展示 repayDateStr。
String _resolveHomeDueDate(HomeProductItem item) {
  final date = item.dueDate ?? item.repayDateStr;
  return date?.formatBackendDate() ?? AppStrings.loanOrderEmptyValue;
}

LoanOrderCardStatusBadgeData _homeOrderStatusBadge(HomeProductItem item) {
  final visual = LoanOrderStatusVisual.forStatus(
    item.appOrderStatus,
    remainingDays: item.remainingDays,
  );
  return LoanOrderCardStatusBadgeData(
    text: visual.label,
    gradient: visual.gradient,
  );
}

LoanOrderCardFooterData _homeOrderFooter(
  HomeProductItem item,
  bool hasAvailableCoupons,
) {
  final visual = LoanOrderStatusVisual.forStatus(
    item.appOrderStatus,
    remainingDays: item.remainingDays,
  );

  // 等待还款订单根据首页优惠券字段切换还款入口文案。
  if (item.appOrderStatus == 4 &&
      visual.label == AppStrings.loanOrderStatusWaitingRepayment) {
    return LoanOrderCardFooterData(
      text: hasAvailableCoupons
          ? AppStrings.loanOrderFooterCouponRepayment
          : AppStrings.loanOrderFooterImmediateRepayment,
      showCouponIcon: hasAvailableCoupons,
    );
  }

  return LoanOrderCardFooterData(text: visual.footerText);
}

String _amountText(num? value) {
  return (value ?? 0).formatAmount(showCurrencySymbol: true);
}

String _daysText(int days) {
  return '$days ${AppStrings.loanOrderDaysUnit}';
}

class _LoanProduct {
  final HomeProductItem? apiItem;
  final String brand;
  final String level;
  final double amount;
  final String amountLabel;
  final String interestLabel;
  final String termLabel;
  final LoanProductCardState state;
  final String? logoUrl;

  const _LoanProduct({
    this.apiItem,
    required this.brand,
    required this.level,
    required this.amount,
    required this.amountLabel,
    required this.interestLabel,
    required this.termLabel,
    required this.state,
    this.logoUrl,
  });

  factory _LoanProduct.fromApi(HomeProductItem item, int index) {
    final state = _stateFromItem(item);
    return _LoanProduct(
      apiItem: item,
      brand: item.productName?.isNotEmpty == true ? item.productName! : '',
      level: 'Lv.${item.productLevel ?? 1}',
      amount: item.availableAmount,
      amountLabel: item.availableAmountLabel,
      interestLabel: item.interestLabel,
      termLabel: item.termLabel,
      state: state,
      logoUrl: item.productLogo,
    );
  }

  static LoanProductCardState _stateFromItem(HomeProductItem item) {
    switch (item.productStatus) {
      case 0:
        return LoanProductCardState.available;
      case 3:
        return LoanProductCardState.unavailable;
      case 4:
        return LoanProductCardState.rejected;
      default:
        return LoanProductCardState.unavailable;
    }
  }

  bool get shouldUseOrderCard {
    final item = apiItem;
    if (item == null) return false;
    return item.appOrderStatus != null;
  }
}
