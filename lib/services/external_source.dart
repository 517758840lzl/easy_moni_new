import 'package:url_launcher/url_launcher.dart';

/// 外部来源跳转服务，统一承接浏览器、邮箱、第三方 App 等系统级跳转。
class ExternalSource {
  ExternalSource._();

  static final ExternalSource instance = ExternalSource._();

  /// 打开外部链接，失败时返回 false 并记录日志。
  Future<bool> openUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final target = url.trim();
    if (target.isEmpty) return false;

    try {
      return await launchUrl(Uri.parse(target), mode: mode);
    } catch (e) {
      return false;
    }
  }
}
