import 'package:flutter/material.dart';

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String trimZeroDecimal() {
    final decimalIndex = lastIndexOf('.');
    if (decimalIndex == -1) return this;

    final decimalPart = substring(decimalIndex + 1);
    if (decimalPart.isEmpty) return substring(0, decimalIndex);

    return RegExp(r'^0+$').hasMatch(decimalPart)
        ? substring(0, decimalIndex)
        : this;
  }

  String formatBackendDate() {
    if (isEmpty) return this;

    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?: \d{2}:\d{2}:\d{2})?$',
    ).firstMatch(this);
    if (match == null) return this;

    final year = match.group(1)!;
    final month = match.group(2)!;
    final day = match.group(3)!;
    return '$day/$month/$year';
  }

  String formatDailyInterestLabel({String unit = ''}) {
    if (isEmpty || this == '-') return this;
    return '$this $unit';
  }
}

extension NullableIntExtension on int? {
  String formatLoanTermLabel({int? to, String unit = 'days'}) {
    final from = this;
    if (from == null && to == null) return '-';
    if (from != null && to != null && from != to) {
      return '$from-$to $unit';
    }
    return '${from ?? to} $unit';
  }
}

extension DateTimeExtension on DateTime {
  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String get formatDate {
    return '$year-${_twoDigits(month)}-${_twoDigits(day)}';
  }

  String get formatDateTime {
    return '$formatDate ${_twoDigits(hour)}:${_twoDigits(minute)}';
  }

  String get formatTime {
    return '${_twoDigits(hour)}:${_twoDigits(minute)}';
  }

  String get formatAfCreateTime {
    return '${_twoDigits(day)}/${_twoDigits(month)}/$year '
        '${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)}';
  }

  String timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year(s) ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month(s) ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day(s) ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

extension NumExtension on num {
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals)}';
  }

  String toPercentage({int decimals = 1}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  String toPlainAmountString() => toStringAsFixed(2).trimZeroDecimal();

  String formatAmount({
    String currencySymbol = 'GHS',
    bool showCurrencySymbol = true,
  }) {
    final amount = toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    ).trimZeroDecimal();

    return showCurrencySymbol ? '$currencySymbol $amount' : amount;
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.of(this).size;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  List<T> safeSublist(int start, [int? end]) {
    if (isEmpty) return [];
    final safeStart = start.clamp(0, length);
    final safeEnd = (end ?? length).clamp(safeStart, length);
    return sublist(safeStart, safeEnd);
  }
}
