import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_moni/core/constants/api_constants.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/pages/loan/models/review_pop_config.dart';

final reviewPopProvider = Provider<ReviewPopApi>((ref) {
  return ReviewPopApi();
});

class ReviewPopApi {
  Future<HttpResult<ReviewPopConfig>> fetchConfig() {
    return HttpProvider.instance.get<ReviewPopConfig>(
      ApiConstants.popconfig,
      fromJson: ReviewPopConfig.fromJson,
    );
  }
}
