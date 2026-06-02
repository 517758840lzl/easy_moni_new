import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';

final ocrVerificationProvider = Provider<OcrVerificationApi>((ref) {
  return OcrVerificationApi();
});

class OcrVerificationApi {
  Future<HttpResult<OcrVerificationResp>> call({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = HttpProvider.instance.token;
    if (token == null || token.isEmpty) {
      return HttpResult.error(HttpResultStatus.serverError, 'token missing');
    }

    final requestUrl = Uri.parse(
      ApiConstants.baseUrl,
    ).resolve(ApiConstants.ocrVerification).toString();

    debugPrint(
      '开始调用 OCR 接口: url=$requestUrl, filename=$filename, bytes=${bytes.length}',
    );

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'multipartFile': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dio.post<dynamic>(
        requestUrl,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'acqChannel': 'GHQU',
            'acqChannelIndex': '0',
            'disableEncBody': 'false',
            'token': token,
          },
        ),
      );

      debugPrint(
        'OCR 原始响应: status=${response.statusCode}, data=${response.data}',
      );

      final map = Map<String, dynamic>.from(response.data as Map);
      if ((map['code'] == 200 || map['code'] == 0) && map['data'] is Map) {
        return HttpResult.success(
          OcrVerificationResp.fromJson(
            Map<String, dynamic>.from(map['data'] as Map),
          ),
        );
      }

      return HttpResult.error(
        HttpResultStatus.serverError,
        (map['msg'] ?? map['message'] ?? 'ocr failed').toString(),
      );
    } on DioException catch (e) {
      debugPrint(
        'OCR DioException: type=${e.type}, message=${e.message}, status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? 'ocr failed',
      );
    } catch (e) {
      debugPrint('OCR Exception: $e');
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
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
