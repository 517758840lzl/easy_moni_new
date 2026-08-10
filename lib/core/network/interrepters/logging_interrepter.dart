import 'package:dio/dio.dart';
import 'package:easy_moni/core/network/network_log.dart';

class LoggingInterrepter extends Interceptor {
  final Map<String, DateTime> _startTimes = {};

  String _requestKey(RequestOptions options) =>
      '${options.method}:${options.uri}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTimes[_requestKey(options)] = DateTime.now();
    NetworkLog.request(
      method: options.method,
      uri: options.uri,
      headers: options.headers,
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final key = _requestKey(response.requestOptions);
    final startedAt = _startTimes.remove(key);
    final duration = startedAt == null
        ? null
        : DateTime.now().difference(startedAt);

    NetworkLog.response(
      method: response.requestOptions.method,
      uri: response.requestOptions.uri,
      statusCode: response.statusCode,
      wireData: response.data,
      duration: duration,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _startTimes.remove(_requestKey(err.requestOptions));
    NetworkLog.error(
      method: err.requestOptions.method,
      uri: err.requestOptions.uri,
      message: '${err.type.name}: ${err.message ?? 'unknown'}',
    );
    handler.next(err);
  }
}
