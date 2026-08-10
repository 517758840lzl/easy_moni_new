abstract final class SplashProgressCurve {
  SplashProgressCurve._();

  static const _stepMs = 700.0;
  static const _totalMs = 3500.0;

  static double at(double controllerValue) {
    final ms = controllerValue.clamp(0.0, 1.0) * _totalMs;
    return _valueAtMs(ms);
  }

  static double _valueAtMs(double ms) {
    if (ms <= 500) return 0;
    if (ms < 500 + _stepMs) {
      return _easeOut((ms - 500) / _stepMs) * 0.30;
    }
    if (ms <= 1500) return 0.30;
    if (ms < 1500 + _stepMs) {
      return 0.30 + _easeOut((ms - 1500) / _stepMs) * 0.35;
    }
    if (ms <= 2800) return 0.65;
    if (ms < 2800 + _stepMs) {
      return 0.65 + _easeOut((ms - 2800) / _stepMs) * 0.35;
    }
    return 1;
  }

  static double _easeOut(double t) {
    final x = t.clamp(0.0, 1.0);
    return 1 - (1 - x) * (1 - x);
  }
}
