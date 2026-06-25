import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/repay/components/repay_bill_card.dart';
import 'package:easy_moni/pages/repay/components/total_repay_amount_display.dart';
import 'package:easy_moni/pages/repay/providers/repay_list_provider.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 还款入口页，展示待还总额、待还账单列表和底部全部还款操作。
class RepayEntryPage extends ConsumerStatefulWidget {
  const RepayEntryPage({super.key});

  @override
  ConsumerState<RepayEntryPage> createState() => _RepayEntryPageState();
}

class _RepayEntryPageState extends ConsumerState<RepayEntryPage> {
  final Set<String> _selectedBillKeys = <String>{};
  String _billListSignature = '';

  double _totalAmount(List<RepayResp> bills) {
    return bills.fold<double>(0, (sum, bill) => sum + (bill.repayAmount ?? 0));
  }

  String _billKey(RepayResp bill, [int? index]) {
    final appOrderId = bill.appOrderId?.trim();
    if (appOrderId != null && appOrderId.isNotEmpty) return appOrderId;

    return Object.hash(
      index,
      bill.productSetCode,
      bill.createTime,
      bill.repayDateStr,
      bill.repayAmount,
    ).toString();
  }

  void _syncSelectedBills(List<RepayResp> bills) {
    final signature = List.generate(
      bills.length,
      (index) => _billKey(bills[index], index),
    ).join('|');

    if (signature == _billListSignature) return;

    _billListSignature = signature;
    _selectedBillKeys
      ..clear()
      ..addAll(
        List.generate(bills.length, (index) => _billKey(bills[index], index)),
      );
  }

  List<RepayResp> _selectedBills(List<RepayResp> bills) {
    return [
      for (var index = 0; index < bills.length; index++)
        if (_selectedBillKeys.contains(_billKey(bills[index], index)))
          bills[index],
    ];
  }

  void _toggleBill(RepayResp bill, int index) {
    final key = _billKey(bill, index);
    setState(() {
      if (_selectedBillKeys.contains(key)) {
        _selectedBillKeys.remove(key);
      } else {
        _selectedBillKeys.add(key);
      }
    });
  }

  /// 下拉刷新复用还款入口待还账单 Provider，确保重新发起首页数据请求。
  Future<void> _refreshBills() async {
    try {
      final refreshFuture = ref.refresh(repayEntryBillsProvider.future);
      await refreshFuture;
    } catch (_) {
      // 网络异常交给页面错误态展示，避免刷新 Future 抛错导致页面崩溃。
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final billsAsync = ref.watch(repayEntryBillsProvider);
    final bills = billsAsync.when(
      data: (items) => items,
      error: (_, _) => const <RepayResp>[],
      loading: () => const <RepayResp>[],
    );
    _syncSelectedBills(bills);

    final selectedBills = _selectedBills(bills);
    final showTotalAmount = bills.length > 1;
    final stateChild = billsAsync.when<Widget?>(
      data: (_) => null,
      error: (_, _) => AppErrorStateView(
        text: AppStrings.repayEntryLoadFailed,
        onReload: _refreshBills,
      ),
      loading: () => const CircularProgressIndicator(),
    );

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + (showTotalAmount ? 113 : 52),
      contentTopRadius: 16,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _RepayEntryHeader(
        totalAmount: _totalAmount(selectedBills),
        showTotalAmount: showTotalAmount,
      ),
      content: RefreshIndicator(
        onRefresh: _refreshBills,
        child: _RepayEntryContent(
          bills: bills,
          selectedBillKeys: _selectedBillKeys,
          billKeyBuilder: _billKey,
          stateChild: stateChild,
          onSelectionTap: _toggleBill,
          onRepayTap: (bill) => _openBillDetail(context, bill),
        ),
      ),
      // 待还订单只有一个不展示全部按钮
      bottomNavigationBar: bills.length > 1
          ? LoanBottomActionButton(
              enabled: selectedBills.isNotEmpty,
              text: AppStrings.repayEntryRepayAll,
              onPressed: () => _openSelectedRepayDetail(context, selectedBills),
            )
          : SizedBox.shrink(),
    );
  }

  void _openBillDetail(BuildContext context, RepayResp bill) {
    final appOrderId = bill.appOrderId?.trim();
    if (appOrderId == null || appOrderId.isEmpty) return;

    context.push(AppRoutePaths.repayOrderDetailWithIds([appOrderId]));
  }

  void _openSelectedRepayDetail(
    BuildContext context,
    List<RepayResp> selectedBills,
  ) {
    if (selectedBills.isEmpty) return;

    if (selectedBills.length == 1) {
      _openBillDetail(context, selectedBills.first);
      return;
    }

    final appOrderIds = selectedBills
        .map((bill) => bill.appOrderId?.trim())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    if (appOrderIds.isEmpty) return;

    context.push(AppRoutePaths.repayMultiOrderDetailWithIds(appOrderIds));
  }
}

class _RepayEntryHeader extends StatelessWidget {
  const _RepayEntryHeader({
    required this.totalAmount,
    required this.showTotalAmount,
  });

  final double totalAmount;
  final bool showTotalAmount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  AppStrings.repayEntryHeaderTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 20 / 16,
                  ),
                ),
                Positioned(
                  right: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(AppRoutePaths.customerService),
                    child: Assets.images.customer.image(width: 32, height: 32),
                  ),
                ),
              ],
            ),
          ),
          if (showTotalAmount)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TotalRepayAmountDisplay(amount: totalAmount),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Assets.images.rightArrow.image(width: 20, height: 20),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RepayEntryContent extends StatelessWidget {
  const _RepayEntryContent({
    required this.bills,
    required this.selectedBillKeys,
    required this.billKeyBuilder,
    this.stateChild,
    required this.onSelectionTap,
    required this.onRepayTap,
  });

  final List<RepayResp> bills;
  final Set<String> selectedBillKeys;
  final String Function(RepayResp bill, int index) billKeyBuilder;
  final Widget? stateChild;
  final void Function(RepayResp bill, int index) onSelectionTap;
  final ValueChanged<RepayResp> onRepayTap;

  @override
  Widget build(BuildContext context) {
    final showSelection = bills.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 17, 12, 12),
          child: Text(
            AppStrings.repayEntryBillTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 20 / 14,
            ),
          ),
        ),
        Expanded(
          child: stateChild != null
              ? AppScrollableStateView(child: stateChild!)
              : bills.isEmpty
              ? const AppScrollableStateView(
                  child: AppEmptyStateView(text: AppStrings.repayEntryEmpty),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    10,
                    0,
                    10,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  itemCount: bills.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    final billKey = billKeyBuilder(bill, index);
                    return RepayBillCard(
                      bill: bill,
                      showSelection: showSelection,
                      selected: selectedBillKeys.contains(billKey),
                      onSelectionTap: () => onSelectionTap(bill, index),
                      onRepayTap: () => onRepayTap(bill),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
