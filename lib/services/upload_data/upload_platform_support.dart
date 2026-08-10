import 'package:flutter/foundation.dart';

/// 风控补传能力按平台区分：App 列表与短信仅 Android 可采集。
abstract final class UploadPlatformSupport {
  UploadPlatformSupport._();

  static bool get supportsAppListAndSms =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
