import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showDatePickerBottomSheet({
  required BuildContext context,
  required String title,
  DateTime? initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  final min = minimumDate ?? DateTime(DateTime.now().year - 100);
  final max = maximumDate ?? DateTime.now();
  var selected = initialDate ?? DateTime(max.year - 18, max.month, max.day);
  if (selected.isBefore(min)) selected = min;
  if (selected.isAfter(max)) selected = max;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    requestFocus: false,
    builder: (sheetContext) {
      return _DatePickerBottomSheet(
        title: title,
        initialDate: selected,
        minimumDate: min,
        maximumDate: max,
      );
    },
  );
}

class _DatePickerBottomSheet extends StatefulWidget {
  const _DatePickerBottomSheet({
    required this.title,
    required this.initialDate,
    required this.minimumDate,
    required this.maximumDate,
  });

  final String title;
  final DateTime initialDate;
  final DateTime minimumDate;
  final DateTime maximumDate;

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
            ),
            child: Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: const Text(
                    AppStrings.confirm,
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 216,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selected,
                minimumDate: widget.minimumDate,
                maximumDate: widget.maximumDate,
                onDateTimeChanged: (value) => _selected = value,
              ),
            ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
