import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/utils/image_compress_tool.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadFileProvider = Provider<UploadFileApi>((ref) {
  return UploadFileApi();
});

class UploadFileApi {
  Future<HttpResult<String>> call({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = HttpProvider.instance.token;
    if (token == null || token.isEmpty) {
      return HttpResult.error(HttpResultStatus.serverError, 'token missing');
    }

    try {
      final config = HttpProvider.instance.config;
      final dio = Dio();
      final uploadUrl = config.resolveApiPath(ApiConstants.uploadFile);
      final headers = config.commonHeaders(token: token);
      final uploadBytes = await ImageCompressTool.compressForUpload(bytes);

      final formData = FormData.fromMap({
        'multipartFile': MultipartFile.fromBytes(
          uploadBytes,
          filename: filename,
        ),
      });

      final response = await dio.post<dynamic>(
        uploadUrl,
        data: formData,
        options: Options(headers: headers),
      );

      final map = Map<String, dynamic>.from(response.data as Map);
      if ((map['code'] == 200 || map['code'] == 0) &&
          map['data'] is Map &&
          map['data']['url'] != null) {
        return HttpResult.success(map['data']['url'].toString());
      }

      return HttpResult.error(
        HttpResultStatus.serverError,
        (map['msg'] ?? map['message'] ?? 'upload failed').toString(),
      );
    } on DioException catch (e) {
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? 'upload failed',
      );
    } catch (e) {
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }
}
