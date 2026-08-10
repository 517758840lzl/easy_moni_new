import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginAgreementRow extends StatelessWidget {
  const LoginAgreementRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  void _toggle() => onChanged(!agreed);

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 22.75 / 14,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24,
                  height: 28,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _LoginAgreementCheckbox(value: agreed),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.translucent,
            child: Text.rich(
              TextSpan(
                style: textStyle,
                children: [
                  const TextSpan(text: AppStrings.loginAgreePrefix),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _AgreementLink(
                      label: AppStrings.loginAgreementLinkLabel(
                        AppStrings.termsOfServiceTitle,
                      ),
                      style: textStyle,
                      onTap: onOpenTerms,
                    ),
                  ),
                  const TextSpan(text: AppStrings.loginAgreeMiddle),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _AgreementLink(
                      label: AppStrings.loginAgreementLinkLabel(
                        AppStrings.privacyData,
                      ),
                      style: textStyle,
                      onTap: onOpenPrivacy,
                    ),
                  ),
                  const TextSpan(text: AppStrings.loginAgreeSuffix),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgreementLink extends StatelessWidget {
  const _AgreementLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(label, style: style),
    );
  }
}

class _LoginAgreementCheckbox extends StatelessWidget {
  const _LoginAgreementCheckbox({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: value
            ? const Icon(
                Icons.check,
                size: 16,
                color: AppColors.primaryDark,
              )
            : null,
      ),
    );
  }
}
