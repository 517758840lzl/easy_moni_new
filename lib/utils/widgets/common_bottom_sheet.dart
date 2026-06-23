import 'package:flutter/material.dart';

class CommonBottomSheetAction<T> {
  const CommonBottomSheetAction({
    required this.text,
    this.result,
    this.onPressed,
    this.isPrimary = true,
    this.enabled = true,
    this.closeOnPressed = true,
  });

  final String text;
  final T? result;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool enabled;
  final bool closeOnPressed;
}

class CommonBottomSheet<T> extends StatelessWidget {
  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.actions,
    this.image,
    this.content,
    this.showDragHandle = true,
    this.backgroundColor = const Color(0xFFFDFEFF),
  }) : assert(actions.length > 0 && actions.length <= 2);

  final String title;
  final String description;
  final Widget? image;
  final Widget? content;
  final List<CommonBottomSheetAction<T>> actions;
  final bool showDragHandle;
  final Color backgroundColor;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    required List<CommonBottomSheetAction<T>> actions,
    Widget? image,
    Widget? content,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color backgroundColor = const Color(0xFFFDFEFF),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return CommonBottomSheet<T>(
          title: title,
          description: description,
          image: image,
          content: content,
          actions: actions,
          showDragHandle: showDragHandle,
          backgroundColor: backgroundColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.5;
    final hasTextContent =
        title.trim().isNotEmpty || description.trim().isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Material(
          color: backgroundColor,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (image != null) ...[
                              image!,
                              const SizedBox(height: 24),
                            ],
                            if (hasTextContent)
                              _BottomSheetTextContent(
                                title: title,
                                description: description,
                              ),
                            if (content != null && hasTextContent)
                              const SizedBox(height: 24),
                            ?content,
                          ],
                        ),
                      ),
                    ),
                  ),
                  _BottomSheetActions<T>(
                    actions: actions,
                    bottomPadding: bottomPadding,
                  ),
                ],
              ),
              if (showDragHandle)
                const Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(child: _BottomSheetDragHandle()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetTextContent extends StatelessWidget {
  const _BottomSheetTextContent({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101314),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF3F4950),
          ),
        ),
      ],
    );
  }
}

class _BottomSheetActions<T> extends StatelessWidget {
  const _BottomSheetActions({
    required this.actions,
    required this.bottomPadding,
  });

  final List<CommonBottomSheetAction<T>> actions;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 4, 20, 8 + bottomPadding),
      child: actions.length == 1
          ? _BottomSheetActionButton<T>(action: actions.first)
          : Row(
              children: [
                Expanded(
                  child: _BottomSheetActionButton<T>(action: actions[0]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BottomSheetActionButton<T>(action: actions[1]),
                ),
              ],
            ),
    );
  }
}

class _BottomSheetActionButton<T> extends StatelessWidget {
  const _BottomSheetActionButton({required this.action});

  final CommonBottomSheetAction<T> action;

  @override
  Widget build(BuildContext context) {
    final isPrimary = action.isPrimary;
    final enabled = action.enabled;

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: TextButton(
        onPressed: enabled ? () => _handlePressed(context) : null,
        style: TextButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF268470) : Colors.white,
          disabledBackgroundColor: isPrimary
              ? const Color(0xFFC2C9CE)
              : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF268470),
          disabledForegroundColor: isPrimary
              ? Colors.white
              : const Color(0xFFC2C9CE),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isPrimary ? 100 : 30),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: enabled
                        ? const Color(0xFF268470)
                        : const Color(0xFFC2C9CE),
                  ),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        child: Text(action.text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  void _handlePressed(BuildContext context) {
    action.onPressed?.call();
    if (action.closeOnPressed) {
      Navigator.of(context).pop(action.result);
    }
  }
}

class _BottomSheetDragHandle extends StatelessWidget {
  const _BottomSheetDragHandle();

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
