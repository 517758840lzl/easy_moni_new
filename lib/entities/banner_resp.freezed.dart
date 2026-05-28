// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BannerResp {

 String get deeplink; int get deeplinkType; String get imageUrl; String get title;
/// Create a copy of BannerResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerRespCopyWith<BannerResp> get copyWith => _$BannerRespCopyWithImpl<BannerResp>(this as BannerResp, _$identity);

  /// Serializes this BannerResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerResp&&(identical(other.deeplink, deeplink) || other.deeplink == deeplink)&&(identical(other.deeplinkType, deeplinkType) || other.deeplinkType == deeplinkType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deeplink,deeplinkType,imageUrl,title);

@override
String toString() {
  return 'BannerResp(deeplink: $deeplink, deeplinkType: $deeplinkType, imageUrl: $imageUrl, title: $title)';
}


}

/// @nodoc
abstract mixin class $BannerRespCopyWith<$Res>  {
  factory $BannerRespCopyWith(BannerResp value, $Res Function(BannerResp) _then) = _$BannerRespCopyWithImpl;
@useResult
$Res call({
 String deeplink, int deeplinkType, String imageUrl, String title
});




}
/// @nodoc
class _$BannerRespCopyWithImpl<$Res>
    implements $BannerRespCopyWith<$Res> {
  _$BannerRespCopyWithImpl(this._self, this._then);

  final BannerResp _self;
  final $Res Function(BannerResp) _then;

/// Create a copy of BannerResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deeplink = null,Object? deeplinkType = null,Object? imageUrl = null,Object? title = null,}) {
  return _then(_self.copyWith(
deeplink: null == deeplink ? _self.deeplink : deeplink // ignore: cast_nullable_to_non_nullable
as String,deeplinkType: null == deeplinkType ? _self.deeplinkType : deeplinkType // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BannerResp].
extension BannerRespPatterns on BannerResp {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerResp() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerResp value)  $default,){
final _that = this;
switch (_that) {
case _BannerResp():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerResp value)?  $default,){
final _that = this;
switch (_that) {
case _BannerResp() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deeplink,  int deeplinkType,  String imageUrl,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerResp() when $default != null:
return $default(_that.deeplink,_that.deeplinkType,_that.imageUrl,_that.title);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deeplink,  int deeplinkType,  String imageUrl,  String title)  $default,) {final _that = this;
switch (_that) {
case _BannerResp():
return $default(_that.deeplink,_that.deeplinkType,_that.imageUrl,_that.title);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deeplink,  int deeplinkType,  String imageUrl,  String title)?  $default,) {final _that = this;
switch (_that) {
case _BannerResp() when $default != null:
return $default(_that.deeplink,_that.deeplinkType,_that.imageUrl,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerResp implements BannerResp {
  const _BannerResp({this.deeplink = '', this.deeplinkType = 0, this.imageUrl = '', this.title = ''});
  factory _BannerResp.fromJson(Map<String, dynamic> json) => _$BannerRespFromJson(json);

@override@JsonKey() final  String deeplink;
@override@JsonKey() final  int deeplinkType;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String title;

/// Create a copy of BannerResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerRespCopyWith<_BannerResp> get copyWith => __$BannerRespCopyWithImpl<_BannerResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerResp&&(identical(other.deeplink, deeplink) || other.deeplink == deeplink)&&(identical(other.deeplinkType, deeplinkType) || other.deeplinkType == deeplinkType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deeplink,deeplinkType,imageUrl,title);

@override
String toString() {
  return 'BannerResp(deeplink: $deeplink, deeplinkType: $deeplinkType, imageUrl: $imageUrl, title: $title)';
}


}

/// @nodoc
abstract mixin class _$BannerRespCopyWith<$Res> implements $BannerRespCopyWith<$Res> {
  factory _$BannerRespCopyWith(_BannerResp value, $Res Function(_BannerResp) _then) = __$BannerRespCopyWithImpl;
@override @useResult
$Res call({
 String deeplink, int deeplinkType, String imageUrl, String title
});




}
/// @nodoc
class __$BannerRespCopyWithImpl<$Res>
    implements _$BannerRespCopyWith<$Res> {
  __$BannerRespCopyWithImpl(this._self, this._then);

  final _BannerResp _self;
  final $Res Function(_BannerResp) _then;

/// Create a copy of BannerResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deeplink = null,Object? deeplinkType = null,Object? imageUrl = null,Object? title = null,}) {
  return _then(_BannerResp(
deeplink: null == deeplink ? _self.deeplink : deeplink // ignore: cast_nullable_to_non_nullable
as String,deeplinkType: null == deeplinkType ? _self.deeplinkType : deeplinkType // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
