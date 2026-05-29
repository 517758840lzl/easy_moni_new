import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  final String _userName = 'Derrick Rose';
  final String _userPhone = '123432345676';
  final double _pendingAmount = 100.0;
  final bool _isOverdue = true;

  void _onRepayTap() {
    debugPrint('点击了去还款');
    // TODO: 跳转到还款页面
  }

  void _onHistoryTap() {
    debugPrint('点击了历史订单');
    context.push('/order-history');
  }

  void _onCustomerServiceTap() {
    debugPrint('点击了客服');
    // TODO: 打开客服页面
  }

  void _onPrivacyPolicyTap() {
    debugPrint('点击了隐私政策');
    // TODO: 打开隐私政策页面
  }

  void _onSettingsTap() {
    debugPrint('点击了设置');
    // TODO: 跳转到设置页面
  }

  void _onLogoutTap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行退出登录
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Assets.images.mineBg.provider(),
                fit: BoxFit.cover,
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
                  // 用户头像
                  Container(
                    width: 91,
                    height: 91,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF268470),
                      radius: 40,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 用户名
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // 手机号
                  Text(
                    _userPhone,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
          // 内容区域
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 待还金额卡片
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF5EE),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // 头像占位
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Assets.images.mineArrow.image(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'GHS ${_pendingAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFF5256),
                                                Color(0xFFFF8463),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            '已逾期',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '当前待还',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF808080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),

                                  child: const Text(
                                    '已逾期',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              // const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF808080),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 18),
                    // 功能列表
                    Container(
                      child: Column(
                        children: [
                          // 其他功能标题
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '其他功能',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            icon: Assets.images.mineFile.image(
                              width: 18,
                              height: 18,
                            ),
                            title: '历史订单',
                            onTap: _onHistoryTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Assets.images.minePencil.image(
                              width: 18,
                              height: 18,
                            ),
                            title: '客服',
                            onTap: _onCustomerServiceTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Assets.images.minePhone.image(
                              width: 18,
                              height: 18,
                            ),
                            title: '隐私政策',
                            onTap: _onPrivacyPolicyTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Assets.images.mineEmail.image(
                              width: 18,
                              height: 18,
                            ),
                            title: '设置',
                            onTap: _onSettingsTap,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 退出登录按钮
                    GestureDetector(
                      onTap: _onLogoutTap,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: Color(0xFF909399),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF909399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20 + MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
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
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFACACAC)),
              ],
            ),
          ),
          if (showDivider)
            Container(
              margin: const EdgeInsets.only(left: 52,right: 22),
              height: 1,
              color: const Color(0xFFF5F5F5),
            ),
        ],
      ),
    );
  }
}
