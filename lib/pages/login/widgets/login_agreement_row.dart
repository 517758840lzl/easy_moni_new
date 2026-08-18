import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginAgreementRow extends StatefulWidget {
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

  @override
  State<LoginAgreementRow> createState() => _LoginAgreementRowState();
}

class _LoginAgreementRowState extends State<LoginAgreementRow> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onOpenTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onOpenPrivacy;
  }

  @override
  void didUpdateWidget(LoginAgreementRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _termsRecognizer.onTap = widget.onOpenTerms;
    _privacyRecognizer.onTap = widget.onOpenPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _toggle() => widget.onChanged(!widget.agreed);

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 375;
    final fontSize = isCompact ? 12.0 : 14.0;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: isCompact ? 18 / 12 : 22.75 / 14,
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
                    child: _LoginAgreementCheckbox(value: widget.agreed),
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
                  TextSpan(
                    text: '<${AppStrings.termsOfServiceTitle}>',
                    style: textStyle,
                    recognizer: _termsRecognizer,
                  ),
                  const TextSpan(text: AppStrings.loginAgreeMiddle),
                  TextSpan(
                    text: '<${AppStrings.privacyData}>',
                    style: textStyle,
                    recognizer: _privacyRecognizer,
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
