import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';

class HeaderInterrepter extends Interceptor {
  static final HeaderInterrepter _instance = HeaderInterrepter._();

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
    // 'App-Version': ApiConstants.appVersion,
    // 'clientType': ApiConstants.platform,
    if (_deviceId case final deviceId?) 'X-Device-Id': deviceId,
    if (_token case final token?) 'token': token,
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
