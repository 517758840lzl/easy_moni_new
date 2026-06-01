import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/pages/loan/loan_home_page.dart';
import 'package:easy_moni/pages/repay/repay_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/pages/fillInforma/personal_info_page.dart';
import 'package:easy_moni/pages/mine/order_history_page.dart';
import 'package:easy_moni/pages/mine/mine.dart';

import '../../gen/assets.gen.dart';
import '../repay/extension_apply_page.dart';
import '../repay/survey_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LoanHomePage(),
    RepayEntryPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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
}
