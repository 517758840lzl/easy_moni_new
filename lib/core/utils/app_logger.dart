import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// 应用统一日志工具，集中管理日志实例、等级和输出开关。
class AppLogger {
  AppLogger._();

  static final Talker _talker = Talker(
    settings: TalkerSettings(enabled: kDebugMode),
  );

  /// 共享 Talker 实例，供网络、Riverpod 等模块复用。
  static Talker get instance => _talker;

  /// 调试日志，默认仅在 Debug 模式输出。
  static void debug(Object? message) {
    if (kDebugMode) {
      _talker.debug(message);
    }
  }

  /// 普通信息日志，默认仅在 Debug 模式输出。
  static void info(Object? message) {
    if (kDebugMode) {
      _talker.info(message);
    }
  }

  /// 警告日志，默认仅在 Debug 模式输出。
  static void warning(Object? message) {
    if (kDebugMode) {
      _talker.warning(message);
    }
  }

  /// 错误日志，支持携带异常和堆栈信息。
  static void error(
    Object? message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      _talker.error(message, exception, stackTrace);
    }
  }
}
