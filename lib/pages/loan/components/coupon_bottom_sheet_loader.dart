import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/pages/loan/components/coupon_bottom_sheet_content.dart';
import 'package:flutter/material.dart';

class CouponBottomSheetLoader extends StatelessWidget {
  const CouponBottomSheetLoader({
    super.key,
    required this.future,
    this.initialSelectedCouponId,
    this.onSelectionChanged,
  });

  final Future<List<CouponItem>> future;
  final int? initialSelectedCouponId;
  final ValueChanged<CouponItem?>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CouponItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 104,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF268470),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error?.toString();
          return SizedBox(
            height: 104,
            child: Center(
              child: Text(
                (message == null || message.isEmpty)
                    ? AppStrings.couponLoadFailed
                    : message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8A8F98)),
              ),
            ),
          );
        }

        return CouponBottomSheetContent(
          coupons: snapshot.data ?? const <CouponItem>[],
          initialSelectedCouponId: initialSelectedCouponId,
          onSelectionChanged: onSelectionChanged,
        );
      },
    );
  }
}
