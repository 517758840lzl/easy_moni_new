import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/mine/providers/delete_account_provider.dart';
import 'package:easy_moni/utils/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 设置页，承载账号相关操作入口。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDeleting = false;

  Future<void> _onDeleteAccountTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.mineDeleteAccountDialogTitle),
        content: const Text(AppStrings.mineDeleteAccountDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _executeDeleteAccount();
  }

  /// 调用注销账号接口，成功后清理本地登录态并回到登录页。
  Future<void> _executeDeleteAccount() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await ref.read(deleteAccountProvider).call();
      if (!mounted) return;

      if (result.isSuccess) {
        await HttpProvider.instance.clearAuth();
        if (!mounted) return;
        context.go(AppRoutePaths.login);
        showToast(AppStrings.mineDeleteAccountSuccess);
        return;
      }
      showToast(result.message ?? AppStrings.mineDeleteAccountFailed);
    } catch (e) {
      if (!mounted) return;
      AppLogger.debug('注销账号异常: $e');
      showToast(AppStrings.mineDeleteAccountFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 64,
      contentTopRadius: 16,
      backgroundColor: AppColors.primaryDark,
      backgroundDecoration: BoxDecoration(
        color: AppColors.primaryDark,
        image: DecorationImage(
          image: Assets.images.mineBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: const _SettingsHeader(),
      content: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            28,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _DeleteAccountCard(
              isLoading: _isDeleting,
              onTap: _onDeleteAccountTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置页顶部导航栏，比例对齐客服页头部。
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Text(
                AppStrings.mineSettings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 注销账号操作卡片，样式参考客服联系方式卡片。
class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E3E4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Assets.images.settingsDeleteAccount.image(),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                AppStrings.mineDeleteAccount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF141B2B),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Assets.images.serviceRightArrow.image(width: 8, height: 12),
          ],
        ),
      ),
    );
  }
}
