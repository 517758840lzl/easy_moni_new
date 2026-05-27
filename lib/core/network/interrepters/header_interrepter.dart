import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import '../../constants/api_constants.dart';

class HeaderInterrepter extends Interceptor {
  static final HeaderInterrepter _instance = HeaderInterrepter();

  factory HeaderInterrepter() => _instance;

  HeaderInterrepter._();

  String? _token;
  String? _deviceId;

  void setToken(String? token) {
    _token = token;
  }

  void setDeviceId(String? deviceId) {
    _deviceId = deviceId;
  }

  Map<String, String> get _commonHeader => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': ApiConstants.appVersion,
    'X-Platform': ApiConstants.platform,
    if (_deviceId != null) 'X-Device-Id': _deviceId!,
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  void clearAuth() {
    _token = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(_commonHeader);
    handler.next(options);
  }
}
