import 'package:easy_moni/core/utils/app_logger.dart';

class SignOutResp {
  const SignOutResp();

  factory SignOutResp.fromJson(dynamic json) {
    try {
      if (json is Map<String, dynamic>) {
      } else if (json is Map) {
      } else if (json is String) {
      } else {
        AppLogger.debug('SignOutResp.fromJson: 未知类型 ${json.runtimeType}');
        return const SignOutResp();
      }

      return const SignOutResp();
    } catch (e, stack) {
      AppLogger.debug('SignOutResp.fromJson 异常: $e\n$stack');
      return const SignOutResp();
    }
  }

  @override
  String toString() {
    return 'SignOutResp()';
  }
}
