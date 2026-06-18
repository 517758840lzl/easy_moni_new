import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/material.dart';

/// 还款头部总金额展示组件，统一处理币种前缀、金额格式化和溢出展示。
class TotalRepayAmountDisplay extends StatelessWidget {
  const TotalRepayAmountDisplay({
    super.key,
    required this.amount,
    this.currencyStyle = _defaultCurrencyStyle,
    this.amountStyle = _defaultAmountStyle,
    this.textAlign = TextAlign.center,
  });

  final num amount;
  final TextStyle currencyStyle;
  final TextStyle amountStyle;
  final TextAlign textAlign;

  static const TextStyle _defaultCurrencyStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 36 / 26,
  );

  static const TextStyle _defaultAmountStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 38 / 32,
  );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: AppStrings.orderDetailCurrencyCode,
            style: currencyStyle,
          ),
          TextSpan(
            text: amount.formatAmount(showCurrencySymbol: false),
            style: amountStyle,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
