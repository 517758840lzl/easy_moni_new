import 'package:dio/dio.dart';

enum HttpResultStatus {
  success,
  error,
  networkError,
  timeout,
  cancel,
  serverError,
  unKnown,
}

class HttpResult<T> {
  final HttpResultStatus status;
  final T? data;
  final String? message;
  final int? statusCode;
  final CancelToken? cancelToken;

  const HttpResult({
    required this.status,
    this.data,
    this.message,
    this.statusCode,
    this.cancelToken,
  });
  bool get isSuccess => status == HttpResultStatus.success;
  factory HttpResult.success(T data, {CancelToken? cancelToken}) {
    return HttpResult(
      status: HttpResultStatus.success,
      data: data,
      cancelToken: cancelToken,
    );
  }

  factory HttpResult.error(
    HttpResultStatus status,
    String message, {
    int? statusCode,
    CancelToken? cancelToken,
  }) {
    return HttpResult(
      status: status,
      message: message,
      statusCode: statusCode,
      cancelToken: cancelToken,
    );
  }

  @override
  String toString() {
    return 'HttpResult(status: $status, message: $message, statusCode: $statusCode)';
  }
}

class HttpListResult<T> {
  final HttpResultStatus status;
  final List<T> data;
  final String? message;
  final int total;
  final int page;
  final int pageSize;
  final CancelToken? cancelToken;

  const HttpListResult({
    required this.status,
    this.data = const [],
    this.message,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.cancelToken,
  });

  bool get isSuccess => status == HttpResultStatus.success;
  bool get hasMore => data.length < total;

  factory HttpListResult.success(
    List<T> data, {
    int total = 0,
    int page = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) {
    return HttpListResult(
      status: HttpResultStatus.success,
      data: data,
      total: total,
      page: page,
      pageSize: pageSize,
      cancelToken: cancelToken,
    );
  }

  factory HttpListResult.error(
    HttpResultStatus status,
    String message, {
    int? statusCode,
    CancelToken? cancelToken,
  }) {
    return HttpListResult(
      status: status,
      message: message,
      cancelToken: cancelToken,
    );
  }
}
