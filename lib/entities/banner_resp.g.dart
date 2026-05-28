// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BannerResp _$BannerRespFromJson(Map<String, dynamic> json) => _BannerResp(
  deeplink: json['deeplink'] as String? ?? '',
  deeplinkType: (json['deeplinkType'] as num?)?.toInt() ?? 0,
  imageUrl: json['imageUrl'] as String? ?? '',
  title: json['title'] as String? ?? '',
);

Map<String, dynamic> _$BannerRespToJson(_BannerResp instance) =>
    <String, dynamic>{
      'deeplink': instance.deeplink,
      'deeplinkType': instance.deeplinkType,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
    };
