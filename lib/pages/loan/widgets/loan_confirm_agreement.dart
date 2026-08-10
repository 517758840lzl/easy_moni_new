import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoanConfirmAgreement extends StatelessWidget {
  const LoanConfirmAgreement({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onOpenAgreement,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenAgreement;

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF4A4D52);
    const textStyle = TextStyle(
      color: textColor,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 18 / 12,
    );
    const linkStyle = TextStyle(
      color: AppColors.primaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 18 / 12,
    );

    return GestureDetector(
      onTap: () => onChanged(!agreed),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AgreementCheckbox(value: agreed),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: textStyle,
                children: [
                  const TextSpan(text: AppStrings.loanConfirmAgreePrefix),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onOpenAgreement,
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        AppStrings.loanConfirmAgreeLink,
                        style: linkStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? AppColors.primaryDark : Colors.white,
          border: Border.all(color: AppColors.primaryDark),
        ),
        child: value
            ? const Icon(Icons.check, size: 11, color: Colors.white)
            : null,
      ),
    );
  }
}
