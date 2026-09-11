import 'dart:async';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';

class LocationPermissionSheet {
  LocationPermissionSheet._();

  static Future<bool> ensure(BuildContext context) async {
    if (await LocationService.checkPermission()) {
      return true;
    }
    if (!context.mounted) return false;

    final osGranted = await LocationService.requestPermission().timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
    if (!context.mounted) return false;
    if (osGranted || await LocationService.checkPermission()) {
      return true;
    }
    if (!context.mounted) return false;

    final shouldOpenSettings = await show(context);
    if (!context.mounted || !shouldOpenSettings) {
      return false;
    }

    await LocationService.openAppSettings();
    return false;
  }

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.paddingOf(context).bottom;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Material(
            color: const Color(0xFFFDFEFF),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.images.location.image(
                            width: 115,
                            height: 116,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.locationPermissionTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101314),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.locationPermissionDesc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3F4950),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: PermissionActionButtons(
                          secondaryText: AppStrings.cancel,
                          primaryText: AppStrings.goSettings,
                          onSecondaryPressed: () =>
                              Navigator.of(context).pop(false),
                          onPrimaryPressed: () =>
                              Navigator.of(context).pop(true),
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(child: _DragHandle()),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
