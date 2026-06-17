// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repay_extension_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepayExtensionResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'msg') String? get msg;@JsonKey(name: 'data') RepayExtensionRespData? get data;
/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayExtensionRespCopyWith<RepayExtensionResp> get copyWith => _$RepayExtensionRespCopyWithImpl<RepayExtensionResp>(this as RepayExtensionResp, _$identity);

  /// Serializes this RepayExtensionResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayExtensionResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'RepayExtensionResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class $RepayExtensionRespCopyWith<$Res>  {
  factory $RepayExtensionRespCopyWith(RepayExtensionResp value, $Res Function(RepayExtensionResp) _then) = _$RepayExtensionRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') RepayExtensionRespData? data
});


$RepayExtensionRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$RepayExtensionRespCopyWithImpl<$Res>
    implements $RepayExtensionRespCopyWith<$Res> {
  _$RepayExtensionRespCopyWithImpl(this._self, this._then);

  final RepayExtensionResp _self;
  final $Res Function(RepayExtensionResp) _then;

/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RepayExtensionRespData?,
  ));
}
/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepayExtensionRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $RepayExtensionRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [RepayExtensionResp].
extension RepayExtensionRespPatterns on RepayExtensionResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayExtensionResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayExtensionResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayExtensionResp value)  $default,){
final _that = this;
switch (_that) {
case _RepayExtensionResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayExtensionResp value)?  $default,){
final _that = this;
switch (_that) {
case _RepayExtensionResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayExtensionRespData? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayExtensionResp() when $default != null:
return $default(_that.code,_that.msg,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayExtensionRespData? data)  $default,) {final _that = this;
switch (_that) {
case _RepayExtensionResp():
return $default(_that.code,_that.msg,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayExtensionRespData? data)?  $default,) {final _that = this;
switch (_that) {
case _RepayExtensionResp() when $default != null:
return $default(_that.code,_that.msg,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayExtensionResp implements RepayExtensionResp {
  const _RepayExtensionResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'msg') this.msg, @JsonKey(name: 'data') this.data});
  factory _RepayExtensionResp.fromJson(Map<String, dynamic> json) => _$RepayExtensionRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'msg') final  String? msg;
@override@JsonKey(name: 'data') final  RepayExtensionRespData? data;

/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayExtensionRespCopyWith<_RepayExtensionResp> get copyWith => __$RepayExtensionRespCopyWithImpl<_RepayExtensionResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayExtensionRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayExtensionResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'RepayExtensionResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class _$RepayExtensionRespCopyWith<$Res> implements $RepayExtensionRespCopyWith<$Res> {
  factory _$RepayExtensionRespCopyWith(_RepayExtensionResp value, $Res Function(_RepayExtensionResp) _then) = __$RepayExtensionRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') RepayExtensionRespData? data
});


@override $RepayExtensionRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$RepayExtensionRespCopyWithImpl<$Res>
    implements _$RepayExtensionRespCopyWith<$Res> {
  __$RepayExtensionRespCopyWithImpl(this._self, this._then);

  final _RepayExtensionResp _self;
  final $Res Function(_RepayExtensionResp) _then;

/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_RepayExtensionResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RepayExtensionRespData?,
  ));
}

/// Create a copy of RepayExtensionResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepayExtensionRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $RepayExtensionRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$RepayExtensionRespData {

@JsonKey(name: 'extensionFee') num? get extensionFee;@JsonKey(name: 'newExtensionFee') num? get newExtensionFee;@JsonKey(name: 'extensionWaivedAmount') num? get extensionWaivedAmount;@JsonKey(name: 'extensionRepaymentDate') String? get extensionRepaymentDate;@JsonKey(name: 'totalSureRepayAmounts') num? get totalSureRepayAmounts;@JsonKey(name: 'remainingDay') int? get remainingDay;
/// Create a copy of RepayExtensionRespData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayExtensionRespDataCopyWith<RepayExtensionRespData> get copyWith => _$RepayExtensionRespDataCopyWithImpl<RepayExtensionRespData>(this as RepayExtensionRespData, _$identity);

  /// Serializes this RepayExtensionRespData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayExtensionRespData&&(identical(other.extensionFee, extensionFee) || other.extensionFee == extensionFee)&&(identical(other.newExtensionFee, newExtensionFee) || other.newExtensionFee == newExtensionFee)&&(identical(other.extensionWaivedAmount, extensionWaivedAmount) || other.extensionWaivedAmount == extensionWaivedAmount)&&(identical(other.extensionRepaymentDate, extensionRepaymentDate) || other.extensionRepaymentDate == extensionRepaymentDate)&&(identical(other.totalSureRepayAmounts, totalSureRepayAmounts) || other.totalSureRepayAmounts == totalSureRepayAmounts)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,extensionFee,newExtensionFee,extensionWaivedAmount,extensionRepaymentDate,totalSureRepayAmounts,remainingDay);

@override
String toString() {
  return 'RepayExtensionRespData(extensionFee: $extensionFee, newExtensionFee: $newExtensionFee, extensionWaivedAmount: $extensionWaivedAmount, extensionRepaymentDate: $extensionRepaymentDate, totalSureRepayAmounts: $totalSureRepayAmounts, remainingDay: $remainingDay)';
}


}

/// @nodoc
abstract mixin class $RepayExtensionRespDataCopyWith<$Res>  {
  factory $RepayExtensionRespDataCopyWith(RepayExtensionRespData value, $Res Function(RepayExtensionRespData) _then) = _$RepayExtensionRespDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'extensionFee') num? extensionFee,@JsonKey(name: 'newExtensionFee') num? newExtensionFee,@JsonKey(name: 'extensionWaivedAmount') num? extensionWaivedAmount,@JsonKey(name: 'extensionRepaymentDate') String? extensionRepaymentDate,@JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,@JsonKey(name: 'remainingDay') int? remainingDay
});




}
/// @nodoc
class _$RepayExtensionRespDataCopyWithImpl<$Res>
    implements $RepayExtensionRespDataCopyWith<$Res> {
  _$RepayExtensionRespDataCopyWithImpl(this._self, this._then);

  final RepayExtensionRespData _self;
  final $Res Function(RepayExtensionRespData) _then;

/// Create a copy of RepayExtensionRespData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? extensionFee = freezed,Object? newExtensionFee = freezed,Object? extensionWaivedAmount = freezed,Object? extensionRepaymentDate = freezed,Object? totalSureRepayAmounts = freezed,Object? remainingDay = freezed,}) {
  return _then(_self.copyWith(
extensionFee: freezed == extensionFee ? _self.extensionFee : extensionFee // ignore: cast_nullable_to_non_nullable
as num?,newExtensionFee: freezed == newExtensionFee ? _self.newExtensionFee : newExtensionFee // ignore: cast_nullable_to_non_nullable
as num?,extensionWaivedAmount: freezed == extensionWaivedAmount ? _self.extensionWaivedAmount : extensionWaivedAmount // ignore: cast_nullable_to_non_nullable
as num?,extensionRepaymentDate: freezed == extensionRepaymentDate ? _self.extensionRepaymentDate : extensionRepaymentDate // ignore: cast_nullable_to_non_nullable
as String?,totalSureRepayAmounts: freezed == totalSureRepayAmounts ? _self.totalSureRepayAmounts : totalSureRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepayExtensionRespData].
extension RepayExtensionRespDataPatterns on RepayExtensionRespData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayExtensionRespData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayExtensionRespData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayExtensionRespData value)  $default,){
final _that = this;
switch (_that) {
case _RepayExtensionRespData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayExtensionRespData value)?  $default,){
final _that = this;
switch (_that) {
case _RepayExtensionRespData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'extensionFee')  num? extensionFee, @JsonKey(name: 'newExtensionFee')  num? newExtensionFee, @JsonKey(name: 'extensionWaivedAmount')  num? extensionWaivedAmount, @JsonKey(name: 'extensionRepaymentDate')  String? extensionRepaymentDate, @JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'remainingDay')  int? remainingDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayExtensionRespData() when $default != null:
return $default(_that.extensionFee,_that.newExtensionFee,_that.extensionWaivedAmount,_that.extensionRepaymentDate,_that.totalSureRepayAmounts,_that.remainingDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'extensionFee')  num? extensionFee, @JsonKey(name: 'newExtensionFee')  num? newExtensionFee, @JsonKey(name: 'extensionWaivedAmount')  num? extensionWaivedAmount, @JsonKey(name: 'extensionRepaymentDate')  String? extensionRepaymentDate, @JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'remainingDay')  int? remainingDay)  $default,) {final _that = this;
switch (_that) {
case _RepayExtensionRespData():
return $default(_that.extensionFee,_that.newExtensionFee,_that.extensionWaivedAmount,_that.extensionRepaymentDate,_that.totalSureRepayAmounts,_that.remainingDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'extensionFee')  num? extensionFee, @JsonKey(name: 'newExtensionFee')  num? newExtensionFee, @JsonKey(name: 'extensionWaivedAmount')  num? extensionWaivedAmount, @JsonKey(name: 'extensionRepaymentDate')  String? extensionRepaymentDate, @JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'remainingDay')  int? remainingDay)?  $default,) {final _that = this;
switch (_that) {
case _RepayExtensionRespData() when $default != null:
return $default(_that.extensionFee,_that.newExtensionFee,_that.extensionWaivedAmount,_that.extensionRepaymentDate,_that.totalSureRepayAmounts,_that.remainingDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayExtensionRespData implements RepayExtensionRespData {
  const _RepayExtensionRespData({@JsonKey(name: 'extensionFee') this.extensionFee, @JsonKey(name: 'newExtensionFee') this.newExtensionFee, @JsonKey(name: 'extensionWaivedAmount') this.extensionWaivedAmount, @JsonKey(name: 'extensionRepaymentDate') this.extensionRepaymentDate, @JsonKey(name: 'totalSureRepayAmounts') this.totalSureRepayAmounts, @JsonKey(name: 'remainingDay') this.remainingDay});
  factory _RepayExtensionRespData.fromJson(Map<String, dynamic> json) => _$RepayExtensionRespDataFromJson(json);

@override@JsonKey(name: 'extensionFee') final  num? extensionFee;
@override@JsonKey(name: 'newExtensionFee') final  num? newExtensionFee;
@override@JsonKey(name: 'extensionWaivedAmount') final  num? extensionWaivedAmount;
@override@JsonKey(name: 'extensionRepaymentDate') final  String? extensionRepaymentDate;
@override@JsonKey(name: 'totalSureRepayAmounts') final  num? totalSureRepayAmounts;
@override@JsonKey(name: 'remainingDay') final  int? remainingDay;

/// Create a copy of RepayExtensionRespData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayExtensionRespDataCopyWith<_RepayExtensionRespData> get copyWith => __$RepayExtensionRespDataCopyWithImpl<_RepayExtensionRespData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayExtensionRespDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayExtensionRespData&&(identical(other.extensionFee, extensionFee) || other.extensionFee == extensionFee)&&(identical(other.newExtensionFee, newExtensionFee) || other.newExtensionFee == newExtensionFee)&&(identical(other.extensionWaivedAmount, extensionWaivedAmount) || other.extensionWaivedAmount == extensionWaivedAmount)&&(identical(other.extensionRepaymentDate, extensionRepaymentDate) || other.extensionRepaymentDate == extensionRepaymentDate)&&(identical(other.totalSureRepayAmounts, totalSureRepayAmounts) || other.totalSureRepayAmounts == totalSureRepayAmounts)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,extensionFee,newExtensionFee,extensionWaivedAmount,extensionRepaymentDate,totalSureRepayAmounts,remainingDay);

@override
String toString() {
  return 'RepayExtensionRespData(extensionFee: $extensionFee, newExtensionFee: $newExtensionFee, extensionWaivedAmount: $extensionWaivedAmount, extensionRepaymentDate: $extensionRepaymentDate, totalSureRepayAmounts: $totalSureRepayAmounts, remainingDay: $remainingDay)';
}


}

/// @nodoc
abstract mixin class _$RepayExtensionRespDataCopyWith<$Res> implements $RepayExtensionRespDataCopyWith<$Res> {
  factory _$RepayExtensionRespDataCopyWith(_RepayExtensionRespData value, $Res Function(_RepayExtensionRespData) _then) = __$RepayExtensionRespDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'extensionFee') num? extensionFee,@JsonKey(name: 'newExtensionFee') num? newExtensionFee,@JsonKey(name: 'extensionWaivedAmount') num? extensionWaivedAmount,@JsonKey(name: 'extensionRepaymentDate') String? extensionRepaymentDate,@JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,@JsonKey(name: 'remainingDay') int? remainingDay
});




}
/// @nodoc
class __$RepayExtensionRespDataCopyWithImpl<$Res>
    implements _$RepayExtensionRespDataCopyWith<$Res> {
  __$RepayExtensionRespDataCopyWithImpl(this._self, this._then);

  final _RepayExtensionRespData _self;
  final $Res Function(_RepayExtensionRespData) _then;

/// Create a copy of RepayExtensionRespData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? extensionFee = freezed,Object? newExtensionFee = freezed,Object? extensionWaivedAmount = freezed,Object? extensionRepaymentDate = freezed,Object? totalSureRepayAmounts = freezed,Object? remainingDay = freezed,}) {
  return _then(_RepayExtensionRespData(
extensionFee: freezed == extensionFee ? _self.extensionFee : extensionFee // ignore: cast_nullable_to_non_nullable
as num?,newExtensionFee: freezed == newExtensionFee ? _self.newExtensionFee : newExtensionFee // ignore: cast_nullable_to_non_nullable
as num?,extensionWaivedAmount: freezed == extensionWaivedAmount ? _self.extensionWaivedAmount : extensionWaivedAmount // ignore: cast_nullable_to_non_nullable
as num?,extensionRepaymentDate: freezed == extensionRepaymentDate ? _self.extensionRepaymentDate : extensionRepaymentDate // ignore: cast_nullable_to_non_nullable
as String?,totalSureRepayAmounts: freezed == totalSureRepayAmounts ? _self.totalSureRepayAmounts : totalSureRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
