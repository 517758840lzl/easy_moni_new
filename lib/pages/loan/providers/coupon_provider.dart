import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/entities/coupon_resp.dart';
import 'package:easy_moni/entities/use_coupon_resp/use_coupon_resp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final couponApiProvider = Provider<CouponApi>((ref) {
  return CouponApi();
});

final couponListProvider = FutureProvider.autoDispose
    .family<List<CouponItem>, CouponRequestParams>((ref, params) async {
      final result = await ref.read(couponApiProvider).fetchCoupons(params);

      if (!result.isSuccess || result.data == null) {
        throw result.message ?? AppStrings.couponLoadFailed;
      }

      final couponData = result.data?.data;
      if (couponData?.showCouponCard != 1) {
        return const <CouponItem>[];
      }

      final coupons = couponData?.coupons ?? const <CouponItem>[];
      return coupons.where((coupon) => coupon.isUsable).toList();
    });

final useCouponPostProvider = FutureProvider.autoDispose
    .family<UseCouponRespData, UseCouponRequestParams>((ref, params) async {
      final result = await ref.read(couponApiProvider).useCouponPost(params);

      if (!result.isSuccess || result.data == null) {
        throw result.message ?? AppStrings.couponLoadFailed;
      }

      return result.data!;
    });

final useCouponPreProvider = FutureProvider.autoDispose
    .family<UseCouponRespData, UseCouponRequestParams>((ref, params) async {
      final result = await ref.read(couponApiProvider).useCouponPre(params);

      if (!result.isSuccess || result.data == null) {
        throw result.message ?? AppStrings.couponLoadFailed;
      }

      return result.data!;
    });

class CouponTypes {
  const CouponTypes._();

  static const String pre = 'PRE';
  static const String post = 'POST';
}

class CouponRepaymentTypes {
  const CouponRepaymentTypes._();

  static const int unrestricted = 0;
  static const int fullAmount = 1;
  static const int extension = 2;
}

class CouponStatus {
  const CouponStatus._();

  static const int expired = -1;
  static const int usable = 0;
  static const int used = 1;
  static const int notStarted = 2;
  static const int unavailable = 3;
}

extension CouponItemUsability on CouponItem {
  bool get isUsable => status == CouponStatus.usable;
}

class CouponRequestParams {
  const CouponRequestParams({
    required this.appOrderIds,
    required this.productCodes,
    required this.couponType,
    required this.repaymentType,
  });

  final List<int> appOrderIds;
  final List<String> productCodes;
  final String couponType;
  final int repaymentType;

  Map<String, dynamic> toJson() {
    return {
      'appOrderIds': appOrderIds,
      'couponType': couponType,
      'productCodes': productCodes,
      'repaymentType': repaymentType,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CouponRequestParams &&
            listEquals(other.appOrderIds, appOrderIds) &&
            listEquals(other.productCodes, productCodes) &&
            other.couponType == couponType &&
            other.repaymentType == repaymentType;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(appOrderIds),
      Object.hashAll(productCodes),
      couponType,
      repaymentType,
    );
  }
}

class UseCouponRequestParams {
  const UseCouponRequestParams({
    required this.appOrderIds,
    required this.couponIds,
    required this.productCodes,
  });

  final List<int> appOrderIds;
  final List<int> couponIds;
  final List<String> productCodes;

  Map<String, dynamic> toJson() {
    return {
      'appOrderIds': appOrderIds,
      'couponIds': couponIds,
      'productCodes': productCodes,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UseCouponRequestParams &&
            listEquals(other.appOrderIds, appOrderIds) &&
            listEquals(other.couponIds, couponIds) &&
            listEquals(other.productCodes, productCodes);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(appOrderIds),
      Object.hashAll(couponIds),
      Object.hashAll(productCodes),
    );
  }
}

class CouponApi {
  Future<HttpResult<CouponResp>> fetchCoupons(CouponRequestParams params) {
    return HttpProvider.instance.post<CouponResp>(
      ApiConstants.customerCouponList,
      data: params.toJson(),
      fromJson: (json) => _parseCouponResp(json),
    );
  }

  Future<HttpResult<UseCouponRespData>> useCouponPost(
    UseCouponRequestParams params,
  ) {
    return HttpProvider.instance.post<UseCouponRespData>(
      ApiConstants.useCouponPost,
      data: params.toJson(),
      fromJson: (json) => _parseUseCouponData(json),
    );
  }

  Future<HttpResult<UseCouponRespData>> useCouponPre(
    UseCouponRequestParams params,
  ) {
    return HttpProvider.instance.post<UseCouponRespData>(
      ApiConstants.useCouponPre,
      data: params.toJson(),
      fromJson: (json) => _parseUseCouponData(json),
    );
  }

  CouponResp _parseCouponResp(dynamic json) {
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      return CouponResp.fromJson(json);
    }
    if (json is Map) {
      return CouponResp.fromJson({'data': Map<String, dynamic>.from(json)});
    }
    return const CouponResp();
  }

  UseCouponRespData _parseUseCouponData(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UseCouponRespData.fromJson(json);
    }
    if (json is Map) {
      return UseCouponRespData.fromJson(Map<String, dynamic>.from(json));
    }
    return const UseCouponRespData();
  }
}
