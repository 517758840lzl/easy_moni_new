import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BottomContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;
  final String text;

  const BottomContinueButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
    this.text = AppStrings.continueStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: TextButton(
              onPressed: isEnabled ? onTap : null,
              style: TextButton.styleFrom(
                backgroundColor: isEnabled
                    ? AppColors.primaryDark
                    : const Color(0xFFBDBDBD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                text,
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
}
