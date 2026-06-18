import 'package:flutter/material.dart';

extension StringExtension on String {
  //首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 小数部分全为 0 时去掉小数部分，如 "57,950.00" -> "57,950"。
  String trimZeroDecimal() {
    final decimalIndex = lastIndexOf('.');
    if (decimalIndex == -1) return this;

    final decimalPart = substring(decimalIndex + 1);
    if (decimalPart.isEmpty) return substring(0, decimalIndex);

    return RegExp(r'^0+$').hasMatch(decimalPart)
        ? substring(0, decimalIndex)
        : this;
  }

  /// 将后端 yyyy-MM-dd 日期格式转换为 dd/MM/yyyy，格式不匹配时保留原值。
  String formatBackendDate() {
    if (isEmpty) return this;

    final parts = split('-');
    if (parts.length != 3) return this;

    final year = parts[0];
    final month = parts[1];
    final day = parts[2];
    if (year.length != 4 || month.length != 2 || day.length != 2) {
      return this;
    }

    return '$day/$month/$year';
  }

  /// 格式化日利率展示文案，统一补充利率单位。
  String formatDailyInterestLabel({String unit = 'per day'}) {
    if (isEmpty || this == '-') return this;
    return '$this $unit';
  }
}

extension NullableIntExtension on int? {
  /// 格式化借款期限展示文案，支持单一期限和区间期限。
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
  String get formatDate {
    return '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  //输出完整的“年月日 时:分
  String get formatDateTime {
    return '$formatDate ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get formatTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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

  /// 格式化金额，可控制是否展示金额单位，如 1000 -> "GHS 1,000"。
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
