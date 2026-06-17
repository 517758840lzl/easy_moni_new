import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 57),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5265), Color(0xFFFF843F)],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Text(
          AppStrings.repayBillOverdueStatus,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}