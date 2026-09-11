import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class LoanOrderStatusVisual {
  const LoanOrderStatusVisual({
    required this.label,
    required this.gradient,
    required this.footerText,
  });

  final String label;
  final List<Color> gradient;
  final String footerText;

  static LoanOrderStatusVisual forStatus(
    int? statusCode, {
    int? remainingDays,
  }) {
    if (statusCode == 4 && remainingDays != null && remainingDays < 0) {
      return const LoanOrderStatusVisual(
        label: AppStrings.loanOrderStatusOverdue,
        gradient: [Color(0xFFFF5265), Color(0xFFFF843F)],
        footerText: AppStrings.loanOrderFooterOverdue,
      );
    }

    switch (statusCode) {
      case 20:
        return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusReviewing,
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: AppStrings.loanOrderFooterReviewing,
        );
      case 3:
        return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusDisbursing,
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: AppStrings.loanOrderFooterDisbursing,
        );
      case 4:
        return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusWaitingRepayment,
          gradient: [Color(0xFFF9B072), Color(0xFFFF843F)],
          footerText: AppStrings.loanOrderFooterWaitingRepayment,
        );
      case 22:
       return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusReviewFailed,
          gradient: [Color(0xFFC1C3C6), Color(0xFFC1C3C6)],
          footerText: AppStrings.loanOrderFooterTransferFailed,
        );
      case 5:
        return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusTransferFailed,
          gradient: [Color(0xFFC1C3C6), Color(0xFFC1C3C6)],
          footerText: AppStrings.loanOrderFooterTransferFailed,
        );
      default:
        return const LoanOrderStatusVisual(
          label: AppStrings.loanOrderStatusReviewing,
          gradient: [Color(0xFF38B899), Color(0xFF38B899)],
          footerText: AppStrings.loanOrderFooterReviewing,
        );
    }
  }
}
