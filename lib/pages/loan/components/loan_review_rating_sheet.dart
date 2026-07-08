import 'package:flutter/material.dart';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/models/review_pop_config.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';

/// 借款成功后的评分弹窗，负责星级选择和双按钮交互。
class LoanReviewRatingSheet extends StatefulWidget {
  const LoanReviewRatingSheet({
    super.key,
    required this.config,
    required this.onSubmit,
  });

  final ReviewPopConfig config;
  final ValueChanged<int> onSubmit;

  @override
  State<LoanReviewRatingSheet> createState() => _LoanReviewRatingSheetState();
}

class _LoanReviewRatingSheetState extends State<LoanReviewRatingSheet> {
  late int _score;

  @override
  void initState() {
    super.initState();
    _score = 5;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFFDFEFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 23, 24, 32),
              child: Column(
                children: [
                  Assets.images.loanBook.image(
                    width: 105,
                    height: 105,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.loanReviewRatingTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF101314),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.config.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF3F4950),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RatingStars(
                    score: _score,
                    onChanged: (score) => setState(() => _score = score),
                  ),
                ],
              ),
            ),
            PermissionActionButtons(
              secondaryText: widget.config.cancelText,
              primaryText: widget.config.okText,
              onSecondaryPressed: () => Navigator.of(context).pop(),
              onPrimaryPressed: () => widget.onSubmit(_score),
            ),
            SizedBox(height: bottomInset > 0 ? 0 : 20),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final itemScore = index + 1;
        final selected = itemScore <= score;

        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(itemScore),
            child: SizedBox(
              width: 34,
              height: 34,
              child: selected
                  ? Assets.images.loanStar.image(fit: BoxFit.contain)
                  : Assets.images.loanStarNormal.image(
                      fit: BoxFit.contain,
                      color: AppColors.warning,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
