import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/pages/loan/components/loan_order_card.dart';
import 'package:easy_moni/pages/loan/components/loan_product_card.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';
import 'package:easy_moni/pages/loan/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../entities/home_resp.dart';
import '../../gen/assets.gen.dart';
import '../../utils/extensions.dart';
import '../../utils/widgets/loan_bottom_action_button.dart';

class LoanHomePage extends ConsumerStatefulWidget {
  const LoanHomePage({super.key});

  @override
  ConsumerState<LoanHomePage> createState() => _LoanHomePageState();
}

class _LoanHomePageState extends ConsumerState<LoanHomePage> {
  final Set<int> _selectedProductIndexes = {};
  bool _isLoading = true;
  String? _loadError;

  List<_LoanProduct> _products = [];
  String? _couponsTitle;
  bool _hasAvailableCoupons = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final result = await ref.read(homeProvider).call();
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        _applyHomeData(result.data!);
      } else {
        setState(() {
          _isLoading = false;
          _loadError = result.message ?? '加载失败，请重试';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = '加载失败，请重试';
      });
    }
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
      _couponsTitle = data.couponsTitle;
      _hasAvailableCoupons = data.hasAvailableCoupons ?? false;
      _isLoading = false;
      _loadError = null;
      _selectedProductIndexes
        ..clear()
        ..addAll(defaultSelectedIndexes);
    });

    debugPrint('首页加载成功: ${products.length} 个产品，可借 $availableCount 个');
  }

  int get _availableProductCount =>
      _products.where((p) => p.state.canConfirm).length;

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextButton(onPressed: _loadHomeData, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    final selectedLoanAmount = _selectedLoanAmount;
    final canApply = selectedLoanAmount > 0;
    final productItems = _products
        .where((p) => p.apiItem?.appOrderStatus == null)
        .toList();
    final orderItems = _products
        .where((p) => p.apiItem?.appOrderStatus != null)
        .toList();
    final hasOrders = orderItems.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF216A4A),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: _buildTopHero()),
            Positioned.fill(
              top: _contentPanelTop(context),
              child: _buildWhiteContentPanel(
                hasOrders: hasOrders,
                productItems: productItems,
                orderItems: orderItems,
                canApply: canApply,
                onApply: () => _handleApply(selectedLoanAmount),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasOrders
          ? null
          : LoanBottomActionButton(
              enabled: canApply,
              onPressed: canApply
                  ? () => _handleApply(selectedLoanAmount)
                  : null,
            ),
    );
  }

  double _contentPanelTop(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return topInset + 154;
  }

  // 跳转确认借款页面
  void _handleApply(double selectedLoanAmount) {
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

    context.push('/loan-confirm', extra: {'products': selectedConfirmProducts});
  }

  Widget _buildWhiteContentPanel({
    required bool hasOrders,
    required List<_LoanProduct> productItems,
    required List<_LoanProduct> orderItems,
    required bool canApply,
    required VoidCallback onApply,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasOrders
          ? _buildOrdersScrollableContent(
              productItems: productItems,
              orderItems: orderItems,
              canApply: canApply,
              onApply: onApply,
            )
          : _buildProductOnlyContent(productItems),
    );
  }

  Widget _buildProductOnlyContent(List<_LoanProduct> productItems) {
    if (productItems.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.noLoanProducts,
          style: TextStyle(fontSize: 14, color: Color(0xFF909399)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 17, 10, 92),
      child: _buildProductSection(productItems),
    );
  }

  Widget _buildOrdersScrollableContent({
    required List<_LoanProduct> productItems,
    required List<_LoanProduct> orderItems,
    required bool canApply,
    required VoidCallback onApply,
  }) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 17, 10, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (productItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      AppStrings.noLoanProducts,
                      style: TextStyle(fontSize: 14, color: Color(0xFF909399)),
                    ),
                  ),
                )
              else
                _buildProductSection(productItems),
              const SizedBox(height: 16),
              LoanBottomActionButton(
                enabled: canApply,
                onPressed: canApply ? onApply : null,
                mode: LoanBottomActionButtonMode.inline,
              ),
              const SizedBox(height: 20),
              _buildMyLoansSection(orderItems),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ),
      ],
    );
  }

  Widget _buildProductSection(List<_LoanProduct> productItems) {
    final canSelectMultiple =
        productItems.where((p) => p.state.canConfirm).length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 可选提示
        Row(
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
                  '可多选',
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
        ),
        const SizedBox(height: 12),
        // 产品列表
        ...List.generate(productItems.length, (index) {
          final product = productItems[index];
          final productIndex = _products.indexOf(product);

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == productItems.length - 1 ? 0 : 16,
            ),
            child: LoanProductCard(
              brand: product.brand,
              level: product.level,
              amountLabel: product.amountLabel,
              interestLabel: '${product.interestLabel} per day',
              termLabel: product.termLabel,
              state: product.state,
              logoUrl: product.logoUrl,
              isSelected: _selectedProductIndexes.contains(productIndex),
              isConfirmed: _selectedProductIndexes.contains(productIndex),
              onTap: () => _onProductTap(productIndex),
              onToggleConfirmed: product.state.canConfirm
                  ? () => _toggleProductSelection(productIndex)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMyLoansSection(List<_LoanProduct> orderItems) {
    if (orderItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '我的借款',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.41,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(orderItems.length, (index) {
          final item = orderItems[index].apiItem;

          if (item == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == orderItems.length - 1 ? 0 : 16,
            ),
            child: LoanOrderCard.fromHomeProductItem(item),
          );
        }),
      ],
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
    final amountText = selectedLoanAmount > 0
        ? selectedLoanAmount.formatAmount()
        : '0.00';
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
                '最高可借额度',
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
              right: 21,
              child: Assets.images.customer.image(width: 32, height: 32),
            ),
            Positioned(
              top: topInset + 63,
              left: 20,
              right: 20,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'GHS',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: amountText),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
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
                      Assets.images.loanCheck.image(width: 22.5, height: 22.5),
                      const SizedBox(width: 10),
                      Text(
                        '可借产品：$_availableProductCount个',
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
            if (_hasAvailableCoupons && (_couponsTitle?.isNotEmpty ?? false))
              Positioned(
                top: topInset + 148,
                left: 20,
                right: 20,
                child: Text(
                  _couponsTitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
      brand: item.productName?.isNotEmpty == true
          ? item.productName!
          : 'product${index + 1}',
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
