import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/core/utils/request_security_util.dart';
import 'package:easy_moni/utils/image_compress_tool.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ocrVerificationProvider = Provider<OcrVerificationApi>((ref) {
  return OcrVerificationApi();
});

class OcrVerificationApi {
  Future<HttpResult<OcrVerificationResp>> call({
    required Uint8List bytes,
    required String filename,
    required String type,
  }) async {
    final token = HttpProvider.instance.token;
    if (token == null || token.isEmpty) {
      return HttpResult.error(HttpResultStatus.serverError, 'token missing');
    }

    final config = HttpProvider.instance.config;
    final requestUrl = config.resolveApiPath(ApiConstants.ocrVerification);

    AppLogger.debug(
      '开始调用 OCR 接口: url=$requestUrl, filename=$filename, bytes=${bytes.length}, type=$type',
    );

    try {
      final dio = Dio();
      final uploadBytes = await ImageCompressTool.compressForUpload(bytes);

      // OCR 图片上传前统一压缩，降低接口传输体积并保留失败兜底。
      final formData = FormData.fromMap({
        'multipartFile': MultipartFile.fromBytes(
          uploadBytes,
          filename: filename,
        ),
      });

      final response = await dio.post<dynamic>(
        requestUrl,
        data: formData,
        queryParameters: {'type': type},
        options: Options(headers: config.commonHeaders(token: token)),
      );

      AppLogger.debug(
        'OCR 原始响应: status=${response.statusCode}, data=${response.data}, '
        'originalBytes=${bytes.length}, uploadBytes=${uploadBytes.length}',
      );

      // 解密
      final decryptedData = RequestSecurityUtil.decryptResponseBody(
        response.data,
      );
      AppLogger.debug(
        'OCR 解密响应: type=${decryptedData.runtimeType}, data=$decryptedData',
      );

      final map = _normalizeResponseMap(decryptedData);
      if (map == null) {
        return HttpResult.error(
          HttpResultStatus.serverError,
          AppStrings.identityVerifyOcrFailed,
        );
      }

      final responseData = map['data'];
      final isSuccessCode = map['code'] == 200 || map['code'] == 0;
      if (isSuccessCode && responseData is Map) {
        return HttpResult.success(
          OcrVerificationResp.fromJson(
            Map<String, dynamic>.from(responseData),
          ),
        );
      }

      return HttpResult.error(
        HttpResultStatus.serverError,
        (map['msg'] ?? map['message'] ?? 'ocr failed').toString(),
      );
    } on DioException catch (e) {
      AppLogger.debug(
        'OCR DioException: type=${e.type}, message=${e.message}, status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? 'ocr failed',
      );
    } catch (e) {
      AppLogger.debug('OCR Exception: $e');
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }

  /// 将 OCR 解密后的响应统一整理为 Map，兼容后端直接返回业务对象的情况。
  Map<String, dynamic>? _normalizeResponseMap(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);
    if (map.containsKey('code') || map.containsKey('data')) {
      return map;
    }

    return {'code': 200, 'data': map};
  }
}

class OcrVerificationResp {
  final String? type;
  final String? name;
  final String? idCardNumber;
  final String? firstNames;
  final String? lastName;
  final String? birthday;
  final String? gender;
  final String? url;
  final String? backUrl;
  final int? isSuccess;

  OcrVerificationResp({
    this.type,
    this.name,
    this.idCardNumber,
    this.firstNames,
    this.lastName,
    this.birthday,
    this.gender,
    this.url,
    this.backUrl,
    this.isSuccess,
  });

  factory OcrVerificationResp.fromJson(Map<String, dynamic> json) {
    return OcrVerificationResp(
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      idCardNumber: json['idCardNumber']?.toString(),
      firstNames: json['fatherName']?.toString(),
      lastName: json['name']?.toString(),
      birthday: json['birthday']?.toString(),
      gender: json['gender']?.toString(),
      url: json['url']?.toString(),
      backUrl: json['backUrl']?.toString(),
      isSuccess: json['isSuccess'] as int?,
    );
  }
}
