import 'package:flutter/foundation.dart';

abstract final class UploadPlatformSupport {
  UploadPlatformSupport._();

  static bool get supportsAppListAndSms =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
