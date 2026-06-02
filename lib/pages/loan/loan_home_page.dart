import 'package:easy_moni/pages/loan/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../entities/home_resp.dart';
import '../../gen/assets.gen.dart';
import '../../utils/extensions.dart';

class LoanProductState {
  static const String available = 'available';
  static const String locked = 'locked';
  static const String rejected = 'rejected';
}

class LoanHomePage extends ConsumerStatefulWidget {
  const LoanHomePage({super.key});

  @override
  ConsumerState<LoanHomePage> createState() => _LoanHomePageState();
}

class _LoanHomePageState extends ConsumerState<LoanHomePage> {
  int? _selectedProductIndex;
  bool _hasConfirmedAvailableProduct = false;
  bool _isLoading = true;
  String? _loadError;

  List<_LoanProduct> _products = [];
  double _maxLoanAmount = 0;
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

    final amounts = products.map((p) => p.amount).where((a) => a > 0);
    final confirmAmount = data.confirmData?.loanAmount ?? 0;
    final maxAmount = amounts.isEmpty
        ? confirmAmount
        : [
            ...amounts,
            if (confirmAmount > 0) confirmAmount,
          ].reduce((a, b) => a > b ? a : b);

    final availableCount =
        products.where((p) => p.state == LoanProductState.available).length;

    setState(() {
      _products = products;
      _maxLoanAmount = maxAmount;
      _couponsTitle = data.couponsTitle;
      _hasAvailableCoupons = data.hasAvailableCoupons ?? false;
      _isLoading = false;
      _loadError = null;
      if (products.isEmpty) {
        _selectedProductIndex = null;
      } else {
        final availableIndex = products.indexWhere(
          (p) => p.state == LoanProductState.available,
        );
        _selectedProductIndex = availableIndex >= 0 ? availableIndex : 0;
      }
      _hasConfirmedAvailableProduct = false;
    });

    debugPrint('首页加载成功: ${products.length} 个产品, 可借 $availableCount 个');
  }

  int get _availableProductCount =>
      _products.where((p) => p.state == LoanProductState.available).length;

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

    final selectedProduct = _selectedProductIndex != null &&
            _selectedProductIndex! < _products.length
        ? _products[_selectedProductIndex!]
        : null;
    final canApply =
        selectedProduct?.state == LoanProductState.available &&
        _hasConfirmedAvailableProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopHero(),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: _products.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无可借产品',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF909399),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 108),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '请选择你想借的产品：',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101314),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...List.generate(
                                  _products.length,
                                  (index) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == _products.length - 1
                                          ? 0
                                          : 12,
                                    ),
                                    child: _buildProductCard(
                                      product: _products[index],
                                      isSelected:
                                          _selectedProductIndex == index,
                                      isConfirmed:
                                          _selectedProductIndex == index &&
                                          _hasConfirmedAvailableProduct,
                                      onTap: () => _onProductTap(index),
                                      onToggleAvailable:
                                          _products[index].state ==
                                              LoanProductState.available
                                          ? () {
                                              setState(() {
                                                _selectedProductIndex = index;
                                                _hasConfirmedAvailableProduct =
                                                    !_hasConfirmedAvailableProduct;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 18,
            child: GestureDetector(
              onTap: canApply
                  ? () => context.push(
                      '/payment',
                      extra: {
                        'amount': selectedProduct?.amount ?? 0,
                        'phone': '2335*****1247',
                        'idNumber': 'MoMo Account',
                      },
                    )
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                decoration: BoxDecoration(
                  color: canApply
                      ? const Color(0xFF2E8F75)
                      : const Color(0xFFC2C9CE),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: canApply
                      ? const [
                          BoxShadow(
                            color: Color(0x332E8F75),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                ),
                child: const Center(
                  child: Text(
                    '我要借款',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onProductTap(int index) {
    setState(() {
      _selectedProductIndex = index;
      if (_products[index].state != LoanProductState.available) {
        _hasConfirmedAvailableProduct = false;
      }
    });

    final product = _products[index];
    if (product.state == LoanProductState.locked) {
      context.push('/payment', extra: {'amount': product.amount});
    } else if (product.state == LoanProductState.rejected) {
      context.push('/payment');
    } else if (product.state == LoanProductState.available) {
      context.push('/payment', extra: {'amount': product.amount});
      setState(() => _hasConfirmedAvailableProduct = true);
    }
  }

  Widget _buildTopHero() {
    final amountText = _maxLoanAmount > 0
        ? 'GHS${_maxLoanAmount.formatAmount()}'
        : 'GHS0.00';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 32,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.inforamtionBgheader.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Assets.images.customer.image(width: 28, height: 28),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '最高可借额度',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            amountText,
            style: const TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.loanCheck.image(width: 14, height: 14),
                const SizedBox(width: 8),
                Text(
                  '可借产品：$_availableProductCount个',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_hasAvailableCoupons &&
              (_couponsTitle?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            Text(
              _couponsTitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required _LoanProduct product,
    required bool isSelected,
    required bool isConfirmed,
    required VoidCallback onTap,
    VoidCallback? onToggleAvailable,
  }) {
    final isAvailable = product.state == LoanProductState.available;
    final isLocked = product.state == LoanProductState.locked;
    final headerGradient = isAvailable
        ? const [Color(0xFF329977), Color(0xFF77D0B0)]
        : isLocked
        ? const [Color(0xFFB9B9BC), Color(0xFFD5D8DD)]
        : const [Color(0xFFC7C7C7), Color(0xFFE2E3E7)];

    final borderColor = isAvailable
        ? const Color(0xFFCDEEE3)
        : isSelected
        ? const Color(0xFFE0E3E7)
        : const Color(0xFFE7EAEE);

    final String statusText;
    switch (product.state) {
      case LoanProductState.available:
        statusText = '可借款';
        break;
      case LoanProductState.locked:
        statusText = '不可借';
        break;
      default:
        statusText = '拒绝';
    }

    const labels = ['可借金额', '日利率', '期限'];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected && isAvailable
                ? const Color(0xFF34B287)
                : borderColor,
            width: isSelected && isAvailable ? 2 : 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F1418),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: LinearGradient(colors: headerGradient),
              ),
              child: Row(
                children: [
                  _buildProductLogo(product),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF1FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.level,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7A85A8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isAvailable)
                    GestureDetector(
                      onTap: onToggleAvailable,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConfirmed
                              ? const Color(0xFF58E0AE)
                              : Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1.4,
                          ),
                        ),
                        child: isConfirmed
                            ? const Icon(
                                Icons.check,
                                size: 11,
                                color: Color(0xFF177558),
                              )
                            : const SizedBox.shrink(),
                      ),
                    )
                  else
                    Icon(
                      isLocked
                          ? Icons.lock_outline_rounded
                          : Icons.block_outlined,
                      size: 16,
                      color: const Color(0xFF45537A),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isAvailable
                      ? const Color(0xFFCAEBDD)
                      : const Color(0xFFE6E8EC),
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    labels[0],
                    'GHS ${product.amount.formatAmount()}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(labels[1], product.interestLabel),
                  const SizedBox(height: 12),
                  _buildInfoRow(labels[2], product.termLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLogo(_LoanProduct product) {
    final logoUrl = product.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logoUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildProductLogoFallback(product),
        ),
      );
    }
    return _buildProductLogoFallback(product);
  }

  Widget _buildProductLogoFallback(_LoanProduct product) {
    final initial = product.brand.isNotEmpty ? product.brand.characters.first : '?';
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: product.accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF22292F),
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111519),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _LoanProduct {
  final HomeProductItem? apiItem;
  final String brand;
  final String level;
  final double amount;
  final String interestLabel;
  final String termLabel;
  final String state;
  final Color accentColor;
  final String? logoUrl;

  const _LoanProduct({
    this.apiItem,
    required this.brand,
    required this.level,
    required this.amount,
    required this.interestLabel,
    required this.termLabel,
    required this.state,
    required this.accentColor,
    this.logoUrl,
  });

  factory _LoanProduct.fromApi(HomeProductItem item, int index) {
    final state = _stateFromItem(item);
    return _LoanProduct(
      apiItem: item,
      brand: item.productName?.isNotEmpty == true
          ? item.productName!
          : '产品${index + 1}',
      level: 'Lv.${item.productLevel ?? 1}',
      amount: item.displayAmount,
      interestLabel: item.interestLabel,
      termLabel: item.termLabel,
      state: state,
      accentColor: _accentForState(state),
      logoUrl: item.productLogo,
    );
  }

  static String _stateFromItem(HomeProductItem item) {
    switch (item.productStatus) {
      case 1:
        return LoanProductState.available;
      case 3:
        return LoanProductState.rejected;
      default:
        return LoanProductState.locked;
    }
  }

  static Color _accentForState(String state) {
    switch (state) {
      case LoanProductState.available:
        return const Color(0xFF2E9A79);
      case LoanProductState.locked:
        return const Color(0xFFC8CDD2);
      default:
        return const Color(0xFFD9D9D9);
    }
  }
}
