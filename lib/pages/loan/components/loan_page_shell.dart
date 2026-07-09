import 'package:flutter/material.dart';

/// Shared rounded page shell for loan flows.
///
/// Handles only the background, header, and rounded white content area.
class LoanRoundedPageShell extends StatelessWidget {
  const LoanRoundedPageShell({
    super.key,
    required this.header,
    required this.content,
    this.contentTop,
    this.contentHeightFactor,
    this.contentTopRadius = 16,
    this.backgroundColor = const Color(0xFF216A4A),
    this.backgroundDecoration,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  }) : assert(
         contentTop != null || contentHeightFactor != null,
         'Either contentTop or contentHeightFactor must be provided.',
       ),
       assert(
         contentHeightFactor == null ||
             (contentHeightFactor > 0 && contentHeightFactor <= 1),
         'contentHeightFactor must be greater than 0 and less than or equal to 1.',
       );

  /// Header area, such as amount, title, or customer support entry.
  final Widget header;

  /// Rounded white content area; each page owns its own scrolling and state.
  final Widget content;

  /// Fixed top offset for the white content area; takes priority over [contentHeightFactor].
  final double Function(BuildContext context)? contentTop;

  /// Height ratio used by the white content area, such as 0.72.
  final double? contentHeightFactor;

  /// Top corner radius of the white content area.
  final double contentTopRadius;

  /// Color for the Scaffold and default background layer.
  final Color backgroundColor;

  /// Custom background decoration, such as an image or gradient.
  final Decoration? backgroundDecoration;

  /// Fixed bottom action area.
  final Widget? bottomNavigationBar;

  /// Passed through to Scaffold so form pages can control keyboard insets.
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final resolvedContentTop =
        contentTop?.call(context) ?? screenHeight * (1 - contentHeightFactor!);
    final panelTop = resolvedContentTop.clamp(0.0, screenHeight).toDouble();

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration:
                    backgroundDecoration ??
                    BoxDecoration(color: backgroundColor),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: header),
            Positioned.fill(
              top: panelTop,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(contentTopRadius),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
