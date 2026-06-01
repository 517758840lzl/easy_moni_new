import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';

final ocrVerificationProvider = Provider<OcrVerificationApi>((ref) {
  return OcrVerificationApi();
});

class OcrVerificationApi {
  /// 上传身份证图片并进行OCR验证
  /// [idCardFront] 身份证正面图片二进制数据
  /// [idCardBack] 身份证背面图片二进制数据
  Future<HttpResult<OcrVerificationResp>> call({
    Uint8List? idCardFront,
    Uint8List? idCardBack,
  }) async {
    try {
      final dio = Dio();
      
      // 构建 formData
      final formData = FormData();
      
      if (idCardFront != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(
            idCardFront,
            filename: 'id_card_front.jpg',
          ),
        ));
      }
      
      if (idCardBack != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(
            idCardBack,
            filename: 'id_card_back.jpg',
          ),
        ));
      }

      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.ocrVerification}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'acqChannel': 'GHQU',
            'acqChannelIndex': '0',
            'token': 'eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl90b2tlbl9rZXkiOiJHSFFVOjIzMzUwNDY4NDU2ODphY2EyY2JkZC03MTY5LTRkZjQtODExNC0wNmQ5N2FiOGYyMjQifQ.JUsSwNbEalJqQ4JSZsv1by6NGvg7e8ywATNNRKxzyepghHS4VzRqpLcbOlQjztKM52e-N1yBEWEfvkfc61K5Cg',
          },
        ),
      );

      if (response.data == null) {
        return HttpResult.error(
          HttpResultStatus.error,
          'Response data is null',
        );
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data.containsKey('code')) {
        if (data['code'] == 0 || data['code'] == '0') {
          return HttpResult.success(
            OcrVerificationResp.fromJson(data['data'] ?? {}),
          );
        } else {
          return HttpResult.error(
            HttpResultStatus.serverError,
            data['msg'] ?? data['message'] ?? 'OCR验证失败',
          );
        }
      }
      
      return HttpResult.success(OcrVerificationResp.fromJson(data));
    } on DioException catch (e) {
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? '网络请求失败',
      );
    } catch (e) {
      return HttpResult.error(
        HttpResultStatus.unKnown,
        e.toString(),
      );
    }
  }
}

class OcrVerificationResp {
  final String? name;
  final String? idCardNumber;
  final String? address;
  final String? birthDate;
  final String? gender;
  final String? ethnicity;
  final String? frontImageUrl;
  final String? backImageUrl;
  final bool? isValid;

  OcrVerificationResp({
    this.name,
    this.idCardNumber,
    this.address,
    this.birthDate,
    this.gender,
    this.ethnicity,
    this.frontImageUrl,
    this.backImageUrl,
    this.isValid,
  });

  factory OcrVerificationResp.fromJson(Map<String, dynamic> json) {
    return OcrVerificationResp(
      name: json['name']?.toString(),
      idCardNumber: json['idCardNumber']?.toString(),
      address: json['address']?.toString(),
      birthDate: json['birthDate']?.toString(),
      gender: json['gender']?.toString(),
      ethnicity: json['ethnicity']?.toString(),
      frontImageUrl: json['frontImageUrl']?.toString(),
      backImageUrl: json['backImageUrl']?.toString(),
      isValid: json['isValid'] as bool?,
    );
  }
}
