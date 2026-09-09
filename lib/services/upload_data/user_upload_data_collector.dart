import 'package:easy_moni/services/upload_data/dart_upload_device_info_collector.dart';

class UserUploadDataCollector {
  UserUploadDataCollector();

  Future<dynamic> collectDeviceInfo() async {
    try {
      final deviceInfo = await DartUploadDeviceInfoCollector.collect();
      return deviceInfo.isNotEmpty ? deviceInfo : null;
    } catch (error) {
      return null;
    }
  }
}
