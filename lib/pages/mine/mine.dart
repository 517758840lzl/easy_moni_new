import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  // TODO: 正式环境需要从用户状态管理获取
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
    debugPrint('点击了退出登录');
    // TODO: 退出登录逻辑
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
              // TODO: 执行退出登录
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 绿色背景区域
          Container(
            decoration: const BoxDecoration(color: Color(0xFF216A4A)),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        const Expanded(child: SizedBox()),
                        // More icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 用户头像
                  Container(
                    width: 91,
                    height: 91,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 内容区域
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 待还金额卡片
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF5EE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
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
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GHS ${_pendingAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
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
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF5256),
                                        Color(0xFFFF8463),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF808080),
                                size: 16,
                              ),
                              const SizedBox(width: 60),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 功能列表
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
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
                            icon: Icons.history,
                            title: '历史订单',
                            onTap: _onHistoryTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Icons.support_agent,
                            title: '客服',
                            onTap: _onCustomerServiceTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: '隐私政策',
                            onTap: _onPrivacyPolicyTap,
                            showDivider: true,
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
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
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
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
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 52),
      height: 1,
      color: const Color(0xFFF5F5F5),
    );
  }
}
