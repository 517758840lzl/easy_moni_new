import 'dart:async';

import 'package:easy_moni/core/network/interrepters/header_interrepter.dart';
import 'package:easy_moni/core/router/app_router.dart';
import 'package:easy_moni/core/network/interrepters/logging_interrepter.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:talker/talker.dart';
import 'package:go_router/go_router.dart';
import '../constants/api_constants.dart';
import 'http_result.dart';
import '../../entities/base_result.dart';
import 'package:dio/dio.dart';

class HttpProvider {
  final Dio _dio;
  final Talker _talker;
  final HeaderInterrepter _headerInterceptor;
  bool _isRedirectingToLogin = false;

  HttpProvider._({
    required Dio dio,
    required Talker talker,
    required HeaderInterrepter headerInterceptor,
  }) : _dio = dio,
       _talker = talker,
       _headerInterceptor = headerInterceptor;

  static late HttpProvider instance;

  static void init({required Talker talker}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeOut,
        receiveTimeout: ApiConstants.receiveTimeOut,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'acqChannel': 'GHPM',
          'acqChannelIndex': '0',
          'disableEncBody': 'false',
          'appVersion': ApiConstants.appVersion,
          'clientType': ApiConstants.clientType,
          'advId': ApiConstants.advId,
          'deviceId': ApiConstants.deviceId,
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

  Future<void> setToken(String? token) async {
    _headerInterceptor.setToken(token);
    if (token != null && token.isNotEmpty) {
      await AuthStorage.saveToken(token);
    }
  }

  String? get token => _headerInterceptor.token;

  void setDeviceId(String? deviceId) {
    _headerInterceptor.setDeviceId(deviceId);
  }

  String? get deviceId => _headerInterceptor.deviceId;

  Future<void> clearAuth() async {
    _headerInterceptor.clearAuth();
    await AuthStorage.clearToken();
  }

  void _redirectToLoginIfNeeded() {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;
    unawaited(clearAuth());
    final context = globalNavigationKey.currentContext;
    if (context != null) {
      final currentUri = GoRouter.of(context).routeInformationProvider.value.uri;
      if (currentUri.toString() != '/login') {
        context.go('/login');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isRedirectingToLogin = false;
    });
  }

  bool _isAuthFailure({
    int? bizCode,
    int? statusCode,
    String? message,
  }) {
    if (bizCode == 401 || statusCode == 401) {
      return true;
    }
    final normalizedMessage = message?.toLowerCase() ?? '';
    return normalizedMessage.contains('authentication failed') ||
        normalizedMessage.contains('unable to access system resources');
  }

  HttpResult<T> _serverErrorResult<T>(
    String message, {
    int? bizCode,
    int? statusCode,
    CancelToken? cancelToken,
  }) {
    if (_isAuthFailure(
      bizCode: bizCode,
      statusCode: statusCode,
      message: message,
    )) {
      _redirectToLoginIfNeeded();
    }
    return HttpResult.error(
      HttpResultStatus.serverError,
      message,
      statusCode: statusCode,
      cancelToken: cancelToken,
    );
  }

  HttpListResult<T> _serverListErrorResult<T>(
    String message, {
    int? bizCode,
    int? statusCode,
    CancelToken? cancelToken,
  }) {
    if (_isAuthFailure(
      bizCode: bizCode,
      statusCode: statusCode,
      message: message,
    )) {
      _redirectToLoginIfNeeded();
    }
    return HttpListResult.error(
      HttpResultStatus.serverError,
      message,
      cancelToken: cancelToken,
    );
  }

  Future<HttpResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
    bool includeToken = true,
  }) async {
    try {
      // 使用 dynamic 而不是 T，避免 Dio 自动转换失败
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        options: Options(extra: {'skipToken': !includeToken}),
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
          _talker.debug(
            'BaseResult 结果: code=${result.code}, isSuccess=${result.isSuccess}, data=${result.data}',
          );
          if (result.isSuccess) {
            return HttpResult.success(
              result.data as T,
              cancelToken: cancelToken,
            );
          } else {
            return _serverErrorResult(
              result.message ?? 'Server error',
              bizCode: result.code,
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
    bool includeToken = true,
  }) async {
    try {
      // 使用 dynamic 而不是 T，避免 Dio 自动转换失败
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        options: Options(extra: {'skipToken': !includeToken}),
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
          _talker.debug(
            'BaseResult 结果: code=${result.code}, isSuccess=${result.isSuccess}, data=${result.data}',
          );
          if (result.isSuccess) {
            // 处理 data 为 null 的情况
            if (result.data == null) {
              // 如果 T 是可空的，返回 null
              // 如果 T 是不可空的，尝试创建默认实例
              try {
                final nullValue = null as T;
                return HttpResult.success(nullValue, cancelToken: cancelToken);
              } catch (_) {
                // T 不可空，返回错误
                _talker.debug('POST data is null and T is not nullable');
                return HttpResult.success(
                  fromJson(null),
                  cancelToken: cancelToken,
                );
              }
            }
            return HttpResult.success(
              result.data as T,
              cancelToken: cancelToken,
            );
          } else {
            return _serverErrorResult(
              result.message ?? 'Server error',
              bizCode: result.code,
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
        return _serverListErrorResult(
          result.message ?? 'Server error',
          bizCode: result.code,
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
        final respData = e.response?.data;
        final serverMsg = (respData is Map)
            ? (respData['message'] ?? respData['msg'] ?? 'Server error')
            : 'Server error';
        return HttpResult.error(
          HttpResultStatus.serverError,
          serverMsg as String,
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
        final respData = e.response?.data;
        final serverMsg = (respData is Map)
            ? (respData['message'] ?? respData['msg'] ?? 'Server error')
            : 'Server error';
        return HttpListResult.error(
          HttpResultStatus.serverError,
          serverMsg as String,
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
