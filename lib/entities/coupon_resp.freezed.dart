// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CouponResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'data') CouponData? get data;@JsonKey(name: 'msg') String? get msg;
/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponRespCopyWith<CouponResp> get copyWith => _$CouponRespCopyWithImpl<CouponResp>(this as CouponResp, _$identity);

  /// Serializes this CouponResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CouponResp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CouponResp&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.msg, _this.msg) || other.msg == _this.msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CouponResp;
  return Object.hash(runtimeType,_this.code,_this.data,_this.msg);
}

@override
String toString() {
  final _this = this as CouponResp;
  return 'CouponResp(code: ${_this.code}, data: ${_this.data}, msg: ${_this.msg})';
}


}

/// @nodoc
abstract mixin class $CouponRespCopyWith<$Res>  {
  factory $CouponRespCopyWith(CouponResp value, $Res Function(CouponResp) _then) = _$CouponRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') CouponData? data,@JsonKey(name: 'msg') String? msg
});


$CouponDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$CouponRespCopyWithImpl<$Res>
    implements $CouponRespCopyWith<$Res> {
  _$CouponRespCopyWithImpl(this._self, this._then);

  final CouponResp _self;
  final $Res Function(CouponResp) _then;

/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(CouponResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CouponData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $CouponDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CouponResp].
extension CouponRespPatterns on CouponResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CouponResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CouponResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CouponResp value)  $default,){
final _that = this;
switch (_that) {
case _CouponResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CouponResp value)?  $default,){
final _that = this;
switch (_that) {
case _CouponResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  CouponData? data, @JsonKey(name: 'msg')  String? msg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CouponResp() when $default != null:
return $default(_that.code,_that.data,_that.msg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  CouponData? data, @JsonKey(name: 'msg')  String? msg)  $default,) {final _that = this;
switch (_that) {
case _CouponResp():
return $default(_that.code,_that.data,_that.msg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  CouponData? data, @JsonKey(name: 'msg')  String? msg)?  $default,) {final _that = this;
switch (_that) {
case _CouponResp() when $default != null:
return $default(_that.code,_that.data,_that.msg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CouponResp implements CouponResp {
  const _CouponResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'data') this.data, @JsonKey(name: 'msg') this.msg});
  factory _CouponResp.fromJson(Map<String, dynamic> json) => _$CouponRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'data') final  CouponData? data;
@override@JsonKey(name: 'msg') final  String? msg;

/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponRespCopyWith<_CouponResp> get copyWith => __$CouponRespCopyWithImpl<_CouponResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponRespToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CouponResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,data,msg);
}

@override
String toString() {
    return 'CouponResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class _$CouponRespCopyWith<$Res> implements $CouponRespCopyWith<$Res> {
  factory _$CouponRespCopyWith(_CouponResp value, $Res Function(_CouponResp) _then) = __$CouponRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') CouponData? data,@JsonKey(name: 'msg') String? msg
});


@override $CouponDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$CouponRespCopyWithImpl<$Res>
    implements _$CouponRespCopyWith<$Res> {
  __$CouponRespCopyWithImpl(this._self, this._then);

  final _CouponResp _self;
  final $Res Function(_CouponResp) _then;

/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_CouponResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CouponData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CouponResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $CouponDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$CouponData {

@JsonKey(name: 'coupons') List<CouponItem>? get coupons;@JsonKey(name: 'showCouponCard') int? get showCouponCard;
/// Create a copy of CouponData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponDataCopyWith<CouponData> get copyWith => _$CouponDataCopyWithImpl<CouponData>(this as CouponData, _$identity);

  /// Serializes this CouponData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CouponData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CouponData&&const DeepCollectionEquality().equals(other.coupons, _this.coupons)&&(identical(other.showCouponCard, _this.showCouponCard) || other.showCouponCard == _this.showCouponCard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CouponData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.coupons),_this.showCouponCard);
}

@override
String toString() {
  final _this = this as CouponData;
  return 'CouponData(coupons: ${_this.coupons}, showCouponCard: ${_this.showCouponCard})';
}


}

/// @nodoc
abstract mixin class $CouponDataCopyWith<$Res>  {
  factory $CouponDataCopyWith(CouponData value, $Res Function(CouponData) _then) = _$CouponDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'coupons') List<CouponItem>? coupons,@JsonKey(name: 'showCouponCard') int? showCouponCard
});




}
/// @nodoc
class _$CouponDataCopyWithImpl<$Res>
    implements $CouponDataCopyWith<$Res> {
  _$CouponDataCopyWithImpl(this._self, this._then);

  final CouponData _self;
  final $Res Function(CouponData) _then;

/// Create a copy of CouponData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coupons = freezed,Object? showCouponCard = freezed,}) {
  return _then(CouponData(
coupons: freezed == coupons ? _self.coupons : coupons // ignore: cast_nullable_to_non_nullable
as List<CouponItem>?,showCouponCard: freezed == showCouponCard ? _self.showCouponCard : showCouponCard // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CouponData].
extension CouponDataPatterns on CouponData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CouponData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CouponData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CouponData value)  $default,){
final _that = this;
switch (_that) {
case _CouponData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CouponData value)?  $default,){
final _that = this;
switch (_that) {
case _CouponData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'coupons')  List<CouponItem>? coupons, @JsonKey(name: 'showCouponCard')  int? showCouponCard)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CouponData() when $default != null:
return $default(_that.coupons,_that.showCouponCard);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'coupons')  List<CouponItem>? coupons, @JsonKey(name: 'showCouponCard')  int? showCouponCard)  $default,) {final _that = this;
switch (_that) {
case _CouponData():
return $default(_that.coupons,_that.showCouponCard);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'coupons')  List<CouponItem>? coupons, @JsonKey(name: 'showCouponCard')  int? showCouponCard)?  $default,) {final _that = this;
switch (_that) {
case _CouponData() when $default != null:
return $default(_that.coupons,_that.showCouponCard);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CouponData implements CouponData {
  const _CouponData({@JsonKey(name: 'coupons')  List<CouponItem>? coupons, @JsonKey(name: 'showCouponCard') this.showCouponCard}): _coupons = coupons;
  factory _CouponData.fromJson(Map<String, dynamic> json) => _$CouponDataFromJson(json);

 final  List<CouponItem>? _coupons;
@override@JsonKey(name: 'coupons') List<CouponItem>? get coupons {
  final value = _coupons;
  if (value == null) return null;
  if (_coupons is EqualUnmodifiableListView) return _coupons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'showCouponCard') final  int? showCouponCard;

/// Create a copy of CouponData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponDataCopyWith<_CouponData> get copyWith => __$CouponDataCopyWithImpl<_CouponData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CouponData&&const DeepCollectionEquality().equals(other.coupons, _coupons)&&(identical(other.showCouponCard, showCouponCard) || other.showCouponCard == showCouponCard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_coupons),showCouponCard);
}

@override
String toString() {
    return 'CouponData(coupons: $coupons, showCouponCard: $showCouponCard)';
}


}

/// @nodoc
abstract mixin class _$CouponDataCopyWith<$Res> implements $CouponDataCopyWith<$Res> {
  factory _$CouponDataCopyWith(_CouponData value, $Res Function(_CouponData) _then) = __$CouponDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'coupons') List<CouponItem>? coupons,@JsonKey(name: 'showCouponCard') int? showCouponCard
});




}
/// @nodoc
class __$CouponDataCopyWithImpl<$Res>
    implements _$CouponDataCopyWith<$Res> {
  __$CouponDataCopyWithImpl(this._self, this._then);

  final _CouponData _self;
  final $Res Function(_CouponData) _then;

/// Create a copy of CouponData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coupons = freezed,Object? showCouponCard = freezed,}) {
  return _then(_CouponData(
coupons: freezed == coupons ? _self._coupons : coupons // ignore: cast_nullable_to_non_nullable
as List<CouponItem>?,showCouponCard: freezed == showCouponCard ? _self.showCouponCard : showCouponCard // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$CouponItem {

@JsonKey(name: 'couponId') int? get couponId;@JsonKey(name: 'description') String? get description;@JsonKey(name: 'discountType') int? get discountType;@JsonKey(name: 'discountValue') num? get discountValue;@JsonKey(name: 'maxDiscountValue') num? get maxDiscountValue;@JsonKey(name: 'minDiscountValue') num? get minDiscountValue;@JsonKey(name: 'repaymentType') int? get repaymentType;@JsonKey(name: 'status') int? get status;@JsonKey(name: 'summary') String? get summary;@JsonKey(name: 'title') String? get title;@JsonKey(name: 'type') String? get type;@JsonKey(name: 'validFrom') int? get validFrom;@JsonKey(name: 'validTo') int? get validTo;
/// Create a copy of CouponItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponItemCopyWith<CouponItem> get copyWith => _$CouponItemCopyWithImpl<CouponItem>(this as CouponItem, _$identity);

  /// Serializes this CouponItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CouponItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CouponItem&&(identical(other.couponId, _this.couponId) || other.couponId == _this.couponId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.discountType, _this.discountType) || other.discountType == _this.discountType)&&(identical(other.discountValue, _this.discountValue) || other.discountValue == _this.discountValue)&&(identical(other.maxDiscountValue, _this.maxDiscountValue) || other.maxDiscountValue == _this.maxDiscountValue)&&(identical(other.minDiscountValue, _this.minDiscountValue) || other.minDiscountValue == _this.minDiscountValue)&&(identical(other.repaymentType, _this.repaymentType) || other.repaymentType == _this.repaymentType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CouponItem;
  return Object.hash(runtimeType,_this.couponId,_this.description,_this.discountType,_this.discountValue,_this.maxDiscountValue,_this.minDiscountValue,_this.repaymentType,_this.status,_this.summary,_this.title,_this.type,_this.validFrom,_this.validTo);
}

@override
String toString() {
  final _this = this as CouponItem;
  return 'CouponItem(couponId: ${_this.couponId}, description: ${_this.description}, discountType: ${_this.discountType}, discountValue: ${_this.discountValue}, maxDiscountValue: ${_this.maxDiscountValue}, minDiscountValue: ${_this.minDiscountValue}, repaymentType: ${_this.repaymentType}, status: ${_this.status}, summary: ${_this.summary}, title: ${_this.title}, type: ${_this.type}, validFrom: ${_this.validFrom}, validTo: ${_this.validTo})';
}


}

/// @nodoc
abstract mixin class $CouponItemCopyWith<$Res>  {
  factory $CouponItemCopyWith(CouponItem value, $Res Function(CouponItem) _then) = _$CouponItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'couponId') int? couponId,@JsonKey(name: 'description') String? description,@JsonKey(name: 'discountType') int? discountType,@JsonKey(name: 'discountValue') num? discountValue,@JsonKey(name: 'maxDiscountValue') num? maxDiscountValue,@JsonKey(name: 'minDiscountValue') num? minDiscountValue,@JsonKey(name: 'repaymentType') int? repaymentType,@JsonKey(name: 'status') int? status,@JsonKey(name: 'summary') String? summary,@JsonKey(name: 'title') String? title,@JsonKey(name: 'type') String? type,@JsonKey(name: 'validFrom') int? validFrom,@JsonKey(name: 'validTo') int? validTo
});




}
/// @nodoc
class _$CouponItemCopyWithImpl<$Res>
    implements $CouponItemCopyWith<$Res> {
  _$CouponItemCopyWithImpl(this._self, this._then);

  final CouponItem _self;
  final $Res Function(CouponItem) _then;

/// Create a copy of CouponItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? couponId = freezed,Object? description = freezed,Object? discountType = freezed,Object? discountValue = freezed,Object? maxDiscountValue = freezed,Object? minDiscountValue = freezed,Object? repaymentType = freezed,Object? status = freezed,Object? summary = freezed,Object? title = freezed,Object? type = freezed,Object? validFrom = freezed,Object? validTo = freezed,}) {
  return _then(CouponItem(
couponId: freezed == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as int?,discountValue: freezed == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as num?,maxDiscountValue: freezed == maxDiscountValue ? _self.maxDiscountValue : maxDiscountValue // ignore: cast_nullable_to_non_nullable
as num?,minDiscountValue: freezed == minDiscountValue ? _self.minDiscountValue : minDiscountValue // ignore: cast_nullable_to_non_nullable
as num?,repaymentType: freezed == repaymentType ? _self.repaymentType : repaymentType // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as int?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CouponItem].
extension CouponItemPatterns on CouponItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CouponItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CouponItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CouponItem value)  $default,){
final _that = this;
switch (_that) {
case _CouponItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CouponItem value)?  $default,){
final _that = this;
switch (_that) {
case _CouponItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'couponId')  int? couponId, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'discountType')  int? discountType, @JsonKey(name: 'discountValue')  num? discountValue, @JsonKey(name: 'maxDiscountValue')  num? maxDiscountValue, @JsonKey(name: 'minDiscountValue')  num? minDiscountValue, @JsonKey(name: 'repaymentType')  int? repaymentType, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'summary')  String? summary, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'validFrom')  int? validFrom, @JsonKey(name: 'validTo')  int? validTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CouponItem() when $default != null:
return $default(_that.couponId,_that.description,_that.discountType,_that.discountValue,_that.maxDiscountValue,_that.minDiscountValue,_that.repaymentType,_that.status,_that.summary,_that.title,_that.type,_that.validFrom,_that.validTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'couponId')  int? couponId, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'discountType')  int? discountType, @JsonKey(name: 'discountValue')  num? discountValue, @JsonKey(name: 'maxDiscountValue')  num? maxDiscountValue, @JsonKey(name: 'minDiscountValue')  num? minDiscountValue, @JsonKey(name: 'repaymentType')  int? repaymentType, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'summary')  String? summary, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'validFrom')  int? validFrom, @JsonKey(name: 'validTo')  int? validTo)  $default,) {final _that = this;
switch (_that) {
case _CouponItem():
return $default(_that.couponId,_that.description,_that.discountType,_that.discountValue,_that.maxDiscountValue,_that.minDiscountValue,_that.repaymentType,_that.status,_that.summary,_that.title,_that.type,_that.validFrom,_that.validTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'couponId')  int? couponId, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'discountType')  int? discountType, @JsonKey(name: 'discountValue')  num? discountValue, @JsonKey(name: 'maxDiscountValue')  num? maxDiscountValue, @JsonKey(name: 'minDiscountValue')  num? minDiscountValue, @JsonKey(name: 'repaymentType')  int? repaymentType, @JsonKey(name: 'status')  int? status, @JsonKey(name: 'summary')  String? summary, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'type')  String? type, @JsonKey(name: 'validFrom')  int? validFrom, @JsonKey(name: 'validTo')  int? validTo)?  $default,) {final _that = this;
switch (_that) {
case _CouponItem() when $default != null:
return $default(_that.couponId,_that.description,_that.discountType,_that.discountValue,_that.maxDiscountValue,_that.minDiscountValue,_that.repaymentType,_that.status,_that.summary,_that.title,_that.type,_that.validFrom,_that.validTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CouponItem implements CouponItem {
  const _CouponItem({@JsonKey(name: 'couponId') this.couponId, @JsonKey(name: 'description') this.description, @JsonKey(name: 'discountType') this.discountType, @JsonKey(name: 'discountValue') this.discountValue, @JsonKey(name: 'maxDiscountValue') this.maxDiscountValue, @JsonKey(name: 'minDiscountValue') this.minDiscountValue, @JsonKey(name: 'repaymentType') this.repaymentType, @JsonKey(name: 'status') this.status, @JsonKey(name: 'summary') this.summary, @JsonKey(name: 'title') this.title, @JsonKey(name: 'type') this.type, @JsonKey(name: 'validFrom') this.validFrom, @JsonKey(name: 'validTo') this.validTo});
  factory _CouponItem.fromJson(Map<String, dynamic> json) => _$CouponItemFromJson(json);

@override@JsonKey(name: 'couponId') final  int? couponId;
@override@JsonKey(name: 'description') final  String? description;
@override@JsonKey(name: 'discountType') final  int? discountType;
@override@JsonKey(name: 'discountValue') final  num? discountValue;
@override@JsonKey(name: 'maxDiscountValue') final  num? maxDiscountValue;
@override@JsonKey(name: 'minDiscountValue') final  num? minDiscountValue;
@override@JsonKey(name: 'repaymentType') final  int? repaymentType;
@override@JsonKey(name: 'status') final  int? status;
@override@JsonKey(name: 'summary') final  String? summary;
@override@JsonKey(name: 'title') final  String? title;
@override@JsonKey(name: 'type') final  String? type;
@override@JsonKey(name: 'validFrom') final  int? validFrom;
@override@JsonKey(name: 'validTo') final  int? validTo;

/// Create a copy of CouponItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponItemCopyWith<_CouponItem> get copyWith => __$CouponItemCopyWithImpl<_CouponItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CouponItem&&(identical(other.couponId, couponId) || other.couponId == couponId)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.maxDiscountValue, maxDiscountValue) || other.maxDiscountValue == maxDiscountValue)&&(identical(other.minDiscountValue, minDiscountValue) || other.minDiscountValue == minDiscountValue)&&(identical(other.repaymentType, repaymentType) || other.repaymentType == repaymentType)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validTo, validTo) || other.validTo == validTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,couponId,description,discountType,discountValue,maxDiscountValue,minDiscountValue,repaymentType,status,summary,title,type,validFrom,validTo);
}

@override
String toString() {
    return 'CouponItem(couponId: $couponId, description: $description, discountType: $discountType, discountValue: $discountValue, maxDiscountValue: $maxDiscountValue, minDiscountValue: $minDiscountValue, repaymentType: $repaymentType, status: $status, summary: $summary, title: $title, type: $type, validFrom: $validFrom, validTo: $validTo)';
}


}

/// @nodoc
abstract mixin class _$CouponItemCopyWith<$Res> implements $CouponItemCopyWith<$Res> {
  factory _$CouponItemCopyWith(_CouponItem value, $Res Function(_CouponItem) _then) = __$CouponItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'couponId') int? couponId,@JsonKey(name: 'description') String? description,@JsonKey(name: 'discountType') int? discountType,@JsonKey(name: 'discountValue') num? discountValue,@JsonKey(name: 'maxDiscountValue') num? maxDiscountValue,@JsonKey(name: 'minDiscountValue') num? minDiscountValue,@JsonKey(name: 'repaymentType') int? repaymentType,@JsonKey(name: 'status') int? status,@JsonKey(name: 'summary') String? summary,@JsonKey(name: 'title') String? title,@JsonKey(name: 'type') String? type,@JsonKey(name: 'validFrom') int? validFrom,@JsonKey(name: 'validTo') int? validTo
});




}
/// @nodoc
class __$CouponItemCopyWithImpl<$Res>
    implements _$CouponItemCopyWith<$Res> {
  __$CouponItemCopyWithImpl(this._self, this._then);

  final _CouponItem _self;
  final $Res Function(_CouponItem) _then;

/// Create a copy of CouponItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? couponId = freezed,Object? description = freezed,Object? discountType = freezed,Object? discountValue = freezed,Object? maxDiscountValue = freezed,Object? minDiscountValue = freezed,Object? repaymentType = freezed,Object? status = freezed,Object? summary = freezed,Object? title = freezed,Object? type = freezed,Object? validFrom = freezed,Object? validTo = freezed,}) {
  return _then(_CouponItem(
couponId: freezed == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as int?,discountValue: freezed == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as num?,maxDiscountValue: freezed == maxDiscountValue ? _self.maxDiscountValue : maxDiscountValue // ignore: cast_nullable_to_non_nullable
as num?,minDiscountValue: freezed == minDiscountValue ? _self.minDiscountValue : minDiscountValue // ignore: cast_nullable_to_non_nullable
as num?,repaymentType: freezed == repaymentType ? _self.repaymentType : repaymentType // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as int?,validTo: freezed == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
