import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// 首页仅有一个产品时，在列表底部展示产品宣传区域。
class LoanHomeSingleProductPromo extends StatelessWidget {
  const LoanHomeSingleProductPromo({super.key});

  static const _cardBackground = Color(0xFFE8F4EF);
  static const _titleColor = Color(0xFF101010);
  static const _descColor = Color(0xFF343434);

  static const _featureTitles = [
    AppStrings.reviewFeatureApplyTitle,
    AppStrings.reviewFeatureDisburseTitle,
    AppStrings.reviewFeatureFlexibleTitle,
  ];

  @override
  Widget build(BuildContext context) {
    final isCompactScreen = MediaQuery.sizeOf(context).height <= 667;
    final descFontSize = isCompactScreen ? 9.0 : 10.0;

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
          child: Assets.images.homePromoBanner.image(
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final titleMaxWidth = (constraints.maxWidth - 28) / 3 - 12;
            final titleFontSize = isCompactScreen
                ? 9.0
                : _resolveUnifiedTitleFontSize(
                    titles: _featureTitles,
                    maxWidth: titleMaxWidth,
                    textScaler: MediaQuery.textScalerOf(context),
                  );

            return Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    image: Assets.images.homePromoFeature1,
                    title: AppStrings.reviewFeatureApplyTitle,
                    desc: AppStrings.reviewFeatureApplyDesc,
                    titleFontSize: titleFontSize,
                    descFontSize: descFontSize,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    image: Assets.images.homePromoFeature2,
                    title: AppStrings.reviewFeatureDisburseTitle,
                    desc: AppStrings.reviewFeatureDisburseDesc,
                    titleFontSize: titleFontSize,
                    descFontSize: descFontSize,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureCard(
                    image: Assets.images.homePromoFeature3,
                    title: AppStrings.reviewFeatureFlexibleTitle,
                    desc: AppStrings.reviewFeatureFlexibleDesc,
                    titleFontSize: titleFontSize,
                    descFontSize: descFontSize,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static double _resolveUnifiedTitleFontSize({
    required List<String> titles,
    required double maxWidth,
    required TextScaler textScaler,
  }) {
    if (maxWidth <= 0) {
      return 13;
    }

    for (var size = 13.0; size >= 7.0; size -= 0.5) {
      final style = TextStyle(fontSize: size, fontWeight: FontWeight.w700);
      final allFit = titles.every((title) {
        final painter = TextPainter(
          text: TextSpan(text: title, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(maxWidth: maxWidth);
        return !painter.didExceedMaxLines;
      });
      if (allFit) {
        return size;
      }
    }

    return 7;
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.image,
    required this.title,
    required this.desc,
    required this.titleFontSize,
    required this.descFontSize,
  });

  final AssetGenImage image;
  final String title;
  final String desc;
  final double titleFontSize;
  final double descFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: LoanHomeSingleProductPromo._cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          image.image(width: 48, height: 48, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            widthFactor: 1,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: LoanHomeSingleProductPromo._titleColor,
                height: 16 / 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descFontSize,
              fontWeight: FontWeight.w400,
              color: LoanHomeSingleProductPromo._descColor,
              height: 16 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
