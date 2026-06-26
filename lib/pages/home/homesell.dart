import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/loan_home_review_page.dart';
import 'package:easy_moni/pages/mine/mine_page.dart';
import 'package:easy_moni/pages/loan/loan_home_page.dart';
import 'package:easy_moni/pages/repay/repay_entry_page.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewAccountHomeProvider = FutureProvider.autoDispose<bool>((ref) {
  return AuthStorage.isReviewAccount();
});

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({
    super.key,
    this.initialTab = AppHomeTabs.loan,
    this.tabRequestId = '',
    this.loanHomeRefreshRequestId = '',
  });

  final String initialTab;
  final String tabRequestId;
  final String loanHomeRefreshRequestId;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late int _currentIndex = _tabIndex(widget.initialTab);
  final Set<int> _visitedTabIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _visitedTabIndexes.add(_currentIndex);
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab == widget.initialTab &&
        oldWidget.tabRequestId == widget.tabRequestId) {
      return;
    }

    setState(() {
      _currentIndex = _tabIndex(widget.initialTab);
      _visitedTabIndexes.add(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewAccountAsync = ref.watch(reviewAccountHomeProvider);
    final pages = List<Widget>.generate(3, (index) {
      // 底部 Tab 首次访问时再挂载，避免进入首页时同时触发三个页面接口。
      if (!_visitedTabIndexes.contains(index)) {
        return const SizedBox.shrink();
      }
      return _buildPage(index, reviewAccountAsync);
    });

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  0,
                  AppStrings.homeTab,
                  Assets.images.loanHomeNormal,
                  Assets.images.loanHome,
                ),

                _buildTabItem(
                  1,
                  AppStrings.repayTab,
                  Assets.images.loanDiscoveryNormal,
                  Assets.images.loanDiscovery,
                ),

                _buildTabItem(
                  2,
                  AppStrings.mineTab,
                  Assets.images.loanNormal,
                  Assets.images.loanMine,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    int index,
    String label,
    AssetGenImage outlinedIcon,
    AssetGenImage filledIcon,
  ) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF268470);
    final inactiveColor = const Color(0xFFACACAC);

    //是否选中
    final currentImage = isSelected ? filledIcon : outlinedIcon;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _visitedTabIndexes.add(index);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 直接调用 .image() 方法渲染图片
            currentImage.image(
              width: 24,
              height: 24,
              // color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index, AsyncValue<bool> reviewAccountAsync) {
    switch (index) {
      case 0:
        // 根据登录接口 cacheData 字段选择贷款首页，审核账号展示审核员版本。
        return reviewAccountAsync.when(
          data: (isReviewAccount) => isReviewAccount
              ? LoanHomeReviewPage(
                  refreshRequestId: widget.loanHomeRefreshRequestId,
                )
              : LoanHomePage(refreshRequestId: widget.loanHomeRefreshRequestId),
          error: (_, _) =>
              LoanHomePage(refreshRequestId: widget.loanHomeRefreshRequestId),
          loading: () => const _HomeTabLoadingPage(),
        );
      case 1:
        return const RepayEntryPage();
      case 2:
        return const MinePage();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HomeTabLoadingPage extends StatelessWidget {
  const _HomeTabLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// 将路由 tab 参数转换为底部导航索引，未知参数默认回到首页。
int _tabIndex(String tab) {
  switch (tab) {
    case AppHomeTabs.repay:
      return 1;
    case AppHomeTabs.mine:
      return 2;
    case AppHomeTabs.loan:
    default:
      return 0;
  }
}
