import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    this.child,
    this.icon,
    this.text = '',
    this.actionText = '',
    this.onActionTap,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget? child;
  final IconData? icon;
  final String text;
  final String actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final customChild = child;
    if (customChild != null) {
      return Center(child: customChild);
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 54, color: const Color(0xFFACACAC)),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF787878),
                  height: 20 / 14,
                ),
              ),
            ],
            if (actionText.isNotEmpty && onActionTap != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onActionTap, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyStateView extends StatelessWidget {
  const AppEmptyStateView({
    super.key,
    required this.text,
    this.icon = Icons.receipt_long_outlined,
  });

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppStateView(icon: icon, text: text);
  }
}

class AppErrorStateView extends StatelessWidget {
  const AppErrorStateView({
    super.key,
    required this.text,
    required this.onReload,
  });

  final String text;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.error_outline_rounded,
      text: text,
      actionText: AppStrings.stateReloadAction,
      onActionTap: onReload,
    );
  }
}

class AppScrollableStateView extends StatelessWidget {
  const AppScrollableStateView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
