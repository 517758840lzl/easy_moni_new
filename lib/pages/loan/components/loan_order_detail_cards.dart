import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/utils/extensions.dart';
import 'package:flutter/material.dart';

/// 订单详情内容卡片组，统一维护字段、间距和信息卡视觉。
class LoanOrderDetailCards extends StatelessWidget {
  const LoanOrderDetailCards({super.key, required this.data});

  final LoanOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    final orderRows = _resolveOrderRows(data);
    final accountRows = _resolveAccountRows(data);

    return Column(
      children: [
        _DetailInfoCard(
          icon: Assets.images.mineBillList.image(width: 30, height: 30),
          title: AppStrings.loanOrderDetailInfoTitle,
          rows: orderRows,
        ),
        if (accountRows.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailInfoCard(
            icon: Assets.images.mineWallet.image(width: 30, height: 30),
            title: AppStrings.loanOrderAccountInfoTitle,
            rows: accountRows,
          ),
        ],
      ],
    );
  }

  /// 不同订单状态展示不同信息，值为空的行直接隐藏，避免详情页出现占位文案。
  static List<_DetailRowData> _resolveOrderRows(LoanOrderDetailData data) {
    final visual = LoanOrderDetailStatusVisual.resolve(data);
    if (visual.kind == LoanOrderDetailStatusKind.overdue) {
      return _filterRows([
        _DetailRowData.amount(
          AppStrings.loanOrderLoanAmountLabel,
          data.loanAmount,
        ),
        _DetailRowData.amount(AppStrings.loanOrderInterestLabel, data.interest),
        _DetailRowData.amount(
          AppStrings.loanOrderOverdueFeeLabel,
          data.serviceFee,
        ),
        _DetailRowData.amount(
          AppStrings.loanOrderRepayAmountLabel,
          data.repayAmount,
        ),
        _DetailRowData.days(AppStrings.loanOrderLoanTermLabel, data.term),
        _DetailRowData.text(AppStrings.loanOrderDueDateLabel, data.dueDate),
        // 逾期状态下后端 remainingDays 为负数，展示时按逾期天数取绝对值。
        _DetailRowData.days(
          AppStrings.loanOrderOverdueDaysLabel,
          data.remainingDays?.abs(),
        ),
      ]);
    }

    if (data.statusCode == 4) {
      return _filterRows([
        _DetailRowData.amount(
          AppStrings.loanOrderLoanAmountLabel,
          data.loanAmount,
        ),
        _DetailRowData.amount(AppStrings.loanOrderInterestLabel, data.interest),
        _DetailRowData.amount(
          AppStrings.loanOrderRepayAmountLabel,
          data.repayAmount,
        ),
        _DetailRowData.days(AppStrings.loanOrderLoanTermLabel, data.term),
        _DetailRowData.text(AppStrings.loanOrderDueDateLabel, data.dueDate),
        _DetailRowData.days(
          AppStrings.loanOrderRepaymentRemainingDaysLabel,
          data.remainingDays,
        ),
      ]);
    }

    return _filterRows([
      _DetailRowData.amount(
        AppStrings.loanOrderLoanAmountLabel,
        data.loanAmount,
      ),
      _DetailRowData.amount(
        AppStrings.loanOrderReceiptAmountLabel,
        data.receiptAmount,
      ),
      _DetailRowData.amount(AppStrings.loanOrderInterestLabel, data.interest),
      _DetailRowData.amount(
        AppStrings.loanOrderRepayAmountLabel,
        data.repayAmount,
      ),
      _DetailRowData.days(AppStrings.loanOrderLoanTermLabel, data.term),
      _DetailRowData.text(AppStrings.loanOrderDueDateLabel, data.dueDate),
    ]);
  }

  static List<_DetailRowData> _resolveAccountRows(LoanOrderDetailData data) {
    return [
      _DetailRowData.text(
        AppStrings.loanOrderMomoAccountLabel,
        data.momoAccount,
      ),
      _DetailRowData.text(AppStrings.loanOrderWalletTypeLabel, data.walletType),
    ].where((row) => row.value.isNotEmpty).toList(growable: false);
  }

  static List<_DetailRowData> _filterRows(List<_DetailRowData> rows) {
    return rows.where((row) => row.value.isNotEmpty).toList(growable: false);
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final Widget icon;
  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4.375),
      ),
      child: Column(
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
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
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
              child: _DetailInfoRow(label: row.label, value: row.value),
            );
          }),
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0B0B0B),
              height: 16 / 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  const _DetailRowData({required this.label, required this.value});

  factory _DetailRowData.text(String label, String? value) {
    return _DetailRowData(
      label: label,
      value: value ?? AppStrings.loanOrderEmptyValue,
    );
  }

  factory _DetailRowData.amount(String label, num? value) {
    return _DetailRowData(
      label: label,
      value: value == null
          ? AppStrings.loanOrderEmptyValue
          : value.formatAmount(showCurrencySymbol: true),
    );
  }

  factory _DetailRowData.days(String label, int? value) {
    return _DetailRowData(
      label: label,
      value: value == null
          ? AppStrings.loanOrderEmptyValue
          : '$value ${AppStrings.loanOrderDaysUnit.capitalize}',
    );
  }

  final String label;
  final String value;
}
