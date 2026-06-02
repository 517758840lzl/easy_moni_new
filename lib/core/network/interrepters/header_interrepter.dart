import 'package:dio/dio.dart';

class HeaderInterrepter extends Interceptor {
  static final HeaderInterrepter _instance = HeaderInterrepter._();

  factory HeaderInterrepter() => _instance;

  HeaderInterrepter._();

  String? _token;
  String? _deviceId;

  String? get token => _token;
  String? get deviceId => _deviceId;

  void setToken(String? token) {
    _token = token;
  }

  void setDeviceId(String? deviceId) {
    _deviceId = deviceId;
  }

  Map<String, String> get _commonHeader => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_deviceId case final deviceId?) 'X-Device-Id': deviceId,
    if (_token case final token?) 'token': token,
  };

  void clearAuth() {
    _token = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipToken = options.extra['skipToken'] == true;
    final headers = Map<String, String>.from(_commonHeader);
    if (skipToken) {
      headers.remove('token');
    }
    options.headers.addAll(headers);
    handler.next(options);
  }
}
