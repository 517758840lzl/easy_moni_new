// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'use_coupon_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UseCouponResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'data') UseCouponRespData? get data;@JsonKey(name: 'msg') String? get msg;
/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseCouponRespCopyWith<UseCouponResp> get copyWith => _$UseCouponRespCopyWithImpl<UseCouponResp>(this as UseCouponResp, _$identity);

  /// Serializes this UseCouponResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCouponResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,data,msg);

@override
String toString() {
  return 'UseCouponResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class $UseCouponRespCopyWith<$Res>  {
  factory $UseCouponRespCopyWith(UseCouponResp value, $Res Function(UseCouponResp) _then) = _$UseCouponRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') UseCouponRespData? data,@JsonKey(name: 'msg') String? msg
});


$UseCouponRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$UseCouponRespCopyWithImpl<$Res>
    implements $UseCouponRespCopyWith<$Res> {
  _$UseCouponRespCopyWithImpl(this._self, this._then);

  final UseCouponResp _self;
  final $Res Function(UseCouponResp) _then;

/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UseCouponRespData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCouponRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UseCouponRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UseCouponResp].
extension UseCouponRespPatterns on UseCouponResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UseCouponResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UseCouponResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UseCouponResp value)  $default,){
final _that = this;
switch (_that) {
case _UseCouponResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UseCouponResp value)?  $default,){
final _that = this;
switch (_that) {
case _UseCouponResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  UseCouponRespData? data, @JsonKey(name: 'msg')  String? msg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UseCouponResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  UseCouponRespData? data, @JsonKey(name: 'msg')  String? msg)  $default,) {final _that = this;
switch (_that) {
case _UseCouponResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  UseCouponRespData? data, @JsonKey(name: 'msg')  String? msg)?  $default,) {final _that = this;
switch (_that) {
case _UseCouponResp() when $default != null:
return $default(_that.code,_that.data,_that.msg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UseCouponResp implements UseCouponResp {
  const _UseCouponResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'data') this.data, @JsonKey(name: 'msg') this.msg});
  factory _UseCouponResp.fromJson(Map<String, dynamic> json) => _$UseCouponRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'data') final  UseCouponRespData? data;
@override@JsonKey(name: 'msg') final  String? msg;

/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UseCouponRespCopyWith<_UseCouponResp> get copyWith => __$UseCouponRespCopyWithImpl<_UseCouponResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UseCouponRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UseCouponResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,data,msg);

@override
String toString() {
  return 'UseCouponResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class _$UseCouponRespCopyWith<$Res> implements $UseCouponRespCopyWith<$Res> {
  factory _$UseCouponRespCopyWith(_UseCouponResp value, $Res Function(_UseCouponResp) _then) = __$UseCouponRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') UseCouponRespData? data,@JsonKey(name: 'msg') String? msg
});


@override $UseCouponRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$UseCouponRespCopyWithImpl<$Res>
    implements _$UseCouponRespCopyWith<$Res> {
  __$UseCouponRespCopyWithImpl(this._self, this._then);

  final _UseCouponResp _self;
  final $Res Function(_UseCouponResp) _then;

/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_UseCouponResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UseCouponRespData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UseCouponResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UseCouponRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UseCouponRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$UseCouponRespData {

@JsonKey(name: 'actualToAccountMoney') num? get actualToAccountMoney;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'newLoanAmount') num? get newLoanAmount;@JsonKey(name: 'newRepaymentAmount') num? get newRepaymentAmount;@JsonKey(name: 'rent') num? get rent;@JsonKey(name: 'repaymentAmount') num? get repaymentAmount;@JsonKey(name: 'serviceFee') num? get serviceFee;@JsonKey(name: 'totalMinRepayAmounts') num? get totalMinRepayAmounts;
/// Create a copy of UseCouponRespData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseCouponRespDataCopyWith<UseCouponRespData> get copyWith => _$UseCouponRespDataCopyWithImpl<UseCouponRespData>(this as UseCouponRespData, _$identity);

  /// Serializes this UseCouponRespData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UseCouponRespData&&(identical(other.actualToAccountMoney, actualToAccountMoney) || other.actualToAccountMoney == actualToAccountMoney)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.newLoanAmount, newLoanAmount) || other.newLoanAmount == newLoanAmount)&&(identical(other.newRepaymentAmount, newRepaymentAmount) || other.newRepaymentAmount == newRepaymentAmount)&&(identical(other.rent, rent) || other.rent == rent)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.totalMinRepayAmounts, totalMinRepayAmounts) || other.totalMinRepayAmounts == totalMinRepayAmounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actualToAccountMoney,loanAmount,newLoanAmount,newRepaymentAmount,rent,repaymentAmount,serviceFee,totalMinRepayAmounts);

@override
String toString() {
  return 'UseCouponRespData(actualToAccountMoney: $actualToAccountMoney, loanAmount: $loanAmount, newLoanAmount: $newLoanAmount, newRepaymentAmount: $newRepaymentAmount, rent: $rent, repaymentAmount: $repaymentAmount, serviceFee: $serviceFee, totalMinRepayAmounts: $totalMinRepayAmounts)';
}


}

/// @nodoc
abstract mixin class $UseCouponRespDataCopyWith<$Res>  {
  factory $UseCouponRespDataCopyWith(UseCouponRespData value, $Res Function(UseCouponRespData) _then) = _$UseCouponRespDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'newLoanAmount') num? newLoanAmount,@JsonKey(name: 'newRepaymentAmount') num? newRepaymentAmount,@JsonKey(name: 'rent') num? rent,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts
});




}
/// @nodoc
class _$UseCouponRespDataCopyWithImpl<$Res>
    implements $UseCouponRespDataCopyWith<$Res> {
  _$UseCouponRespDataCopyWithImpl(this._self, this._then);

  final UseCouponRespData _self;
  final $Res Function(UseCouponRespData) _then;

/// Create a copy of UseCouponRespData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actualToAccountMoney = freezed,Object? loanAmount = freezed,Object? newLoanAmount = freezed,Object? newRepaymentAmount = freezed,Object? rent = freezed,Object? repaymentAmount = freezed,Object? serviceFee = freezed,Object? totalMinRepayAmounts = freezed,}) {
  return _then(_self.copyWith(
actualToAccountMoney: freezed == actualToAccountMoney ? _self.actualToAccountMoney : actualToAccountMoney // ignore: cast_nullable_to_non_nullable
as num?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,newLoanAmount: freezed == newLoanAmount ? _self.newLoanAmount : newLoanAmount // ignore: cast_nullable_to_non_nullable
as num?,newRepaymentAmount: freezed == newRepaymentAmount ? _self.newRepaymentAmount : newRepaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,rent: freezed == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,totalMinRepayAmounts: freezed == totalMinRepayAmounts ? _self.totalMinRepayAmounts : totalMinRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [UseCouponRespData].
extension UseCouponRespDataPatterns on UseCouponRespData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UseCouponRespData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UseCouponRespData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UseCouponRespData value)  $default,){
final _that = this;
switch (_that) {
case _UseCouponRespData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UseCouponRespData value)?  $default,){
final _that = this;
switch (_that) {
case _UseCouponRespData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'newLoanAmount')  num? newLoanAmount, @JsonKey(name: 'newRepaymentAmount')  num? newRepaymentAmount, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UseCouponRespData() when $default != null:
return $default(_that.actualToAccountMoney,_that.loanAmount,_that.newLoanAmount,_that.newRepaymentAmount,_that.rent,_that.repaymentAmount,_that.serviceFee,_that.totalMinRepayAmounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'newLoanAmount')  num? newLoanAmount, @JsonKey(name: 'newRepaymentAmount')  num? newRepaymentAmount, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts)  $default,) {final _that = this;
switch (_that) {
case _UseCouponRespData():
return $default(_that.actualToAccountMoney,_that.loanAmount,_that.newLoanAmount,_that.newRepaymentAmount,_that.rent,_that.repaymentAmount,_that.serviceFee,_that.totalMinRepayAmounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'newLoanAmount')  num? newLoanAmount, @JsonKey(name: 'newRepaymentAmount')  num? newRepaymentAmount, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts)?  $default,) {final _that = this;
switch (_that) {
case _UseCouponRespData() when $default != null:
return $default(_that.actualToAccountMoney,_that.loanAmount,_that.newLoanAmount,_that.newRepaymentAmount,_that.rent,_that.repaymentAmount,_that.serviceFee,_that.totalMinRepayAmounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UseCouponRespData implements UseCouponRespData {
  const _UseCouponRespData({@JsonKey(name: 'actualToAccountMoney') this.actualToAccountMoney, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'newLoanAmount') this.newLoanAmount, @JsonKey(name: 'newRepaymentAmount') this.newRepaymentAmount, @JsonKey(name: 'rent') this.rent, @JsonKey(name: 'repaymentAmount') this.repaymentAmount, @JsonKey(name: 'serviceFee') this.serviceFee, @JsonKey(name: 'totalMinRepayAmounts') this.totalMinRepayAmounts});
  factory _UseCouponRespData.fromJson(Map<String, dynamic> json) => _$UseCouponRespDataFromJson(json);

@override@JsonKey(name: 'actualToAccountMoney') final  num? actualToAccountMoney;
@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'newLoanAmount') final  num? newLoanAmount;
@override@JsonKey(name: 'newRepaymentAmount') final  num? newRepaymentAmount;
@override@JsonKey(name: 'rent') final  num? rent;
@override@JsonKey(name: 'repaymentAmount') final  num? repaymentAmount;
@override@JsonKey(name: 'serviceFee') final  num? serviceFee;
@override@JsonKey(name: 'totalMinRepayAmounts') final  num? totalMinRepayAmounts;

/// Create a copy of UseCouponRespData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UseCouponRespDataCopyWith<_UseCouponRespData> get copyWith => __$UseCouponRespDataCopyWithImpl<_UseCouponRespData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UseCouponRespDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UseCouponRespData&&(identical(other.actualToAccountMoney, actualToAccountMoney) || other.actualToAccountMoney == actualToAccountMoney)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.newLoanAmount, newLoanAmount) || other.newLoanAmount == newLoanAmount)&&(identical(other.newRepaymentAmount, newRepaymentAmount) || other.newRepaymentAmount == newRepaymentAmount)&&(identical(other.rent, rent) || other.rent == rent)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.totalMinRepayAmounts, totalMinRepayAmounts) || other.totalMinRepayAmounts == totalMinRepayAmounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actualToAccountMoney,loanAmount,newLoanAmount,newRepaymentAmount,rent,repaymentAmount,serviceFee,totalMinRepayAmounts);

@override
String toString() {
  return 'UseCouponRespData(actualToAccountMoney: $actualToAccountMoney, loanAmount: $loanAmount, newLoanAmount: $newLoanAmount, newRepaymentAmount: $newRepaymentAmount, rent: $rent, repaymentAmount: $repaymentAmount, serviceFee: $serviceFee, totalMinRepayAmounts: $totalMinRepayAmounts)';
}


}

/// @nodoc
abstract mixin class _$UseCouponRespDataCopyWith<$Res> implements $UseCouponRespDataCopyWith<$Res> {
  factory _$UseCouponRespDataCopyWith(_UseCouponRespData value, $Res Function(_UseCouponRespData) _then) = __$UseCouponRespDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'newLoanAmount') num? newLoanAmount,@JsonKey(name: 'newRepaymentAmount') num? newRepaymentAmount,@JsonKey(name: 'rent') num? rent,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts
});




}
/// @nodoc
class __$UseCouponRespDataCopyWithImpl<$Res>
    implements _$UseCouponRespDataCopyWith<$Res> {
  __$UseCouponRespDataCopyWithImpl(this._self, this._then);

  final _UseCouponRespData _self;
  final $Res Function(_UseCouponRespData) _then;

/// Create a copy of UseCouponRespData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actualToAccountMoney = freezed,Object? loanAmount = freezed,Object? newLoanAmount = freezed,Object? newRepaymentAmount = freezed,Object? rent = freezed,Object? repaymentAmount = freezed,Object? serviceFee = freezed,Object? totalMinRepayAmounts = freezed,}) {
  return _then(_UseCouponRespData(
actualToAccountMoney: freezed == actualToAccountMoney ? _self.actualToAccountMoney : actualToAccountMoney // ignore: cast_nullable_to_non_nullable
as num?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,newLoanAmount: freezed == newLoanAmount ? _self.newLoanAmount : newLoanAmount // ignore: cast_nullable_to_non_nullable
as num?,newRepaymentAmount: freezed == newRepaymentAmount ? _self.newRepaymentAmount : newRepaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,rent: freezed == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,totalMinRepayAmounts: freezed == totalMinRepayAmounts ? _self.totalMinRepayAmounts : totalMinRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
