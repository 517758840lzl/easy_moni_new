import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// 客服页，展示客服入口相关的安全提醒信息。
class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.mineCustomerService)),
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: _AntiFraudCard(),
        ),
      ),
    );
  }
}

/// 防诈骗提示卡片，样式对齐 Figma 客服安全提醒模块。
class _AntiFraudCard extends StatelessWidget {
  const _AntiFraudCard();

  static const double _cardHeight = 192;
  static const double _imageSize = 160;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _cardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141B2B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _AntiFraudGradient()),
          Positioned(
            right: -29,
            bottom: 3,
            child: Assets.images.serviceSafe.image(
              width: _imageSize,
              height: _imageSize,
              fit: BoxFit.contain,
            ),
          ),
          const Padding(padding: EdgeInsets.all(24), child: _AntiFraudText()),
        ],
      ),
    );
  }
}

/// 深色卡片右上角的绿色径向光效。
class _AntiFraudGradient extends StatelessWidget {
  const _AntiFraudGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 0.7,
          colors: [
            const Color(0xFF006C49).withValues(alpha: 0.1),
            const Color(0xFF006C49).withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// 卡片主副文案，独立封装便于后续替换为接口数据。
class _AntiFraudText extends StatelessWidget {
  const _AntiFraudText();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 222,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.customerServiceAntiFraudTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.customerServiceAntiFraudDesc,
              style: TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 14,
                height: 16 / 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
