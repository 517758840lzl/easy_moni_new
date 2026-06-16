import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/home_resp.dart';
import 'package:easy_moni/entities/loan_confirm/loan_confirm_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/models/loan_order_card_config.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

export 'package:easy_moni/pages/loan/models/loan_order_card_config.dart'
    show LoanOrderCardMode;

class LoanOrderCard extends StatelessWidget {
  const LoanOrderCard({
    super.key,
    required this.productName,
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    required this.dueDate,
    this.productLogo,
    this.statusText,
    this.statusCode,
    this.totalServiceDays,
    this.remainingDays,
    this.serviceFee,
    this.interest,
    this.mode = LoanOrderCardMode.repaymentStatus,
    this.footerText,
    this.hasAvailableCoupons = false,
    this.onTap,
  });

  factory LoanOrderCard.fromHomeProductItem(
    HomeProductItem item, {
    Key? key,
    bool hasAvailableCoupons = false,
    VoidCallback? onTap,
  }) {
    final dueDate = _resolveHomeDueDate(item);

    return LoanOrderCard(
      key: key,
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : AppStrings.loanOrderProductFallback,
      productLogo: item.productLogo,
      loanAmount: item.loanAmount ?? 0,
      receiptAmount: item.receiptAmount ?? 0,
      repayAmount: item.repayAmount ?? 0,
      dueDate: dueDate,
      statusCode: item.appOrderStatus,
      totalServiceDays: item.totalServiceDays,
      remainingDays: item.remainingDays,
      hasAvailableCoupons: hasAvailableCoupons,
      onTap: onTap,
    );
  }

  factory LoanOrderCard.confirmFromLoanConfirmOrder(
    LoanConfirmOrder item, {
    Key? key,
    VoidCallback? onTap,
  }) {
    final dueDate =
        item.dueDate?.formatBackendDate() ?? AppStrings.loanOrderEmptyValue;

    return LoanOrderCard(
      key: key,
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : AppStrings.loanOrderProductFallback,
      productLogo: item.productLogo,
      loanAmount: item.loanAmount ?? 0,
      receiptAmount: item.actualToAccount ?? item.receiptAmount ?? 0,
      repayAmount: item.repayAmount ?? 0,
      dueDate: dueDate,
      totalServiceDays: item.totalServiceDays,
      serviceFee: item.serviceFee ?? 0,
      interest: item.interest ?? 0,
      mode: LoanOrderCardMode.loanConfirm,
      onTap: onTap,
    );
  }

  final String productName;
  final String? productLogo;
  final num loanAmount;
  final num receiptAmount;
  final num repayAmount;
  final String? dueDate;
  final String? statusText;
  final int? statusCode;
  final int? totalServiceDays;
  final int? remainingDays;
  final num? serviceFee;
  final num? interest;
  final LoanOrderCardMode mode;
  final String? footerText;
  final bool hasAvailableCoupons;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusVisual = _LoanOrderStatusVisual.forStatus(
      statusCode,
      remainingDays: remainingDays,
    );
    final effectiveStatusText = statusText ?? statusVisual.label;
    final footerVisual = _LoanOrderFooterVisual.resolve(
      statusCode: statusCode,
      statusLabel: statusVisual.label,
      statusFooterText: statusVisual.footerText,
      hasAvailableCoupons: hasAvailableCoupons,
      footerText: footerText,
    );
    final config = LoanOrderCardConfig.forMode(mode);
    final fieldData = LoanOrderCardFieldData(
      loanAmount: loanAmount,
      receiptAmount: receiptAmount,
      repayAmount: repayAmount,
      dueDate: dueDate,
      totalServiceDays: totalServiceDays,
      serviceFee: serviceFee,
      interest: interest,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: onTap == null
          ? HitTestBehavior.deferToChild
          : HitTestBehavior.opaque,
      child: SizedBox(
        height: config.height,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: config.height,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5EE),
                borderRadius: BorderRadius.circular(4.375),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderHeader(
                    productName: productName,
                    productLogo: productLogo,
                  ),
                  const SizedBox(height: 7),
                  ..._buildInfoRows(config.fields, fieldData),
                  if (config.showFooter) ...[
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0x1A000000),
                    ),
                    const SizedBox(height: 11),
                    _OrderFooterAction(
                      text: footerVisual.text,
                      showCouponIcon: footerVisual.showCouponIcon,
                    ),
                  ],
                ],
              ),
            ),
            if (config.showStatusBadge)
              Positioned(
                top: 13,
                right: 13,
                child: _OrderStatusBadge(
                  text: effectiveStatusText,
                  visual: statusVisual,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 放款中后端不下发 dueDate，需要优先展示 repayDateStr。
  static String _resolveHomeDueDate(HomeProductItem item) {
    final date = item.appOrderStatus == 3 ? item.repayDateStr : item.dueDate;
    return date?.formatBackendDate() ?? AppStrings.loanOrderEmptyValue;
  }

  /// 根据配置生成订单信息行，统一维护行间距。
  static List<Widget> _buildInfoRows(
    List<LoanOrderCardFieldConfig> fields,
    LoanOrderCardFieldData data,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      widgets.add(
        _OrderInfoRow(label: field.label, value: field.resolveValue(data)),
      );
      if (i < fields.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }
}

class _LoanOrderFooterVisual {
  const _LoanOrderFooterVisual({
    required this.text,
    required this.showCouponIcon,
  });

  final String text;
  final bool showCouponIcon;

  factory _LoanOrderFooterVisual.resolve({
    required int? statusCode,
    required String statusLabel,
    required String statusFooterText,
    required bool hasAvailableCoupons,
    String? footerText,
  }) {
    if (footerText != null) {
      return _LoanOrderFooterVisual(text: footerText, showCouponIcon: false);
    }

    // 等待还款订单根据首页优惠券字段切换还款入口文案。
    if (statusCode == 4 &&
        statusLabel == AppStrings.loanOrderStatusWaitingRepayment) {
      return _LoanOrderFooterVisual(
        text: hasAvailableCoupons
            ? AppStrings.loanOrderFooterCouponRepayment
            : AppStrings.loanOrderFooterImmediateRepayment,
        showCouponIcon: hasAvailableCoupons,
      );
    }

    return _LoanOrderFooterVisual(
      text: statusFooterText,
      showCouponIcon: false,
    );
  }
}

class _LoanOrderStatusVisual {
  const _LoanOrderStatusVisual({
    required this.label,
    required this.gradient,
    required this.footerText,
  });

  final String label;
  final List<Color> gradient;
  final String footerText;

  factory _LoanOrderStatusVisual.forStatus(
    int? statusCode, {
    int? remainingDays,
  }) {
    if (statusCode == 4 && remainingDays != null && remainingDays < 0) {
      return const _LoanOrderStatusVisual(
        label: AppStrings.loanOrderStatusOverdue,
        gradient: [Color(0xFFFF5265), Color(0xFFFF843F)],
        footerText: AppStrings.loanOrderFooterOverdue,
      );
    }

    switch (statusCode) {
      case 20:
        return const _LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusReviewing,
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: AppStrings.loanOrderFooterReviewing,
        );
      case 3:
        return const _LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusDisbursing,
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: AppStrings.loanOrderFooterDisbursing,
        );
      case 4:
        return const _LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusWaitingRepayment,
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: AppStrings.loanOrderFooterWaitingRepayment,
        );
      case 5:
        return const _LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusTransferFailed,
          gradient: [Color(0xFFC1C3C6), Color(0xFFC1C3C6)],
          footerText: AppStrings.loanOrderFooterTransferFailed,
        );
      default:
        return const _LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusReviewing,
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: AppStrings.loanOrderFooterReviewing,
        );
    }
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.productName, required this.productLogo});

  final String productName;
  final String? productLogo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrderLogo(productName: productName, productLogo: productLogo),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0E0E0E),
              height: 16 / 12,
            ),
          ),
        ),
        const SizedBox(width: 62),
      ],
    );
  }
}

class _OrderLogo extends StatelessWidget {
  const _OrderLogo({required this.productName, required this.productLogo});

  final String productName;
  final String? productLogo;

  @override
  Widget build(BuildContext context) {
    final logo = productLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logo,
          width: 21,
          height: 21,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final initial = productName.isNotEmpty
        ? productName.characters.first
        : AppStrings.loanOrderLogoFallback;

    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Color(0xFF216A4A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.text, required this.visual});

  final String text;
  final _LoanOrderStatusVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: visual.gradient,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 16 / 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF131313),
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderFooterAction extends StatelessWidget {
  const _OrderFooterAction({required this.text, required this.showCouponIcon});

  final String text;
  final bool showCouponIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showCouponIcon) ...[
          SvgPicture.asset(Assets.images.couponIcon, width: 14, height: 14),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF216A4A),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
