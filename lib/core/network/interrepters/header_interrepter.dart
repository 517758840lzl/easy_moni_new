import 'package:dio/dio.dart';
import 'package:easy_moni/core/config/environment_config.dart';

class HeaderInterrepter extends Interceptor {
  HeaderInterrepter(this._config);

  final EnvironmentConfig _config;
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

  Map<String, String> get _commonHeader =>
      _config.commonHeaders(token: _token, deviceId: _deviceId);

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
