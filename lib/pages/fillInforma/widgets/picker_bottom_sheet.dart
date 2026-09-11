import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickerBottomSheetOption {
  const PickerBottomSheetOption({required this.label});

  final String label;
}

class PickerBottomSheet extends StatefulWidget {
  const PickerBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.initialIndex,
    required this.onConfirm,
    this.confirmText = AppStrings.confirm,
  });

  final String title;
  final List<PickerBottomSheetOption> options;
  final int initialIndex;
  final ValueChanged<int> onConfirm;
  final String confirmText;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<PickerBottomSheetOption> options,
    required int selectedIndex,
    required ValueChanged<int> onConfirm,
    String confirmText = AppStrings.confirm,
  }) {
    if (options.isEmpty) {
      return Future.value();
    }

    final safeIndex = selectedIndex.clamp(0, options.length - 1);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      requestFocus: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return PickerBottomSheet(
          title: title,
          options: options,
          initialIndex: safeIndex,
          onConfirm: onConfirm,
          confirmText: confirmText,
        );
      },
    );
  }

  @override
  State<PickerBottomSheet> createState() => _PickerBottomSheetState();
}

class _PickerBottomSheetState extends State<PickerBottomSheet> {
  late int _selectedIndex;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    widget.onConfirm(_selectedIndex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
      child: SizedBox(
        height: 327,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            _buildHeader(context),
            Expanded(
              child: CupertinoPicker.builder(
                scrollController: _scrollController,
                itemExtent: 38,
                onSelectedItemChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                childCount: widget.options.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return Center(
                    child: Text(
                      widget.options[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 14,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w400,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  );
                },
              ),
            ),
            LoanBottomActionButton(
              enabled: true,
              onPressed: _confirmSelection,
              text: widget.confirmText,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.close, size: 16, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 20, height: 20),
        ],
      ),
    );
  }
}
