// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repay_detail_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepayDetailResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'msg') String? get msg;@JsonKey(name: 'data') RepayDetailRespData? get data;
/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayDetailRespCopyWith<RepayDetailResp> get copyWith => _$RepayDetailRespCopyWithImpl<RepayDetailResp>(this as RepayDetailResp, _$identity);

  /// Serializes this RepayDetailResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayDetailResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'RepayDetailResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class $RepayDetailRespCopyWith<$Res>  {
  factory $RepayDetailRespCopyWith(RepayDetailResp value, $Res Function(RepayDetailResp) _then) = _$RepayDetailRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') RepayDetailRespData? data
});


$RepayDetailRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$RepayDetailRespCopyWithImpl<$Res>
    implements $RepayDetailRespCopyWith<$Res> {
  _$RepayDetailRespCopyWithImpl(this._self, this._then);

  final RepayDetailResp _self;
  final $Res Function(RepayDetailResp) _then;

/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RepayDetailRespData?,
  ));
}
/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepayDetailRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $RepayDetailRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [RepayDetailResp].
extension RepayDetailRespPatterns on RepayDetailResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayDetailResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayDetailResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayDetailResp value)  $default,){
final _that = this;
switch (_that) {
case _RepayDetailResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayDetailResp value)?  $default,){
final _that = this;
switch (_that) {
case _RepayDetailResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayDetailRespData? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayDetailResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayDetailRespData? data)  $default,) {final _that = this;
switch (_that) {
case _RepayDetailResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  RepayDetailRespData? data)?  $default,) {final _that = this;
switch (_that) {
case _RepayDetailResp() when $default != null:
return $default(_that.code,_that.msg,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayDetailResp implements RepayDetailResp {
  const _RepayDetailResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'msg') this.msg, @JsonKey(name: 'data') this.data});
  factory _RepayDetailResp.fromJson(Map<String, dynamic> json) => _$RepayDetailRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'msg') final  String? msg;
@override@JsonKey(name: 'data') final  RepayDetailRespData? data;

/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayDetailRespCopyWith<_RepayDetailResp> get copyWith => __$RepayDetailRespCopyWithImpl<_RepayDetailResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayDetailRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayDetailResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'RepayDetailResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class _$RepayDetailRespCopyWith<$Res> implements $RepayDetailRespCopyWith<$Res> {
  factory _$RepayDetailRespCopyWith(_RepayDetailResp value, $Res Function(_RepayDetailResp) _then) = __$RepayDetailRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') RepayDetailRespData? data
});


@override $RepayDetailRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$RepayDetailRespCopyWithImpl<$Res>
    implements _$RepayDetailRespCopyWith<$Res> {
  __$RepayDetailRespCopyWithImpl(this._self, this._then);

  final _RepayDetailResp _self;
  final $Res Function(_RepayDetailResp) _then;

/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_RepayDetailResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RepayDetailRespData?,
  ));
}

/// Create a copy of RepayDetailResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepayDetailRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $RepayDetailRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$RepayDetailRespData {

@JsonKey(name: 'totalSureRepayAmounts') num? get totalSureRepayAmounts;@JsonKey(name: 'sureRepayPeriods') int? get sureRepayPeriods;@JsonKey(name: 'remainingDay') int? get remainingDay;@JsonKey(name: 'extensionSwitch') bool? get extensionSwitch;@JsonKey(name: 'isExtensionSwitch') bool? get isExtensionSwitch;@JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? get loanOrderDetails;@JsonKey(name: 'totalMinRepayAmounts') num? get totalMinRepayAmounts;@JsonKey(name: 'waivedAmount') num? get waivedAmount;
/// Create a copy of RepayDetailRespData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayDetailRespDataCopyWith<RepayDetailRespData> get copyWith => _$RepayDetailRespDataCopyWithImpl<RepayDetailRespData>(this as RepayDetailRespData, _$identity);

  /// Serializes this RepayDetailRespData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayDetailRespData&&(identical(other.totalSureRepayAmounts, totalSureRepayAmounts) || other.totalSureRepayAmounts == totalSureRepayAmounts)&&(identical(other.sureRepayPeriods, sureRepayPeriods) || other.sureRepayPeriods == sureRepayPeriods)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay)&&(identical(other.extensionSwitch, extensionSwitch) || other.extensionSwitch == extensionSwitch)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&const DeepCollectionEquality().equals(other.loanOrderDetails, loanOrderDetails)&&(identical(other.totalMinRepayAmounts, totalMinRepayAmounts) || other.totalMinRepayAmounts == totalMinRepayAmounts)&&(identical(other.waivedAmount, waivedAmount) || other.waivedAmount == waivedAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSureRepayAmounts,sureRepayPeriods,remainingDay,extensionSwitch,isExtensionSwitch,const DeepCollectionEquality().hash(loanOrderDetails),totalMinRepayAmounts,waivedAmount);

@override
String toString() {
  return 'RepayDetailRespData(totalSureRepayAmounts: $totalSureRepayAmounts, sureRepayPeriods: $sureRepayPeriods, remainingDay: $remainingDay, extensionSwitch: $extensionSwitch, isExtensionSwitch: $isExtensionSwitch, loanOrderDetails: $loanOrderDetails, totalMinRepayAmounts: $totalMinRepayAmounts, waivedAmount: $waivedAmount)';
}


}

/// @nodoc
abstract mixin class $RepayDetailRespDataCopyWith<$Res>  {
  factory $RepayDetailRespDataCopyWith(RepayDetailRespData value, $Res Function(RepayDetailRespData) _then) = _$RepayDetailRespDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,@JsonKey(name: 'sureRepayPeriods') int? sureRepayPeriods,@JsonKey(name: 'remainingDay') int? remainingDay,@JsonKey(name: 'extensionSwitch') bool? extensionSwitch,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails,@JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts,@JsonKey(name: 'waivedAmount') num? waivedAmount
});




}
/// @nodoc
class _$RepayDetailRespDataCopyWithImpl<$Res>
    implements $RepayDetailRespDataCopyWith<$Res> {
  _$RepayDetailRespDataCopyWithImpl(this._self, this._then);

  final RepayDetailRespData _self;
  final $Res Function(RepayDetailRespData) _then;

/// Create a copy of RepayDetailRespData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSureRepayAmounts = freezed,Object? sureRepayPeriods = freezed,Object? remainingDay = freezed,Object? extensionSwitch = freezed,Object? isExtensionSwitch = freezed,Object? loanOrderDetails = freezed,Object? totalMinRepayAmounts = freezed,Object? waivedAmount = freezed,}) {
  return _then(_self.copyWith(
totalSureRepayAmounts: freezed == totalSureRepayAmounts ? _self.totalSureRepayAmounts : totalSureRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,sureRepayPeriods: freezed == sureRepayPeriods ? _self.sureRepayPeriods : sureRepayPeriods // ignore: cast_nullable_to_non_nullable
as int?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,extensionSwitch: freezed == extensionSwitch ? _self.extensionSwitch : extensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanOrderDetails: freezed == loanOrderDetails ? _self.loanOrderDetails : loanOrderDetails // ignore: cast_nullable_to_non_nullable
as List<RepayDetailRespDataLoanOrderDetails>?,totalMinRepayAmounts: freezed == totalMinRepayAmounts ? _self.totalMinRepayAmounts : totalMinRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,waivedAmount: freezed == waivedAmount ? _self.waivedAmount : waivedAmount // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepayDetailRespData].
extension RepayDetailRespDataPatterns on RepayDetailRespData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayDetailRespData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayDetailRespData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayDetailRespData value)  $default,){
final _that = this;
switch (_that) {
case _RepayDetailRespData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayDetailRespData value)?  $default,){
final _that = this;
switch (_that) {
case _RepayDetailRespData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'sureRepayPeriods')  int? sureRepayPeriods, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'extensionSwitch')  bool? extensionSwitch, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanOrderDetails')  List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts, @JsonKey(name: 'waivedAmount')  num? waivedAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayDetailRespData() when $default != null:
return $default(_that.totalSureRepayAmounts,_that.sureRepayPeriods,_that.remainingDay,_that.extensionSwitch,_that.isExtensionSwitch,_that.loanOrderDetails,_that.totalMinRepayAmounts,_that.waivedAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'sureRepayPeriods')  int? sureRepayPeriods, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'extensionSwitch')  bool? extensionSwitch, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanOrderDetails')  List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts, @JsonKey(name: 'waivedAmount')  num? waivedAmount)  $default,) {final _that = this;
switch (_that) {
case _RepayDetailRespData():
return $default(_that.totalSureRepayAmounts,_that.sureRepayPeriods,_that.remainingDay,_that.extensionSwitch,_that.isExtensionSwitch,_that.loanOrderDetails,_that.totalMinRepayAmounts,_that.waivedAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'totalSureRepayAmounts')  num? totalSureRepayAmounts, @JsonKey(name: 'sureRepayPeriods')  int? sureRepayPeriods, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'extensionSwitch')  bool? extensionSwitch, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanOrderDetails')  List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails, @JsonKey(name: 'totalMinRepayAmounts')  num? totalMinRepayAmounts, @JsonKey(name: 'waivedAmount')  num? waivedAmount)?  $default,) {final _that = this;
switch (_that) {
case _RepayDetailRespData() when $default != null:
return $default(_that.totalSureRepayAmounts,_that.sureRepayPeriods,_that.remainingDay,_that.extensionSwitch,_that.isExtensionSwitch,_that.loanOrderDetails,_that.totalMinRepayAmounts,_that.waivedAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayDetailRespData implements RepayDetailRespData {
  const _RepayDetailRespData({@JsonKey(name: 'totalSureRepayAmounts') this.totalSureRepayAmounts, @JsonKey(name: 'sureRepayPeriods') this.sureRepayPeriods, @JsonKey(name: 'remainingDay') this.remainingDay, @JsonKey(name: 'extensionSwitch') this.extensionSwitch, @JsonKey(name: 'isExtensionSwitch') this.isExtensionSwitch, @JsonKey(name: 'loanOrderDetails') final  List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails, @JsonKey(name: 'totalMinRepayAmounts') this.totalMinRepayAmounts, @JsonKey(name: 'waivedAmount') this.waivedAmount}): _loanOrderDetails = loanOrderDetails;
  factory _RepayDetailRespData.fromJson(Map<String, dynamic> json) => _$RepayDetailRespDataFromJson(json);

@override@JsonKey(name: 'totalSureRepayAmounts') final  num? totalSureRepayAmounts;
@override@JsonKey(name: 'sureRepayPeriods') final  int? sureRepayPeriods;
@override@JsonKey(name: 'remainingDay') final  int? remainingDay;
@override@JsonKey(name: 'extensionSwitch') final  bool? extensionSwitch;
@override@JsonKey(name: 'isExtensionSwitch') final  bool? isExtensionSwitch;
 final  List<RepayDetailRespDataLoanOrderDetails>? _loanOrderDetails;
@override@JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? get loanOrderDetails {
  final value = _loanOrderDetails;
  if (value == null) return null;
  if (_loanOrderDetails is EqualUnmodifiableListView) return _loanOrderDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'totalMinRepayAmounts') final  num? totalMinRepayAmounts;
@override@JsonKey(name: 'waivedAmount') final  num? waivedAmount;

/// Create a copy of RepayDetailRespData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayDetailRespDataCopyWith<_RepayDetailRespData> get copyWith => __$RepayDetailRespDataCopyWithImpl<_RepayDetailRespData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayDetailRespDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayDetailRespData&&(identical(other.totalSureRepayAmounts, totalSureRepayAmounts) || other.totalSureRepayAmounts == totalSureRepayAmounts)&&(identical(other.sureRepayPeriods, sureRepayPeriods) || other.sureRepayPeriods == sureRepayPeriods)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay)&&(identical(other.extensionSwitch, extensionSwitch) || other.extensionSwitch == extensionSwitch)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&const DeepCollectionEquality().equals(other._loanOrderDetails, _loanOrderDetails)&&(identical(other.totalMinRepayAmounts, totalMinRepayAmounts) || other.totalMinRepayAmounts == totalMinRepayAmounts)&&(identical(other.waivedAmount, waivedAmount) || other.waivedAmount == waivedAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSureRepayAmounts,sureRepayPeriods,remainingDay,extensionSwitch,isExtensionSwitch,const DeepCollectionEquality().hash(_loanOrderDetails),totalMinRepayAmounts,waivedAmount);

@override
String toString() {
  return 'RepayDetailRespData(totalSureRepayAmounts: $totalSureRepayAmounts, sureRepayPeriods: $sureRepayPeriods, remainingDay: $remainingDay, extensionSwitch: $extensionSwitch, isExtensionSwitch: $isExtensionSwitch, loanOrderDetails: $loanOrderDetails, totalMinRepayAmounts: $totalMinRepayAmounts, waivedAmount: $waivedAmount)';
}


}

/// @nodoc
abstract mixin class _$RepayDetailRespDataCopyWith<$Res> implements $RepayDetailRespDataCopyWith<$Res> {
  factory _$RepayDetailRespDataCopyWith(_RepayDetailRespData value, $Res Function(_RepayDetailRespData) _then) = __$RepayDetailRespDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'totalSureRepayAmounts') num? totalSureRepayAmounts,@JsonKey(name: 'sureRepayPeriods') int? sureRepayPeriods,@JsonKey(name: 'remainingDay') int? remainingDay,@JsonKey(name: 'extensionSwitch') bool? extensionSwitch,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanOrderDetails') List<RepayDetailRespDataLoanOrderDetails>? loanOrderDetails,@JsonKey(name: 'totalMinRepayAmounts') num? totalMinRepayAmounts,@JsonKey(name: 'waivedAmount') num? waivedAmount
});




}
/// @nodoc
class __$RepayDetailRespDataCopyWithImpl<$Res>
    implements _$RepayDetailRespDataCopyWith<$Res> {
  __$RepayDetailRespDataCopyWithImpl(this._self, this._then);

  final _RepayDetailRespData _self;
  final $Res Function(_RepayDetailRespData) _then;

/// Create a copy of RepayDetailRespData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSureRepayAmounts = freezed,Object? sureRepayPeriods = freezed,Object? remainingDay = freezed,Object? extensionSwitch = freezed,Object? isExtensionSwitch = freezed,Object? loanOrderDetails = freezed,Object? totalMinRepayAmounts = freezed,Object? waivedAmount = freezed,}) {
  return _then(_RepayDetailRespData(
totalSureRepayAmounts: freezed == totalSureRepayAmounts ? _self.totalSureRepayAmounts : totalSureRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,sureRepayPeriods: freezed == sureRepayPeriods ? _self.sureRepayPeriods : sureRepayPeriods // ignore: cast_nullable_to_non_nullable
as int?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,extensionSwitch: freezed == extensionSwitch ? _self.extensionSwitch : extensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanOrderDetails: freezed == loanOrderDetails ? _self._loanOrderDetails : loanOrderDetails // ignore: cast_nullable_to_non_nullable
as List<RepayDetailRespDataLoanOrderDetails>?,totalMinRepayAmounts: freezed == totalMinRepayAmounts ? _self.totalMinRepayAmounts : totalMinRepayAmounts // ignore: cast_nullable_to_non_nullable
as num?,waivedAmount: freezed == waivedAmount ? _self.waivedAmount : waivedAmount // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}


/// @nodoc
mixin _$RepayDetailRespDataLoanOrderDetails {

@JsonKey(name: 'appOrderId') String? get appOrderId;@JsonKey(name: 'productCode') String? get productCode;@JsonKey(name: 'productLogo') String? get productLogo;@JsonKey(name: 'productName') String? get productName;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'installmentId') int? get installmentId;@JsonKey(name: 'term') int? get term;@JsonKey(name: 'daysPerTerm') int? get daysPerTerm;@JsonKey(name: 'repayDate') String? get repayDate;@JsonKey(name: 'remainingDay') int? get remainingDay;@JsonKey(name: 'receiptAmount') num? get receiptAmount;@JsonKey(name: 'serviceFee') num? get serviceFee;@JsonKey(name: 'repaymentAmount') num? get repaymentAmount;@JsonKey(name: 'waivedAmount') num? get waivedAmount;@JsonKey(name: 'installmentNum') int? get installmentNum;@JsonKey(name: 'bankCardNo') String? get bankCardNo;@JsonKey(name: 'bankAccountId') int? get bankAccountId;@JsonKey(name: 'bankAccountType') String? get bankAccountType;@JsonKey(name: 'bankName') String? get bankName;@JsonKey(name: 'orderStatus') int? get orderStatus;@JsonKey(name: 'orderStatusDesc') String? get orderStatusDesc;@JsonKey(name: 'updateTime') String? get updateTime;@JsonKey(name: 'acqChannel') String? get acqChannel;@JsonKey(name: 'closeTime') int? get closeTime;@JsonKey(name: 'rejectTime') int? get rejectTime;@JsonKey(name: 'interest') num? get interest;@JsonKey(name: 'overdueInterest') num? get overdueInterest;
/// Create a copy of RepayDetailRespDataLoanOrderDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayDetailRespDataLoanOrderDetailsCopyWith<RepayDetailRespDataLoanOrderDetails> get copyWith => _$RepayDetailRespDataLoanOrderDetailsCopyWithImpl<RepayDetailRespDataLoanOrderDetails>(this as RepayDetailRespDataLoanOrderDetails, _$identity);

  /// Serializes this RepayDetailRespDataLoanOrderDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayDetailRespDataLoanOrderDetails&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.installmentId, installmentId) || other.installmentId == installmentId)&&(identical(other.term, term) || other.term == term)&&(identical(other.daysPerTerm, daysPerTerm) || other.daysPerTerm == daysPerTerm)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.waivedAmount, waivedAmount) || other.waivedAmount == waivedAmount)&&(identical(other.installmentNum, installmentNum) || other.installmentNum == installmentNum)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankAccountId, bankAccountId) || other.bankAccountId == bankAccountId)&&(identical(other.bankAccountType, bankAccountType) || other.bankAccountType == bankAccountType)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusDesc, orderStatusDesc) || other.orderStatusDesc == orderStatusDesc)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime)&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.overdueInterest, overdueInterest) || other.overdueInterest == overdueInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,appOrderId,productCode,productLogo,productName,loanAmount,installmentId,term,daysPerTerm,repayDate,remainingDay,receiptAmount,serviceFee,repaymentAmount,waivedAmount,installmentNum,bankCardNo,bankAccountId,bankAccountType,bankName,orderStatus,orderStatusDesc,updateTime,acqChannel,closeTime,rejectTime,interest,overdueInterest]);

@override
String toString() {
  return 'RepayDetailRespDataLoanOrderDetails(appOrderId: $appOrderId, productCode: $productCode, productLogo: $productLogo, productName: $productName, loanAmount: $loanAmount, installmentId: $installmentId, term: $term, daysPerTerm: $daysPerTerm, repayDate: $repayDate, remainingDay: $remainingDay, receiptAmount: $receiptAmount, serviceFee: $serviceFee, repaymentAmount: $repaymentAmount, waivedAmount: $waivedAmount, installmentNum: $installmentNum, bankCardNo: $bankCardNo, bankAccountId: $bankAccountId, bankAccountType: $bankAccountType, bankName: $bankName, orderStatus: $orderStatus, orderStatusDesc: $orderStatusDesc, updateTime: $updateTime, acqChannel: $acqChannel, closeTime: $closeTime, rejectTime: $rejectTime, interest: $interest, overdueInterest: $overdueInterest)';
}


}

/// @nodoc
abstract mixin class $RepayDetailRespDataLoanOrderDetailsCopyWith<$Res>  {
  factory $RepayDetailRespDataLoanOrderDetailsCopyWith(RepayDetailRespDataLoanOrderDetails value, $Res Function(RepayDetailRespDataLoanOrderDetails) _then) = _$RepayDetailRespDataLoanOrderDetailsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'productCode') String? productCode,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'installmentId') int? installmentId,@JsonKey(name: 'term') int? term,@JsonKey(name: 'daysPerTerm') int? daysPerTerm,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'remainingDay') int? remainingDay,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'waivedAmount') num? waivedAmount,@JsonKey(name: 'installmentNum') int? installmentNum,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankAccountId') int? bankAccountId,@JsonKey(name: 'bankAccountType') String? bankAccountType,@JsonKey(name: 'bankName') String? bankName,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusDesc') String? orderStatusDesc,@JsonKey(name: 'updateTime') String? updateTime,@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'closeTime') int? closeTime,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'overdueInterest') num? overdueInterest
});




}
/// @nodoc
class _$RepayDetailRespDataLoanOrderDetailsCopyWithImpl<$Res>
    implements $RepayDetailRespDataLoanOrderDetailsCopyWith<$Res> {
  _$RepayDetailRespDataLoanOrderDetailsCopyWithImpl(this._self, this._then);

  final RepayDetailRespDataLoanOrderDetails _self;
  final $Res Function(RepayDetailRespDataLoanOrderDetails) _then;

/// Create a copy of RepayDetailRespDataLoanOrderDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appOrderId = freezed,Object? productCode = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? loanAmount = freezed,Object? installmentId = freezed,Object? term = freezed,Object? daysPerTerm = freezed,Object? repayDate = freezed,Object? remainingDay = freezed,Object? receiptAmount = freezed,Object? serviceFee = freezed,Object? repaymentAmount = freezed,Object? waivedAmount = freezed,Object? installmentNum = freezed,Object? bankCardNo = freezed,Object? bankAccountId = freezed,Object? bankAccountType = freezed,Object? bankName = freezed,Object? orderStatus = freezed,Object? orderStatusDesc = freezed,Object? updateTime = freezed,Object? acqChannel = freezed,Object? closeTime = freezed,Object? rejectTime = freezed,Object? interest = freezed,Object? overdueInterest = freezed,}) {
  return _then(_self.copyWith(
appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,installmentId: freezed == installmentId ? _self.installmentId : installmentId // ignore: cast_nullable_to_non_nullable
as int?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,daysPerTerm: freezed == daysPerTerm ? _self.daysPerTerm : daysPerTerm // ignore: cast_nullable_to_non_nullable
as int?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,waivedAmount: freezed == waivedAmount ? _self.waivedAmount : waivedAmount // ignore: cast_nullable_to_non_nullable
as num?,installmentNum: freezed == installmentNum ? _self.installmentNum : installmentNum // ignore: cast_nullable_to_non_nullable
as int?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankAccountId: freezed == bankAccountId ? _self.bankAccountId : bankAccountId // ignore: cast_nullable_to_non_nullable
as int?,bankAccountType: freezed == bankAccountType ? _self.bankAccountType : bankAccountType // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusDesc: freezed == orderStatusDesc ? _self.orderStatusDesc : orderStatusDesc // ignore: cast_nullable_to_non_nullable
as String?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as int?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,overdueInterest: freezed == overdueInterest ? _self.overdueInterest : overdueInterest // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepayDetailRespDataLoanOrderDetails].
extension RepayDetailRespDataLoanOrderDetailsPatterns on RepayDetailRespDataLoanOrderDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayDetailRespDataLoanOrderDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayDetailRespDataLoanOrderDetails value)  $default,){
final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayDetailRespDataLoanOrderDetails value)?  $default,){
final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'installmentId')  int? installmentId, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'daysPerTerm')  int? daysPerTerm, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'waivedAmount')  num? waivedAmount, @JsonKey(name: 'installmentNum')  int? installmentNum, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankAccountId')  int? bankAccountId, @JsonKey(name: 'bankAccountType')  String? bankAccountType, @JsonKey(name: 'bankName')  String? bankName, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusDesc')  String? orderStatusDesc, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'overdueInterest')  num? overdueInterest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails() when $default != null:
return $default(_that.appOrderId,_that.productCode,_that.productLogo,_that.productName,_that.loanAmount,_that.installmentId,_that.term,_that.daysPerTerm,_that.repayDate,_that.remainingDay,_that.receiptAmount,_that.serviceFee,_that.repaymentAmount,_that.waivedAmount,_that.installmentNum,_that.bankCardNo,_that.bankAccountId,_that.bankAccountType,_that.bankName,_that.orderStatus,_that.orderStatusDesc,_that.updateTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.interest,_that.overdueInterest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'installmentId')  int? installmentId, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'daysPerTerm')  int? daysPerTerm, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'waivedAmount')  num? waivedAmount, @JsonKey(name: 'installmentNum')  int? installmentNum, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankAccountId')  int? bankAccountId, @JsonKey(name: 'bankAccountType')  String? bankAccountType, @JsonKey(name: 'bankName')  String? bankName, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusDesc')  String? orderStatusDesc, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'overdueInterest')  num? overdueInterest)  $default,) {final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails():
return $default(_that.appOrderId,_that.productCode,_that.productLogo,_that.productName,_that.loanAmount,_that.installmentId,_that.term,_that.daysPerTerm,_that.repayDate,_that.remainingDay,_that.receiptAmount,_that.serviceFee,_that.repaymentAmount,_that.waivedAmount,_that.installmentNum,_that.bankCardNo,_that.bankAccountId,_that.bankAccountType,_that.bankName,_that.orderStatus,_that.orderStatusDesc,_that.updateTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.interest,_that.overdueInterest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'installmentId')  int? installmentId, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'daysPerTerm')  int? daysPerTerm, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'remainingDay')  int? remainingDay, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'waivedAmount')  num? waivedAmount, @JsonKey(name: 'installmentNum')  int? installmentNum, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankAccountId')  int? bankAccountId, @JsonKey(name: 'bankAccountType')  String? bankAccountType, @JsonKey(name: 'bankName')  String? bankName, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusDesc')  String? orderStatusDesc, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'overdueInterest')  num? overdueInterest)?  $default,) {final _that = this;
switch (_that) {
case _RepayDetailRespDataLoanOrderDetails() when $default != null:
return $default(_that.appOrderId,_that.productCode,_that.productLogo,_that.productName,_that.loanAmount,_that.installmentId,_that.term,_that.daysPerTerm,_that.repayDate,_that.remainingDay,_that.receiptAmount,_that.serviceFee,_that.repaymentAmount,_that.waivedAmount,_that.installmentNum,_that.bankCardNo,_that.bankAccountId,_that.bankAccountType,_that.bankName,_that.orderStatus,_that.orderStatusDesc,_that.updateTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.interest,_that.overdueInterest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayDetailRespDataLoanOrderDetails implements RepayDetailRespDataLoanOrderDetails {
  const _RepayDetailRespDataLoanOrderDetails({@JsonKey(name: 'appOrderId') this.appOrderId, @JsonKey(name: 'productCode') this.productCode, @JsonKey(name: 'productLogo') this.productLogo, @JsonKey(name: 'productName') this.productName, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'installmentId') this.installmentId, @JsonKey(name: 'term') this.term, @JsonKey(name: 'daysPerTerm') this.daysPerTerm, @JsonKey(name: 'repayDate') this.repayDate, @JsonKey(name: 'remainingDay') this.remainingDay, @JsonKey(name: 'receiptAmount') this.receiptAmount, @JsonKey(name: 'serviceFee') this.serviceFee, @JsonKey(name: 'repaymentAmount') this.repaymentAmount, @JsonKey(name: 'waivedAmount') this.waivedAmount, @JsonKey(name: 'installmentNum') this.installmentNum, @JsonKey(name: 'bankCardNo') this.bankCardNo, @JsonKey(name: 'bankAccountId') this.bankAccountId, @JsonKey(name: 'bankAccountType') this.bankAccountType, @JsonKey(name: 'bankName') this.bankName, @JsonKey(name: 'orderStatus') this.orderStatus, @JsonKey(name: 'orderStatusDesc') this.orderStatusDesc, @JsonKey(name: 'updateTime') this.updateTime, @JsonKey(name: 'acqChannel') this.acqChannel, @JsonKey(name: 'closeTime') this.closeTime, @JsonKey(name: 'rejectTime') this.rejectTime, @JsonKey(name: 'interest') this.interest, @JsonKey(name: 'overdueInterest') this.overdueInterest});
  factory _RepayDetailRespDataLoanOrderDetails.fromJson(Map<String, dynamic> json) => _$RepayDetailRespDataLoanOrderDetailsFromJson(json);

@override@JsonKey(name: 'appOrderId') final  String? appOrderId;
@override@JsonKey(name: 'productCode') final  String? productCode;
@override@JsonKey(name: 'productLogo') final  String? productLogo;
@override@JsonKey(name: 'productName') final  String? productName;
@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'installmentId') final  int? installmentId;
@override@JsonKey(name: 'term') final  int? term;
@override@JsonKey(name: 'daysPerTerm') final  int? daysPerTerm;
@override@JsonKey(name: 'repayDate') final  String? repayDate;
@override@JsonKey(name: 'remainingDay') final  int? remainingDay;
@override@JsonKey(name: 'receiptAmount') final  num? receiptAmount;
@override@JsonKey(name: 'serviceFee') final  num? serviceFee;
@override@JsonKey(name: 'repaymentAmount') final  num? repaymentAmount;
@override@JsonKey(name: 'waivedAmount') final  num? waivedAmount;
@override@JsonKey(name: 'installmentNum') final  int? installmentNum;
@override@JsonKey(name: 'bankCardNo') final  String? bankCardNo;
@override@JsonKey(name: 'bankAccountId') final  int? bankAccountId;
@override@JsonKey(name: 'bankAccountType') final  String? bankAccountType;
@override@JsonKey(name: 'bankName') final  String? bankName;
@override@JsonKey(name: 'orderStatus') final  int? orderStatus;
@override@JsonKey(name: 'orderStatusDesc') final  String? orderStatusDesc;
@override@JsonKey(name: 'updateTime') final  String? updateTime;
@override@JsonKey(name: 'acqChannel') final  String? acqChannel;
@override@JsonKey(name: 'closeTime') final  int? closeTime;
@override@JsonKey(name: 'rejectTime') final  int? rejectTime;
@override@JsonKey(name: 'interest') final  num? interest;
@override@JsonKey(name: 'overdueInterest') final  num? overdueInterest;

/// Create a copy of RepayDetailRespDataLoanOrderDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayDetailRespDataLoanOrderDetailsCopyWith<_RepayDetailRespDataLoanOrderDetails> get copyWith => __$RepayDetailRespDataLoanOrderDetailsCopyWithImpl<_RepayDetailRespDataLoanOrderDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayDetailRespDataLoanOrderDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayDetailRespDataLoanOrderDetails&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.installmentId, installmentId) || other.installmentId == installmentId)&&(identical(other.term, term) || other.term == term)&&(identical(other.daysPerTerm, daysPerTerm) || other.daysPerTerm == daysPerTerm)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.remainingDay, remainingDay) || other.remainingDay == remainingDay)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.waivedAmount, waivedAmount) || other.waivedAmount == waivedAmount)&&(identical(other.installmentNum, installmentNum) || other.installmentNum == installmentNum)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankAccountId, bankAccountId) || other.bankAccountId == bankAccountId)&&(identical(other.bankAccountType, bankAccountType) || other.bankAccountType == bankAccountType)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusDesc, orderStatusDesc) || other.orderStatusDesc == orderStatusDesc)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime)&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.overdueInterest, overdueInterest) || other.overdueInterest == overdueInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,appOrderId,productCode,productLogo,productName,loanAmount,installmentId,term,daysPerTerm,repayDate,remainingDay,receiptAmount,serviceFee,repaymentAmount,waivedAmount,installmentNum,bankCardNo,bankAccountId,bankAccountType,bankName,orderStatus,orderStatusDesc,updateTime,acqChannel,closeTime,rejectTime,interest,overdueInterest]);

@override
String toString() {
  return 'RepayDetailRespDataLoanOrderDetails(appOrderId: $appOrderId, productCode: $productCode, productLogo: $productLogo, productName: $productName, loanAmount: $loanAmount, installmentId: $installmentId, term: $term, daysPerTerm: $daysPerTerm, repayDate: $repayDate, remainingDay: $remainingDay, receiptAmount: $receiptAmount, serviceFee: $serviceFee, repaymentAmount: $repaymentAmount, waivedAmount: $waivedAmount, installmentNum: $installmentNum, bankCardNo: $bankCardNo, bankAccountId: $bankAccountId, bankAccountType: $bankAccountType, bankName: $bankName, orderStatus: $orderStatus, orderStatusDesc: $orderStatusDesc, updateTime: $updateTime, acqChannel: $acqChannel, closeTime: $closeTime, rejectTime: $rejectTime, interest: $interest, overdueInterest: $overdueInterest)';
}


}

/// @nodoc
abstract mixin class _$RepayDetailRespDataLoanOrderDetailsCopyWith<$Res> implements $RepayDetailRespDataLoanOrderDetailsCopyWith<$Res> {
  factory _$RepayDetailRespDataLoanOrderDetailsCopyWith(_RepayDetailRespDataLoanOrderDetails value, $Res Function(_RepayDetailRespDataLoanOrderDetails) _then) = __$RepayDetailRespDataLoanOrderDetailsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'productCode') String? productCode,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'installmentId') int? installmentId,@JsonKey(name: 'term') int? term,@JsonKey(name: 'daysPerTerm') int? daysPerTerm,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'remainingDay') int? remainingDay,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'waivedAmount') num? waivedAmount,@JsonKey(name: 'installmentNum') int? installmentNum,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankAccountId') int? bankAccountId,@JsonKey(name: 'bankAccountType') String? bankAccountType,@JsonKey(name: 'bankName') String? bankName,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusDesc') String? orderStatusDesc,@JsonKey(name: 'updateTime') String? updateTime,@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'closeTime') int? closeTime,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'overdueInterest') num? overdueInterest
});




}
/// @nodoc
class __$RepayDetailRespDataLoanOrderDetailsCopyWithImpl<$Res>
    implements _$RepayDetailRespDataLoanOrderDetailsCopyWith<$Res> {
  __$RepayDetailRespDataLoanOrderDetailsCopyWithImpl(this._self, this._then);

  final _RepayDetailRespDataLoanOrderDetails _self;
  final $Res Function(_RepayDetailRespDataLoanOrderDetails) _then;

/// Create a copy of RepayDetailRespDataLoanOrderDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appOrderId = freezed,Object? productCode = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? loanAmount = freezed,Object? installmentId = freezed,Object? term = freezed,Object? daysPerTerm = freezed,Object? repayDate = freezed,Object? remainingDay = freezed,Object? receiptAmount = freezed,Object? serviceFee = freezed,Object? repaymentAmount = freezed,Object? waivedAmount = freezed,Object? installmentNum = freezed,Object? bankCardNo = freezed,Object? bankAccountId = freezed,Object? bankAccountType = freezed,Object? bankName = freezed,Object? orderStatus = freezed,Object? orderStatusDesc = freezed,Object? updateTime = freezed,Object? acqChannel = freezed,Object? closeTime = freezed,Object? rejectTime = freezed,Object? interest = freezed,Object? overdueInterest = freezed,}) {
  return _then(_RepayDetailRespDataLoanOrderDetails(
appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,installmentId: freezed == installmentId ? _self.installmentId : installmentId // ignore: cast_nullable_to_non_nullable
as int?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,daysPerTerm: freezed == daysPerTerm ? _self.daysPerTerm : daysPerTerm // ignore: cast_nullable_to_non_nullable
as int?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,remainingDay: freezed == remainingDay ? _self.remainingDay : remainingDay // ignore: cast_nullable_to_non_nullable
as int?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,waivedAmount: freezed == waivedAmount ? _self.waivedAmount : waivedAmount // ignore: cast_nullable_to_non_nullable
as num?,installmentNum: freezed == installmentNum ? _self.installmentNum : installmentNum // ignore: cast_nullable_to_non_nullable
as int?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankAccountId: freezed == bankAccountId ? _self.bankAccountId : bankAccountId // ignore: cast_nullable_to_non_nullable
as int?,bankAccountType: freezed == bankAccountType ? _self.bankAccountType : bankAccountType // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusDesc: freezed == orderStatusDesc ? _self.orderStatusDesc : orderStatusDesc // ignore: cast_nullable_to_non_nullable
as String?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as int?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,overdueInterest: freezed == overdueInterest ? _self.overdueInterest : overdueInterest // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
