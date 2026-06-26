import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/mine/components/mine_menu_section.dart';
import 'package:easy_moni/pages/mine/components/pending_repay_card.dart';
import 'package:easy_moni/pages/mine/providers/sign_out_provider.dart';
import 'package:easy_moni/pages/mine/providers/user_info_provider.dart';
import 'package:easy_moni/pages/repay/providers/repay_list_provider.dart';
import 'package:easy_moni/utils/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 我的页面，负责用户信息加载、入口事件和页面结构组装。
class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  String _userName = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final result = await ref.read(userInfoProvider).call();
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        final userInfo = result.data!;
        setState(() {
          _userName = userInfo.customerName ?? userInfo.userName ?? '';
          _userPhone = userInfo.phone?.toString() ?? '';
        });
        AppLogger.debug('用户信息加载成功: $userInfo');
      } else {
        AppLogger.debug('获取用户信息失败: ${result.message}');
      }
    } catch (e) {
      if (!mounted) return;
      AppLogger.debug('获取用户信息异常: $e');
    }
  }

  void _onRepayTap(List<RepayResp> pendingRepayOrders) {
    final appOrderIds = pendingRepayOrders
        .map((order) => order.appOrderId?.trim())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    if (appOrderIds.isEmpty) return;

    if (appOrderIds.length == 1) {
      context.push(AppRoutePaths.repayOrderDetailWithIds(appOrderIds));
      return;
    }

    context.push(AppRoutePaths.repayMultiOrderDetailWithIds(appOrderIds));
  }

  void _onHistoryTap() {
    context.push(AppRoutePaths.orderHistory);
  }

  void _onCustomerServiceTap() {
    context.push(AppRoutePaths.customerService);
  }

  void _onPrivacyPolicyTap() {
    context.push(AppRoutePaths.privacyPolicy);
  }

  void _onSettingsTap() {
    context.push(AppRoutePaths.settings);
  }

  Future<void> _onLogoutTap() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.mineLogoutDialogTitle),
        content: const Text(AppStrings.mineLogoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _executeLogout();
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _executeLogout() async {
    try {
      final result = await ref.read(signOutProvider).call();
      if (!mounted) return;

      if (result.isSuccess) {
        await HttpProvider.instance.clearAuth();
        if (!mounted) return;
        // 退出登录后回到 GoRouter 管理的登录页，避免原生 Navigator 覆盖路由栈
        context.go(AppRoutePaths.login);
        showToast(AppStrings.mineLogoutSuccess);
      } else {
        showToast(result.message ?? AppStrings.mineLogoutFailed);
      }
    } catch (e) {
      if (!mounted) return;
      AppLogger.debug('退出登录异常: $e');
      showToast(AppStrings.mineLogoutFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final pendingRepayOrders = ref
        .watch(repayEntryBillsProvider)
        .when(
          data: (items) => items,
          error: (_, _) => const <RepayResp>[],
          loading: () => const <RepayResp>[],
        );
    final totalRepayAmount = pendingRepayOrders.fold<double>(
      0,
      (sum, order) => sum + (order.repayAmount ?? 0),
    );
    // 任一待还订单已逾期时，卡片展示逾期标识。
    final isOverdue = pendingRepayOrders.any(
      (order) => (order.remainingDays ?? 0) < 0,
    );

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 212,
      contentTopRadius: 16,
      backgroundColor: AppColors.primaryDark,
      header: _MineHeader(
        userName: _userName,
        userPhone: _userPhone,
        onCustomerServiceTap: _onCustomerServiceTap,
      ),
      content: _MineContent(
        showPendingRepayCard: pendingRepayOrders.isNotEmpty,
        pendingAmount: totalRepayAmount,
        isOverdue: isOverdue,
        onRepayTap: () => _onRepayTap(pendingRepayOrders),
        onHistoryTap: _onHistoryTap,
        onCustomerServiceTap: _onCustomerServiceTap,
        onPrivacyPolicyTap: _onPrivacyPolicyTap,
        onSettingsTap: _onSettingsTap,
        onLogoutTap: _onLogoutTap,
      ),
    );
  }
}

/// 我的页面顶部用户资料区。
class _MineHeader extends StatelessWidget {
  const _MineHeader({
    required this.userName,
    required this.userPhone,
    required this.onCustomerServiceTap,
  });

  final String userName;
  final String userPhone;
  final VoidCallback onCustomerServiceTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.mineBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCustomerServiceTap,
                      child: Assets.images.customer.image(
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 94,
              height: 94,
              child: CircleAvatar(
                backgroundColor: Color(0xFF268470),
                radius: 40,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              userPhone,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

/// 我的页面白色内容区，暂只承载现有入口和静态展示。
class _MineContent extends StatelessWidget {
  const _MineContent({
    required this.showPendingRepayCard,
    required this.pendingAmount,
    required this.isOverdue,
    required this.onRepayTap,
    required this.onHistoryTap,
    required this.onCustomerServiceTap,
    required this.onPrivacyPolicyTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final bool showPendingRepayCard;
  final double pendingAmount;
  final bool isOverdue;
  final VoidCallback onRepayTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onCustomerServiceTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (showPendingRepayCard)
            PendingRepayCard(
              amount: pendingAmount,
              isOverdue: isOverdue,
              onTap: onRepayTap,
            ),
          MineMenuSection(
            onHistoryTap: onHistoryTap,
            onCustomerServiceTap: onCustomerServiceTap,
            onPrivacyPolicyTap: onPrivacyPolicyTap,
            onSettingsTap: onSettingsTap,
          ),
          const SizedBox(height: 8),
          _LogoutButton(onTap: onLogoutTap),
          SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20, color: Color(0xFF909399)),
            SizedBox(width: 8),
            Text(
              AppStrings.mineLogout,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF909399),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
