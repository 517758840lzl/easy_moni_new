import 'dart:convert';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/repay/repay_extension_resp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repayExtensionApiProvider = Provider<RepayExtensionApi>((ref) {
  return RepayExtensionApi();
});

final mockRepayExtensionApiProvider = Provider<MockRepayExtensionApi>((ref) {
  return MockRepayExtensionApi();
});

final repayExtensionProvider = FutureProvider.autoDispose
    .family<RepayExtensionRespData, int?>((ref, installmentId) async {
      if (installmentId == null || installmentId <= 0) {
        throw Exception(AppStrings.repayExtensionNoOrderData);
      }

      // TODO: 联调确认展期详情接口在测试环境稳定后，可切回 mockRepayExtensionApiProvider。
      final result = await ref
          .read(repayExtensionApiProvider)
          .call(installmentId: installmentId);

      if (result.isSuccess && result.data != null) {
        return result.data!;
      }

      throw Exception(result.message ?? AppStrings.repayExtensionLoadFailed);
    });

class RepayExtensionApi {
  /// 获取展期详情，installmentId 为当前申请展期账单的ID。
  Future<HttpResult<RepayExtensionRespData>> call({
    required int installmentId,
  }) async {
    final result = await HttpProvider.instance.post<RepayExtensionRespData>(
      ApiConstants.extension,
      data: {'couponIds': <int>[], 'installmentId': installmentId},
      fromJson: (json) =>
          RepayExtensionRespData.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      return HttpResult.success(result.data!);
    }

    return HttpResult.error(
      HttpResultStatus.serverError,
      result.message ?? AppStrings.repayExtensionLoadFailed,
    );
  }
}

class MockRepayExtensionApi {
  static const String _mockAssetPath =
      'lib/pages/repay/mock/repay_extension.json';

  /// 模拟展期详情接口，从本地 JSON 读取数据并延迟返回，方便页面联调。
  Future<HttpResult<RepayExtensionRespData>> call({
    required int installmentId,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final source = await rootBundle.loadString(_mockAssetPath);
      final map = jsonDecode(source) as Map<String, dynamic>;
      final resp = RepayExtensionResp.fromJson(map);
      final data = resp.data;

      if (resp.code != 200 || data == null) {
        return HttpResult.error(
          HttpResultStatus.serverError,
          resp.msg ?? AppStrings.repayExtensionLoadFailed,
        );
      }

      return HttpResult.success(data);
    } catch (e) {
      return HttpResult.error(HttpResultStatus.unKnown, e.toString());
    }
  }
}
