import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// 个人中心功能入口列表。
class MineMenuSection extends StatelessWidget {
  const MineMenuSection({
    super.key,
    required this.onHistoryTap,
    required this.onCustomerServiceTap,
    required this.onPrivacyPolicyTap,
    required this.onSettingsTap,
  });

  final VoidCallback onHistoryTap;
  final VoidCallback onCustomerServiceTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MineMenuItem(
          icon: Assets.images.mineFile.image(width: 18, height: 18),
          title: AppStrings.mineHistoryOrders,
          onTap: onHistoryTap,
        ),
        _MineMenuItem(
          icon: Assets.images.minePencil.image(width: 18, height: 18),
          title: AppStrings.mineCustomerService,
          onTap: onCustomerServiceTap,
        ),
        _MineMenuItem(
          icon: Assets.images.minePhone.image(width: 18, height: 18),
          title: AppStrings.privacyData,
          onTap: onPrivacyPolicyTap,
        ),
        _MineMenuItem(
          icon: Assets.images.mineEmail.image(width: 18, height: 18),
          title: AppStrings.mineSettings,
          onTap: onSettingsTap,
          showDivider: false,
        ),
      ],
    );
  }
}

class _MineMenuItem extends StatelessWidget {
  const _MineMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFFACACAC),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              margin: const EdgeInsets.only(left: 52, right: 22),
              height: 1,
              color: const Color(0xFFF5F5F5),
            ),
        ],
      ),
    );
  }
}
