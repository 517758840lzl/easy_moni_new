import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_resp.freezed.dart';
part 'banner_resp.g.dart';

@freezed
abstract class BannerResp with _$BannerResp {
  const factory BannerResp({
    @Default('') String deeplink,
    @Default(0) int deeplinkType,
    @Default('') String imageUrl,
    @Default('') String title,
  }) = _BannerResp;

  factory BannerResp.fromJson(Map<String, dynamic> json) =>
      _$BannerRespFromJson(json);
}
