import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../entities/loan_confirm/loan_confirm_resp.dart';
import '../../gen/assets.gen.dart';
import '../../utils/extensions.dart';
import '../../utils/widgets/loan_bottom_action_button.dart';
import 'components/loan_order_card.dart';
import 'models/loan_confirm_request_product.dart';
import 'providers/loan_confirm_provider.dart';

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
  final bool _isSubmitting = false;
  String? _loadError;
  LoanConfirmResp? _loanConfirmResp;

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
          _loadError = confirmResult.message ?? '加载失败，请重试';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _loanConfirmResp = confirmResult.data;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = '加载失败，请重试';
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    // 先做页面测试，再测试逻辑
    context.go('/loan-reviewing');
    // final data = _confirmData;
    // final orders = data?.list ?? const <LoanConfirmOrder>[];
    // if (data == null || orders.isEmpty) {
    //   context.showSnackBar('暂无可确认借款', isError: true);
    //   return;
    // }
    //
    // setState(() {
    //   _isSubmitting = true;
    // });
    //
    // try {
    //   final result = await ref
    //       .read(loanConfirmProvider)
    //       .confirmOrder(confirmData: data);
    //   if (!mounted) return;
    //   if (result.isSuccess) {
    //     context.go('/loan-reviewing');
    //   } else {
    //     context.showSnackBar(result.message ?? '提交失败，请重试', isError: true);
    //   }
    // } catch (_) {
    //   if (!mounted) return;
    //   context.showSnackBar('提交失败，请重试', isError: true);
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isSubmitting = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final data = _confirmData;
    final orders = data?.list ?? const <LoanConfirmOrder>[];
    final hasData = data != null && orders.isNotEmpty;
    final topInset = MediaQuery.of(context).padding.top;
    final cardTop = topInset + 218;
    final contentTop = topInset + 278;

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
            Positioned(top: 0, left: 0, right: 0, child: _Hero(data: data)),
            if (hasData)
              // 收款账户卡片悬浮在顶部信息区和白色内容区之间。
              Positioned(
                top: cardTop,
                left: 14,
                right: 14,
                child: _MomoAccountCard(data: data),
              ),
            // 主内容区：包含异形白底、加载/错误/空态和订单列表。
            Positioned.fill(
              top: contentTop,
              child: _buildContent(data: data, orders: orders),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasData
          ? LoanBottomActionButton(
              enabled: !_isSubmitting,
              text: _isSubmitting ? '提交中...' : '确认借款',
              onPressed: _isSubmitting ? null : _submitOrder,
            )
          : null,
    );
  }

  Widget _buildContent({
    required LoanConfirmData? data,
    required List<LoanConfirmOrder> orders,
  }) {
    // 先画顶部曲线阴影，再用同样的路径裁剪白色内容区。
    return Stack(
      fit: StackFit.expand,
      children: [
        const _LoanConfirmContentEdge(),
        ClipPath(
          clipper: const _LoanConfirmContentClipper(),
          child: ColoredBox(
            color: Colors.white,
            child: _buildContentState(data: data, orders: orders),
          ),
        ),
      ],
    );
  }

  Widget _buildContentState({
    required LoanConfirmData? data,
    required List<LoanConfirmOrder> orders,
  }) {
    // 内容区只负责状态切换：加载、错误、空数据、正常列表。
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
            TextButton(onPressed: _loadData, child: const Text('重试')),
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
              '暂无可确认借款',
              style: TextStyle(fontSize: 14, color: Color(0xFF909399)),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => context.pop(), child: const Text('返回')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        10,
        34,
        10,
        88 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // 优惠券入口固定在订单列表最上方。
          const _CouponEntryCard(),
          const SizedBox(height: 14),
          ...List.generate(orders.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == orders.length - 1 ? 0 : 16,
              ),
              child: LoanOrderCard.confirmFromLoanConfirmOrder(orders[index]),
            );
          }),
        ],
      ),
    );
  }
}

// 裁剪白色内容区的顶部形状：两侧圆角，中间向下形成柔和弧线。
class _LoanConfirmContentClipper extends CustomClipper<Path> {
  const _LoanConfirmContentClipper();

  static const sideHeight = 16.0;
  static const centerHeight = 30.0;

  @override
  Path getClip(Size size) {
    // 这条路径只定义上边缘曲线，底部保持普通矩形填满剩余区域。
    return Path()
      ..moveTo(0, sideHeight)
      ..quadraticBezierTo(0, 0, sideHeight, 0)
      ..cubicTo(
        size.width * 0.28,
        centerHeight,
        size.width * 0.72,
        centerHeight,
        size.width - sideHeight,
        0,
      )
      ..quadraticBezierTo(size.width, 0, size.width, sideHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_LoanConfirmContentClipper oldClipper) => false;
}

// 内容区顶部的阴影层，和 ClipPath 使用同一条曲线保持视觉贴合。
class _LoanConfirmContentEdge extends StatelessWidget {
  const _LoanConfirmContentEdge();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LoanConfirmContentEdgePainter());
  }
}

// 沿内容区顶部曲线绘制一条模糊描边，增强白色区域和绿色背景的层次感。
class _LoanConfirmContentEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 曲线参数复用 clipper 常量，避免阴影和裁剪边缘错位。
    final curve = Path()
      ..moveTo(0, _LoanConfirmContentClipper.sideHeight)
      ..quadraticBezierTo(0, 0, _LoanConfirmContentClipper.sideHeight, 0)
      ..cubicTo(
        size.width * 0.28,
        _LoanConfirmContentClipper.centerHeight,
        size.width * 0.72,
        _LoanConfirmContentClipper.centerHeight,
        size.width - _LoanConfirmContentClipper.sideHeight,
        0,
      )
      ..quadraticBezierTo(
        size.width,
        0,
        size.width,
        _LoanConfirmContentClipper.sideHeight,
      );

    canvas.drawPath(
      // 略微上移，让模糊阴影主要露在白色内容区外侧。
      curve.shift(const Offset(0, -1)),
      Paint()
        ..color = const Color(0x663D250C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_LoanConfirmContentEdgePainter oldDelegate) => false;
}

// 页面头图区域：展示导航、客服入口、借款总额和三项关键确认信息。
class _Hero extends StatelessWidget {
  const _Hero({required this.data});

  final LoanConfirmData? data;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final orders = data?.list ?? const <LoanConfirmOrder>[];
    // 应还金额来自所有待确认订单的 repayAmount 汇总。
    final repayTotal = orders.fold<double>(0, (sum, item) {
      return sum + (item.repayAmount ?? 0).toDouble();
    });

    return SizedBox(
      height: topInset + 249,
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
            top: topInset + 17,
            left: 64,
            right: 64,
            child: const Text(
              '确认借款',
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
            child: Assets.images.customer.image(width: 32, height: 32),
          ),
          Positioned(
            top: topInset + 66,
            left: 20,
            right: 20,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'GHS ',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: (data?.loanAmount ?? 0).toDouble().formatAmount(),
                    ),
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
          ),
          Positioned(
            top: topInset + 132,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    icon: Assets.images.loanWallect.image(
                      width: 22,
                      height: 22,
                    ),
                    value: _amountText(data?.actualToAccountMoney),
                    label: '到账金额',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    icon: Assets.images.loanMoney.image(
                      width: 22,
                      height: 22,
                    ),
                    value: _amountText(repayTotal),
                    label: '应还金额',
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
                    label: '还款日期',
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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            value,
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
    );
  }
}

// MoMo 收款账户卡：展示实际放款到账的钱包/手机号信息。
class _MomoAccountCard extends StatelessWidget {
  const _MomoAccountCard({required this.data});

  final LoanConfirmData data;

  @override
  Widget build(BuildContext context) {
    // 接口字段为空时使用兜底文案，避免卡片出现空白。
    final accountName = _nonEmpty(data.bankCardName, fallback: 'Vodafone Cash');
    final accountNo = _nonEmpty(data.bankCardNo, fallback: '-');

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
      padding: const EdgeInsets.fromLTRB(4, 11, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SimIcon(),
          const SizedBox(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5C2B0B),
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
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  'MoMo收款账户',
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

// 优惠券入口卡片，目前作为列表顶部的固定入口展示。
class _CouponEntryCard extends StatelessWidget {
  const _CouponEntryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4.375),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Assets.images.loanGhs.image(width: 28, height: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text(
                      '优惠券',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131313),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  '提升额度或享受利息减免',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A8F98),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}

// 金额展示统一加 GHS 前缀，并按项目扩展方法格式化小数。
String _amountText(num? value) {
  return 'GHS ${(value ?? 0).toDouble().formatAmount()}';
}

// 日期字段为空时展示占位符，避免 UI 直接显示空字符串。
String _dateText(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? '-' : text;
}

// 字符串兜底工具：处理接口返回 null、空串或全空格的情况。
String _nonEmpty(String? value, {required String fallback}) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}
