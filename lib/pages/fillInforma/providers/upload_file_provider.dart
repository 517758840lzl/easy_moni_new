import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';

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
      final dio = Dio();
      final uploadUrl = Uri.parse(
        ApiConstants.baseUrl,
      ).resolve(ApiConstants.uploadFile).toString();
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        'acqChannel': 'GHPM',
        'acqChannelIndex': '0',
        'disableEncBody': 'false',
        'token': token,
      };

      debugPrint(
        '上传文件开始: url=$uploadUrl, '
        'filename=$filename, bytes=${bytes.length}, headers=$headers',
      );

      final formData = FormData.fromMap({
        'multipartFile': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dio.post<dynamic>(
        uploadUrl,
        data: formData,
        options: Options(headers: headers),
      );

      debugPrint(
        '上传文件响应: status=${response.statusCode}, data=${response.data}',
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
      debugPrint(
        '上传文件 DioException: type=${e.type}, message=${e.message}, '
        'status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      return HttpResult.error(
        HttpResultStatus.serverError,
        e.message ?? 'upload failed',
      );
    } catch (e) {
      debugPrint('上传文件 Exception: $e');
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }
}
