class BaseResult<T> {
  final int code;
  final String? message;
  final T? data;

  const BaseResult({required this.code, this.message, this.data});

  bool get isSuccess => code == 0;

  factory BaseResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResult(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
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
