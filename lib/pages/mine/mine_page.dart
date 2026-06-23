import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/user_repayment_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/mine/components/mine_menu_section.dart';
import 'package:easy_moni/pages/mine/components/pending_repay_card.dart';
import 'package:easy_moni/pages/mine/providers/sign_out_provider.dart';
import 'package:easy_moni/pages/mine/providers/user_info_provider.dart';
import 'package:easy_moni/pages/mine/providers/user_repayment_provider.dart';
import 'package:easy_moni/utils/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 我的页待还订单状态定义，当前仅查询待还款中的订单。
class MineRepayOrderStatus {
  MineRepayOrderStatus._();

  static const int repaying = 4;
  static const List<int> pendingStatusList = <int>[repaying];
}

/// 我的页面，负责用户信息加载、入口事件和页面结构组装。
class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  String _userName = '';
  String _userPhone = '';
  List<UserRepaymentResp> _pendingRepayOrders = const <UserRepaymentResp>[];
  bool _showPendingRepayCard = true;

  /// 当前待还金额为所有待还订单 repayAmount 之和。
  double get _totalRepayAmount {
    return _pendingRepayOrders.fold<double>(
      0,
      (sum, order) => sum + order.repayAmount,
    );
  }

  /// 任一待还订单已逾期时，卡片展示逾期标识。
  bool get _isOverdue {
    return _pendingRepayOrders.any((order) => order.remainingDays < 0);
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPendingRepayOrders();
  }

  Future<void> _loadUserInfo() async {
    try {
      final result = await ref.read(userInfoProvider).call();
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        final userInfo = result.data!;
        setState(() {
          _userName = userInfo.nickName ?? userInfo.userName ?? '';
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

  /// 初始化待还卡片数据，复用用户还款列表接口。
  Future<void> _loadPendingRepayOrders() async {
    try {
      final result = await ref
          .read(userRepaymentProvider)
          .call(statusList: MineRepayOrderStatus.pendingStatusList);
      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _pendingRepayOrders = result.data ?? const <UserRepaymentResp>[];
        });
        AppLogger.debug('待还订单加载成功: ${_pendingRepayOrders.length}');
      } else {
        AppLogger.debug('获取待还订单失败: ${result.message}');
      }
    } catch (e) {
      if (!mounted) return;
      AppLogger.debug('获取待还订单异常: $e');
    }
  }

  void _onRepayTap() {
    AppLogger.debug('点击了去还款');
    final appOrderIds = _pendingRepayOrders
        .map((order) => order.appOrderId.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (appOrderIds.isEmpty) {
      setState(() {
        _showPendingRepayCard = false;
      });
      return;
    }

    if (appOrderIds.length == 1) {
      context.push(AppRoutePaths.repayOrderDetailWithIds(appOrderIds));
      return;
    }

    context.push(AppRoutePaths.repayMultiOrderDetailWithIds(appOrderIds));
  }

  void _onHistoryTap() {
    AppLogger.debug('点击了历史订单');
    context.push(AppRoutePaths.orderHistory);
  }

  void _onCustomerServiceTap() {
    AppLogger.debug('点击了客服');
    context.push(AppRoutePaths.customerService);
  }

  void _onPrivacyPolicyTap() {
    AppLogger.debug('点击了隐私政策');
    // TODO: 打开隐私政策页面
  }

  void _onSettingsTap() {
    AppLogger.debug('点击了设置');
    // TODO: 跳转到设置页面
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
            child: const Text(AppStrings.mineLogoutDialogConfirm),
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

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 212,
      contentTopRadius: 16,
      backgroundColor: AppColors.primaryDark,
      header: _MineHeader(userName: _userName, userPhone: _userPhone),
      content: _MineContent(
        showPendingRepayCard: _showPendingRepayCard,
        pendingAmount: _totalRepayAmount,
        isOverdue: _isOverdue,
        onRepayTap: _onRepayTap,
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
  const _MineHeader({required this.userName, required this.userPhone});

  final String userName;
  final String userPhone;

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
                    Assets.images.customer.image(width: 28, height: 28),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 91,
              height: 91,
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
