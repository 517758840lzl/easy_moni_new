import 'dart:convert';

import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';

/// 路由 extra 编解码器，确保复杂入参在系统恢复和浏览器历史中不丢失。
class AppRouteExtraCodec extends Codec<Object?, Object?> {
  const AppRouteExtraCodec();

  @override
  Converter<Object?, Object?> get decoder => const _AppRouteExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _AppRouteExtraEncoder();
}

class _AppRouteExtraEncoder extends Converter<Object?, Object?> {
  const _AppRouteExtraEncoder();

  @override
  Object? convert(Object? input) {
    return switch (input) {
      null => null,
      PaymentRequestParams() => <Object?>[
        'PaymentRequestParams',
        input.toJson(),
      ],
      RepayExtensionRequestData() => <Object?>[
        'RepayExtensionRequestData',
        input.toJson(),
      ],
      LoanOrderDetailData() => <Object?>['LoanOrderDetailData', input.toJson()],
      _ when _isJsonSafe(input) => input,
      // ponytail: 未登记的历史 extra 不参与恢复；保持旧行为，无法序列化时丢弃。
      _ => null,
    };
  }
}

class _AppRouteExtraDecoder extends Converter<Object?, Object?> {
  const _AppRouteExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input is! List<Object?> || input.isEmpty) return input;

    final tag = input.first;
    final payload = input.length > 1 ? input[1] : null;
    if (payload is! Map) return input;

    final json = Map<String, dynamic>.from(payload);
    return switch (tag) {
      'PaymentRequestParams' => PaymentRequestParams.fromJson(json),
      'RepayExtensionRequestData' => RepayExtensionRequestData.fromJson(json),
      'LoanOrderDetailData' => LoanOrderDetailData.fromJson(json),
      _ => input,
    };
  }
}

bool _isJsonSafe(Object? value) {
  return switch (value) {
    null || String() || num() || bool() => true,
    List() => value.every(_isJsonSafe),
    Map() =>
      value.keys.every((key) => key is String) &&
          value.values.every(_isJsonSafe),
    _ => false,
  };
}
