import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/loan_home_page.dart';
import 'package:flutter/material.dart';

// 审核员首页：复用借款首页业务逻辑，仅追加产品特色展示区域。
class LoanHomeReviewPage extends StatelessWidget {
  const LoanHomeReviewPage({super.key, this.refreshRequestId = ''});

  final String refreshRequestId;

  @override
  Widget build(BuildContext context) {
    return LoanHomeScaffold(
      refreshRequestId: refreshRequestId,
      showAvailableProductCount: false,
      contentPanelTopOffset: 110,
      bottomContent: const _ReviewFeatureSection(),
    );
  }
}

// 产品特色模块：展示审核员版本底部宣传 banner 与三项服务卖点。
class _ReviewFeatureSection extends StatelessWidget {
  const _ReviewFeatureSection();

  static const _cardBackground = Color(0xFFE8F4EF);
  static const _titleColor = Color(0xFF101010);
  static const _descColor = Color(0xFF343434);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.reviewFeatureTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _titleColor,
            height: 28 / 20,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Assets.images.reviewBanner.image(
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                image: Assets.images.review1,
                title: AppStrings.reviewFeatureApplyTitle,
                desc: AppStrings.reviewFeatureApplyDesc,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _FeatureCard(
                image: Assets.images.review2,
                title: AppStrings.reviewFeatureDisburseTitle,
                desc: AppStrings.reviewFeatureDisburseDesc,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _FeatureCard(
                image: Assets.images.review3,
                title: AppStrings.reviewFeatureFlexibleTitle,
                desc: AppStrings.reviewFeatureFlexibleDesc,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.image,
    required this.title,
    required this.desc,
  });

  final AssetGenImage image;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: _ReviewFeatureSection._cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          image.image(width: 48, height: 48, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _ReviewFeatureSection._titleColor,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: _ReviewFeatureSection._descColor,
              height: 16 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
