import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/entities/banner_resp.dart';

final bannerListProvider = FutureProvider<HttpListResult<BannerResp>>((
  ref,
) async {
  final result = await HttpProvider.instance.getList<BannerResp>(
    ApiConstants.bannerList,
    fromJson: (json) => BannerResp.fromJson(json as Map<String, dynamic>),
  );
  return result;
});
