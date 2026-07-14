import 'package:talker/talker.dart';
import 'package:dio/dio.dart';

class LoggingInterrepter extends Interceptor {
  final Talker takler;

  LoggingInterrepter({required this.takler});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final log = StringBuffer();
    log.writeln('╔══════ REQUEST ══════');
    log.writeln('► ${options.method} ${options.uri}');
    log.writeln('► Headers: ${options.headers}');

    if (options.data != null) {
      log.writeln('► Body: ${_formatJson(options.data)}');
    }
    // TODO: 调试完成后删除。
    // ignore: avoid_print
    print(log.toString());
    takler.debug(log.toString());
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final log = StringBuffer();
    log.writeln('║');
    log.writeln('╠══════ RESPONSE ══════');
    log.writeln('◄ ${response.statusCode} ${response.requestOptions.uri}');
    log.writeln('◄ Data: ${_formatJson(response.data)}');
    log.writeln('╚═════════════════════');

    takler.debug(log.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final log = StringBuffer();
    log.write('=============');
    log.write('=====error=========');
    log.write('type==${err.type}=');
    log.write('message====${err.message}=======');
    log.write('URL==========${err.requestOptions.uri}');
    if (err.response != null) {
      log.write('response======${err.response?.data}');
    }
    log.write('===============error======================');
    takler.error(log.toString(), err, err.stackTrace);
    handler.next(err);
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) {
      try {
        final decode = data;
        return decode;
      } catch (_) {
        return data;
      }
    }
    return data.toString();
  }
}
