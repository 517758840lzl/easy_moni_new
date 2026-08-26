class NonRepeatableClick {
  static DateTime? _lastClickTime;

  static Future<void> checkClick({
    Duration debounceDuration = const Duration(milliseconds: 500),
    void Function()? click,
  }) async {
    final now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) >= debounceDuration) {
      _lastClickTime = now;
      click?.call();
    }
  }
}
