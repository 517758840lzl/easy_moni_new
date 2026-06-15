import 'package:easy_moni/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../entities/extension_resp.dart';
import '../../../utils/extensions.dart';
import 'providers/extension_provider.dart';

class ExtensionApplyPage extends ConsumerStatefulWidget {
  final String billId;

  const ExtensionApplyPage({super.key, required this.billId});

  @override
  ConsumerState<ExtensionApplyPage> createState() => _ExtensionApplyPageState();
}

class _ExtensionApplyPageState extends ConsumerState<ExtensionApplyPage> {
  ExtensionResp? _extensionData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExtensionDetails();
  }

  Future<void> _loadExtensionDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(extensionProvider);
      final result = await api.call(
        couponIds: [],
        installmentId: int.tryParse(widget.billId) ?? 0,
      );

      if (mounted) {
        setState(() {
          if (result.isSuccess && result.data != null) {
            _extensionData = result.data;
          } else {
            _error = result.message ?? '获取展期详情失败';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          // 顶部绿色渐变背景区域
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF216A4A), Color(0xFF216A4A)],
              ),
            ),
            child: Column(
              children: [
                // 状态栏和导航栏
                _buildHeader(),
                const SizedBox(height: 40),

                // 金额显示
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'GHS',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _extensionData?.extensionFee.formatAmount() ?? '0',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Extension Fee',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
          // 白色内容区域
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _buildContent(),
            ),
          ),
        ],
      ),
      // 底部确认按钮
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '展期信息',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 提示信息
          _buildNoticeCard(),
          const SizedBox(height: 12),
          // 优惠券选择
          _buildCouponCard(),
          const SizedBox(height: 12),
          // 展期详情卡片
          _buildExtensionDetailCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          // 标题
          const Expanded(
            child: Text(
              '展期申请',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          // 占位
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 12,
              color: Color(0xFFFFCC00),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '延期成功后，还款金额将保持不变，不会产生更多费用。',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // 优惠券图标
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFBE5C8), Color(0xFFFFCFBB)],
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: const Center(
              child: Text(
                'GHS',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFE4E68),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 优惠券文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '优惠券',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '提额券或降息券',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFACACAC)),
        ],
      ),
    );
  }

  Widget _buildExtensionDetailCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildDetailRow('延长天数：', '${_extensionData?.remainingDay ?? 0}天'),
          const SizedBox(height: 16),
          _buildDetailRow('新的到期日：', _extensionData?.newDueDate ?? ''),
          const SizedBox(height: 16),
          _buildDetailRow(
            '新到期日应还金额：',
            'GHS ${_extensionData?.totalSureRepayAmounts.toStringAsFixed(2) ?? '0.00'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF252629)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            // 确认展期逻辑
            _showConfirmDialog();
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF268470),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Text(
                '确认展期',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认展期'),
        content: Text('确认申请展期${_extensionData?.remainingDay ?? 0}天吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 处理展期逻辑
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('展期申请成功')));
              context.go(AppRoutePaths.root);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
