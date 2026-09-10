import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_moni/core/config/environment_config.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/network/interrepters/header_interrepter.dart';
import 'package:easy_moni/core/router/app_router.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/utils/request_security_util.dart';
import 'package:easy_moni/entities/base_result.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 统一网络请求入口，负责请求配置、加密请求体、响应解析和登录态失效处理。
class HttpProvider {
  final Dio _dio;
  final EnvironmentConfig _config;
  final HeaderInterrepter _headerInterceptor;
  bool _isRedirectingToLogin = false;

  HttpProvider._({
    required this._dio,
    required this._config,
    required this._headerInterceptor,
  });

  static late HttpProvider instance;

  static void init() {
    final config = EnvironmentConfig.current;
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );

    final headerInterceptor = HeaderInterrepter(config);

    dio.interceptors.add(headerInterceptor);

    instance = HttpProvider._(
      dio: dio,
      config: config,
      headerInterceptor: headerInterceptor,
    );
  }

  static Future<void> warmupNetwork() async {
    try {
      await instance._dio.get<dynamic>(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
          validateStatus: (_) => true,
          extra: const {'skipToken': true},
        ),
      );
    } on DioException {
      return;
    } catch (_) {
      return;
    }
  }

  EnvironmentConfig get config => _config;

  /// 恢复本地登录态到请求头，避免启动或页面分流时重复写入本地存储。
  void restoreToken(String? token) {
    _headerInterceptor.setToken(token);
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
      final currentUri = GoRouter.of(
        context,
      ).routeInformationProvider.value.uri;
      if (currentUri.toString() != AppRoutePaths.login) {
        context.go(AppRoutePaths.login);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isRedirectingToLogin = false;
    });
  }

  bool _isAuthFailure({int? bizCode, int? statusCode, String? message}) {
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

      final responseData = _decryptResponseDataIfNeeded(response.data);

      if (responseData == null) {
        return HttpResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      Map<String, dynamic>? map;

      try {
        final sourceMap = responseData as Map;
        map = {};
        for (final key in sourceMap.keys) {
          map[key.toString()] = sourceMap[key];
        }
      } catch (e) {
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Map conversion error: $e',
          cancelToken: cancelToken,
        );
      }

      try {
        if (map.containsKey('code')) {
          final result = BaseResult.fromJson(map, fromJson);
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
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Parse error: $e',
          cancelToken: cancelToken,
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, cancelToken);
    } catch (e, stack) {
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
      final requestData = _encryptPostDataIfNeeded(data);

      // 使用 dynamic 而不是 T，避免 Dio 自动转换失败
      final response = await _dio.post<dynamic>(
        path,
        data: requestData,
        queryParameters: params,
        cancelToken: cancelToken,
        options: Options(extra: {'skipToken': !includeToken}),
      );

      final responseData = _decryptResponseDataIfNeeded(response.data);

      if (responseData == null) {
        return HttpResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      Map<String, dynamic>? map;

      try {
        // 使用 Map.from 来确保正确转换
        final sourceMap = responseData as Map;
        map = {};
        for (final key in sourceMap.keys) {
          map[key.toString()] = sourceMap[key];
        }
      } catch (e) {
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Map conversion error: $e',
          cancelToken: cancelToken,
        );
      }

      try {
        if (map.containsKey('code')) {
          final result = BaseResult.fromJson(map, fromJson);
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
        return HttpResult.error(
          HttpResultStatus.unKnown,
          'Parse error: $e',
          cancelToken: cancelToken,
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, cancelToken);
    } catch (e, stack) {
      return HttpResult.error(
        HttpResultStatus.unKnown,
        e.toString(),
        cancelToken: cancelToken,
      );
    }
  }

  /// 按配置统一加密 POST 请求体，上传表单和空请求体保持原样。
  dynamic _encryptPostDataIfNeeded(dynamic data) {
    if (!_shouldEncryptPostData(data)) {
      return data;
    }

    return RequestSecurityUtil.encryptRequestBody(data);
  }

  /// 解密后端返回的整体响应体，再交给统一解析流程处理。
  dynamic _decryptResponseDataIfNeeded(dynamic data) {
    return RequestSecurityUtil.decryptResponseBody(data);
  }

  bool _shouldEncryptPostData(dynamic data) {
    if (_config.disableEncBody.toLowerCase() == 'true') {
      return true;
    }
    if (data == null || data is FormData) {
      return false;
    }
    if (data is Map && RequestSecurityUtil.isEncryptedTransportBody(data)) {
      return false;
    }
    return true;
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

      final responseData = _decryptResponseDataIfNeeded(response.data);

      if (responseData == null) {
        return HttpListResult.error(
          HttpResultStatus.error,
          'Response data is null',
          cancelToken: cancelToken,
        );
      }

      // List
      if (responseData is List) {
        final list = responseData
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();

        return HttpListResult.success(
          list,
          total: list.length,
          cancelToken: cancelToken,
        );
      }

      final result = ListResult.fromJson(
        responseData as Map<String, dynamic>,
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
        final respData = _decryptResponseDataIfNeeded(e.response?.data);
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
        final respData = _decryptResponseDataIfNeeded(e.response?.data);
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
