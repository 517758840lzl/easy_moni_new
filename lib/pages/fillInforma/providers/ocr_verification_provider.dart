import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
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

    try {
      final dio = Dio();
      final uploadBytes = await ImageCompressTool.compressForUpload(bytes);

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

      final decryptedData = RequestSecurityUtil.decryptResponseBody(
        response.data,
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
            uploadBytes: uploadBytes,
          ),
        );
      }

      return HttpResult.error(
        HttpResultStatus.serverError,
        (map['msg'] ?? map['message'] ?? 'ocr failed').toString(),
      );
    } on DioException catch (e) {
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? 'ocr failed',
      );
    } catch (e) {
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }

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
  final String? idCardNumber;
  final String? name;
  final String? fatherName;
  final String? motherName;
  final String? type;
  final String? url;
  final String? backUrl;

  final Uint8List? uploadBytes;
  final int? isSuccess;
  final int? gender;
  final String? birthday;
  final String? documentNumber;

  OcrVerificationResp({
    this.idCardNumber,
    this.name,
    this.fatherName,
    this.motherName,
    this.type,
    this.url,
    this.backUrl,
    this.uploadBytes,
    this.isSuccess,
    this.gender,
    this.birthday,
    this.documentNumber,
  });

  factory OcrVerificationResp.fromJson(
    Map<String, dynamic> json, {
    Uint8List? uploadBytes,
  }) {
    return OcrVerificationResp(
      idCardNumber: json['idCardNumber']?.toString(),
      name: json['name']?.toString(),
      fatherName: json['fatherName']?.toString(),
      motherName: json['motherName']?.toString(),
      type: json['type']?.toString(),
      url: json['url']?.toString(),
      backUrl: json['backUrl']?.toString(),
      uploadBytes: uploadBytes,
      isSuccess: _parseNullableInt(json['isSuccess']),
      gender: _parseNullableInt(json['gender']),
      birthday: json['birthday']?.toString(),
      documentNumber: json['documentNumber']?.toString(),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
