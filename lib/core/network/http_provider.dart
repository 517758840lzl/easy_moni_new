import 'dart:convert';
import 'package:easy_moni/core/network/interrepters/header_interrepter.dart';
import 'package:easy_moni/core/network/interrepters/logging_interrepter.dart';
import 'package:talker/talker.dart';
import '../constants/api_constants.dart';
import 'http_result.dart';
import '../../entities/base_result.dart';
import 'package:dio/dio.dart';

class HttpProvider {
  final Dio _dio;
  final Talker _talker;
  final HeaderInterrepter _headerInterceptor;

  HttpProvider._({
    required Dio dio,
    required Talker talker,
    required HeaderInterrepter headerInterceptor,
  }) : _dio = dio,
       _talker = talker,
       _headerInterceptor = headerInterceptor;

  static late HttpProvider instance;
  static late Talker _talkerInstance;

  static void init({required Talker talker}) {
    _talkerInstance = talker;

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeOut,
        receiveTimeout: ApiConstants.receiveTimeOut,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'acqChannel':'GHQU',
          'acqChannelIndex': '0',
          'disableEncBody': false,
          // 'token': 'eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl90b2tlbl9rZXkiOiJHSFFVOjIzMzUwNDY4NDU2ODphY2EyY2JkZC03MTY5LTRkZjQtODExNC0wNmQ5N2FiOGYyMjQifQ.JUsSwNbEalJqQ4JSZsv1by6NGvg7e8ywATNNRKxzyepghHS4VzRqpLcbOlQjztKM52e-N1yBEWEfvkfc61K5Cg',
        },
      ),
    );

    final headerInterceptor = HeaderInterrepter();
    final loggingInterceptor = LoggingInterrepter(takler: talker);

    dio.interceptors.addAll([headerInterceptor, loggingInterceptor]);

    instance = HttpProvider._(
      dio: dio,
      talker: talker,
      headerInterceptor: headerInterceptor,
    );
  }

  void setToken(String? token) {
    _headerInterceptor.setToken(token);
  }

  void setDeviceId(String? deviceId) {
    _headerInterceptor.setDeviceId(deviceId);
  }

  void clearAuth() {
    _headerInterceptor.clearAuth();
  }

  Future<HttpResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      // 使用 dynamic 而不是 T，避免 Dio 自动转换失败
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
      );

      if (response.data == null) {
        return HttpResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      Map<String, dynamic>? map;
      final dataType = response.data.runtimeType.toString();
      _talker.debug('GET response.data type: $dataType');
      
      try {
        final sourceMap = response.data as Map;
        map = {};
        for (final key in sourceMap.keys) {
          map[key.toString()] = sourceMap[key];
        }
      } catch (e) {
        _talker.error('Map conversion error: $e');
        _talker.error('Map conversion stack: ${StackTrace.current}');
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Map conversion error: $e',
          cancelToken: cancelToken,
        );
      }

      try {
        if (map.containsKey('code')) {
          _talker.debug('调用 BaseResult.fromJson, map=$map');
          final result = BaseResult.fromJson(map, fromJson);
          _talker.debug('BaseResult 结果: code=${result.code}, isSuccess=${result.isSuccess}, data=${result.data}');
          if (result.isSuccess) {
            return HttpResult.success(
              result.data as T,
              cancelToken: cancelToken,
            );
          } else {
            return HttpResult.error(
              HttpResultStatus.serverError,
              result.message ?? 'Server error',
              statusCode: response.statusCode,
              cancelToken: cancelToken,
            );
          }
        }
        return HttpResult.success(fromJson(map), cancelToken: cancelToken);
      } catch (e, stack) {
        _talker.error('Parse error: $e\n$stack');
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Parse error: $e',
          cancelToken: cancelToken,
        );
      }
    } on DioException catch (e) {
      _talker.error('DioException: $e');
      return _handleDioException(e, cancelToken);
    } catch (e, stack) {
      _talker.error('Unexpected error: $e\n$stack');
      return HttpResult.error(
        HttpResultStatus.unKnown,
        e.toString(),
        cancelToken: cancelToken,
      );
    }
  }

  Future<HttpResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      // 使用 dynamic 而不是 T，避免 Dio 自动转换失败
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
      );

      if (response.data == null) {
        return HttpResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      Map<String, dynamic>? map;
      final dataType = response.data.runtimeType.toString();
      _talker.debug('POST response.data type: $dataType');
      
      try {
        // 使用 Map.from 来确保正确转换
        _talker.debug('POST response.data before cast: ${response.data}');
        _talker.debug('POST response.data type: ${response.data.runtimeType}');
        final sourceMap = response.data as Map;
        map = {};
        for (final key in sourceMap.keys) {
          map[key.toString()] = sourceMap[key];
        }
        _talker.debug('POST map after conversion: $map');
      } catch (e) {
        _talker.error('Map conversion error: $e');
        _talker.error('Map conversion stack: ${StackTrace.current}');
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Map conversion error: $e',
          cancelToken: cancelToken,
        );
      }

      try {
        if (map.containsKey('code')) {
          _talker.debug('调用 BaseResult.fromJson, map=$map');
          final result = BaseResult.fromJson(map, fromJson);
          _talker.debug('BaseResult 结果: code=${result.code}, isSuccess=${result.isSuccess}, data=${result.data}');
          if (result.isSuccess) {
            return HttpResult.success(
              result.data as T,
              cancelToken: cancelToken,
            );
          } else {
            return HttpResult.error(
              HttpResultStatus.serverError,
              result.message ?? 'Server error',
              statusCode: response.statusCode,
              cancelToken: cancelToken,
            );
          }
        }
        return HttpResult.success(fromJson(map), cancelToken: cancelToken);
      } catch (e, stack) {
        _talker.error('Parse error: $e\n$stack');
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Parse error: $e',
          cancelToken: cancelToken,
        );
      }
    } on DioException catch (e) {
      _talker.error('DioException: $e');
      return _handleDioException(e, cancelToken);
    } catch (e, stack) {
      _talker.error('Unexpected error: $e\n$stack');
      return HttpResult.error(
        HttpResultStatus.unKnown,
        e.toString(),
        cancelToken: cancelToken,
      );
    }
  }

  Future<HttpListResult<T>> getList<T>(
    String path, {
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
      );

      if (response.data == null) {
        return HttpListResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      // List
      if (response.data is List) {
        final list = (response.data as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();

        return HttpListResult.success(
          list,
          total: list.length,
          cancelToken: cancelToken,
        );
      }

      final result = ListResult.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
      if (result.isSuccess) {
        return HttpListResult.success(
          result.data,
          total: result.total,
          page: result.page,
          pageSize: result.pageSize,
          cancelToken: cancelToken,
        );
      } else {
        return HttpListResult.error(
          HttpResultStatus.serverError,
          result.message ?? 'Server error',
          statusCode: response.statusCode,
          cancelToken: cancelToken,
        );
      }
    } on DioException catch (e) {
      return _handleListDioException(e, cancelToken);
    } catch (e) {
      _talker.error('Unexpected error: $e');
      return HttpListResult.error(
        HttpResultStatus.unKnown,
        e.toString(),
        cancelToken: cancelToken,
      );
    }
  }

  HttpResult<T> _handleDioException<T>(
    DioException e,
    CancelToken? cancelToken,
  ) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpResult.error(
          HttpResultStatus.timeout,
          'Connection timeout',
          statusCode: e.response?.statusCode,
          cancelToken: cancelToken,
        );
      case DioExceptionType.cancel:
        return HttpResult.error(
          HttpResultStatus.cancel,
          'Request cancelled',
          cancelToken: cancelToken,
        );
      case DioExceptionType.connectionError:
        return HttpResult.error(
          HttpResultStatus.networkError,
          'Network connection error',
          cancelToken: cancelToken,
        );
      case DioExceptionType.badResponse:
        return HttpResult.error(
          HttpResultStatus.serverError,
          e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
          cancelToken: cancelToken,
        );
      default:
        return HttpResult.error(
          HttpResultStatus.unKnown,
          e.message ?? 'Unknown error',
          statusCode: e.response?.statusCode,
          cancelToken: cancelToken,
        );
    }
  }

  HttpListResult<T> _handleListDioException<T>(
    DioException e,
    CancelToken? cancelToken,
  ) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpListResult.error(
          HttpResultStatus.timeout,
          'Connection timeout',
          cancelToken: cancelToken,
        );
      case DioExceptionType.cancel:
        return HttpListResult.error(
          HttpResultStatus.cancel,
          'Request cancelled',
          cancelToken: cancelToken,
        );
      case DioExceptionType.connectionError:
        return HttpListResult.error(
          HttpResultStatus.networkError,
          'Network connection error',
          cancelToken: cancelToken,
        );
      case DioExceptionType.badResponse:
        return HttpListResult.error(
          HttpResultStatus.serverError,
          e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
          cancelToken: cancelToken,
        );
      default:
        return HttpListResult.error(
          HttpResultStatus.unKnown,
          e.message ?? 'Unknown error',
          cancelToken: cancelToken,
        );
    }
  }
}
