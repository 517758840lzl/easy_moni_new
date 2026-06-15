import 'package:easy_moni/core/utils/app_logger.dart';

class BaseResult<T> {
  final int code;
  final String? message;
  final T? data;

  const BaseResult({required this.code, this.message, this.data});

  bool get isSuccess => code == 0 || code == 200;

  factory BaseResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final code = json['code'] as int? ?? -1;
    final message = (json['message'] ?? json['msg']) as String?;
    final data = json['data'];

    T? parsedData;
    if (data != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(data);
      } catch (e) {
        AppLogger.debug('BaseResult.fromJson callback error: $e');
        parsedData = data as T?;
      }
    } else {
      parsedData = data as T?;
    }

    AppLogger.debug(
      'BaseResult: code=$code, message=$message, data=$data, parsedData=$parsedData',
    );

    return BaseResult(code: code, message: message, data: parsedData);
  }
}

class ListResult<T> {
  final int code;
  final String? message;
  final List<T> data;
  final int total;
  final int page;
  final int pageSize;

  const ListResult({
    required this.code,
    this.message,
    required this.data,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
  });

  bool get isSuccess => code == 0;
  bool get hasMore => data.length < total;

  factory ListResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final list =
        (json['data'] as List<dynamic>?)?.map((e) => fromJsonT(e)).toList() ??
        [];
    return ListResult(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String?,
      data: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }
}
