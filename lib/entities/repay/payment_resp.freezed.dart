// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'data') PaymentRespData? get data;@JsonKey(name: 'msg') String? get msg;
/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRespCopyWith<PaymentResp> get copyWith => _$PaymentRespCopyWithImpl<PaymentResp>(this as PaymentResp, _$identity);

  /// Serializes this PaymentResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,data,msg);

@override
String toString() {
  return 'PaymentResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class $PaymentRespCopyWith<$Res>  {
  factory $PaymentRespCopyWith(PaymentResp value, $Res Function(PaymentResp) _then) = _$PaymentRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') PaymentRespData? data,@JsonKey(name: 'msg') String? msg
});


$PaymentRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$PaymentRespCopyWithImpl<$Res>
    implements $PaymentRespCopyWith<$Res> {
  _$PaymentRespCopyWithImpl(this._self, this._then);

  final PaymentResp _self;
  final $Res Function(PaymentResp) _then;

/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PaymentRespData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $PaymentRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentResp].
extension PaymentRespPatterns on PaymentResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentResp value)  $default,){
final _that = this;
switch (_that) {
case _PaymentResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentResp value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  PaymentRespData? data, @JsonKey(name: 'msg')  String? msg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  PaymentRespData? data, @JsonKey(name: 'msg')  String? msg)  $default,) {final _that = this;
switch (_that) {
case _PaymentResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  PaymentRespData? data, @JsonKey(name: 'msg')  String? msg)?  $default,) {final _that = this;
switch (_that) {
case _PaymentResp() when $default != null:
return $default(_that.code,_that.data,_that.msg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentResp implements PaymentResp {
  const _PaymentResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'data') this.data, @JsonKey(name: 'msg') this.msg});
  factory _PaymentResp.fromJson(Map<String, dynamic> json) => _$PaymentRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'data') final  PaymentRespData? data;
@override@JsonKey(name: 'msg') final  String? msg;

/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRespCopyWith<_PaymentResp> get copyWith => __$PaymentRespCopyWithImpl<_PaymentResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,data,msg);

@override
String toString() {
  return 'PaymentResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class _$PaymentRespCopyWith<$Res> implements $PaymentRespCopyWith<$Res> {
  factory _$PaymentRespCopyWith(_PaymentResp value, $Res Function(_PaymentResp) _then) = __$PaymentRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') PaymentRespData? data,@JsonKey(name: 'msg') String? msg
});


@override $PaymentRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$PaymentRespCopyWithImpl<$Res>
    implements _$PaymentRespCopyWith<$Res> {
  __$PaymentRespCopyWithImpl(this._self, this._then);

  final _PaymentResp _self;
  final $Res Function(_PaymentResp) _then;

/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_PaymentResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PaymentRespData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PaymentResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $PaymentRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$PaymentRespData {

@JsonKey(name: 'payChannel') String? get payChannel;@JsonKey(name: 'payUrl') String? get payUrl;@JsonKey(name: 'paymentCode') String? get paymentCode;@JsonKey(name: 'productLogo') String? get productLogo;@JsonKey(name: 'productName') String? get productName;@JsonKey(name: 'repayAmount') num? get repayAmount;@JsonKey(name: 'repaymentAmount') num? get repaymentAmount;@JsonKey(name: 'type') int? get type;
/// Create a copy of PaymentRespData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRespDataCopyWith<PaymentRespData> get copyWith => _$PaymentRespDataCopyWithImpl<PaymentRespData>(this as PaymentRespData, _$identity);

  /// Serializes this PaymentRespData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRespData&&(identical(other.payChannel, payChannel) || other.payChannel == payChannel)&&(identical(other.payUrl, payUrl) || other.payUrl == payUrl)&&(identical(other.paymentCode, paymentCode) || other.paymentCode == paymentCode)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payChannel,payUrl,paymentCode,productLogo,productName,repayAmount,repaymentAmount,type);

@override
String toString() {
  return 'PaymentRespData(payChannel: $payChannel, payUrl: $payUrl, paymentCode: $paymentCode, productLogo: $productLogo, productName: $productName, repayAmount: $repayAmount, repaymentAmount: $repaymentAmount, type: $type)';
}


}

/// @nodoc
abstract mixin class $PaymentRespDataCopyWith<$Res>  {
  factory $PaymentRespDataCopyWith(PaymentRespData value, $Res Function(PaymentRespData) _then) = _$PaymentRespDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'payChannel') String? payChannel,@JsonKey(name: 'payUrl') String? payUrl,@JsonKey(name: 'paymentCode') String? paymentCode,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'type') int? type
});




}
/// @nodoc
class _$PaymentRespDataCopyWithImpl<$Res>
    implements $PaymentRespDataCopyWith<$Res> {
  _$PaymentRespDataCopyWithImpl(this._self, this._then);

  final PaymentRespData _self;
  final $Res Function(PaymentRespData) _then;

/// Create a copy of PaymentRespData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payChannel = freezed,Object? payUrl = freezed,Object? paymentCode = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? repayAmount = freezed,Object? repaymentAmount = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
payChannel: freezed == payChannel ? _self.payChannel : payChannel // ignore: cast_nullable_to_non_nullable
as String?,payUrl: freezed == payUrl ? _self.payUrl : payUrl // ignore: cast_nullable_to_non_nullable
as String?,paymentCode: freezed == paymentCode ? _self.paymentCode : paymentCode // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRespData].
extension PaymentRespDataPatterns on PaymentRespData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRespData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRespData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRespData value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRespData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRespData value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRespData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'payChannel')  String? payChannel, @JsonKey(name: 'payUrl')  String? payUrl, @JsonKey(name: 'paymentCode')  String? paymentCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'type')  int? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRespData() when $default != null:
return $default(_that.payChannel,_that.payUrl,_that.paymentCode,_that.productLogo,_that.productName,_that.repayAmount,_that.repaymentAmount,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'payChannel')  String? payChannel, @JsonKey(name: 'payUrl')  String? payUrl, @JsonKey(name: 'paymentCode')  String? paymentCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'type')  int? type)  $default,) {final _that = this;
switch (_that) {
case _PaymentRespData():
return $default(_that.payChannel,_that.payUrl,_that.paymentCode,_that.productLogo,_that.productName,_that.repayAmount,_that.repaymentAmount,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'payChannel')  String? payChannel, @JsonKey(name: 'payUrl')  String? payUrl, @JsonKey(name: 'paymentCode')  String? paymentCode, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repaymentAmount')  num? repaymentAmount, @JsonKey(name: 'type')  int? type)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRespData() when $default != null:
return $default(_that.payChannel,_that.payUrl,_that.paymentCode,_that.productLogo,_that.productName,_that.repayAmount,_that.repaymentAmount,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRespData implements PaymentRespData {
  const _PaymentRespData({@JsonKey(name: 'payChannel') this.payChannel, @JsonKey(name: 'payUrl') this.payUrl, @JsonKey(name: 'paymentCode') this.paymentCode, @JsonKey(name: 'productLogo') this.productLogo, @JsonKey(name: 'productName') this.productName, @JsonKey(name: 'repayAmount') this.repayAmount, @JsonKey(name: 'repaymentAmount') this.repaymentAmount, @JsonKey(name: 'type') this.type});
  factory _PaymentRespData.fromJson(Map<String, dynamic> json) => _$PaymentRespDataFromJson(json);

@override@JsonKey(name: 'payChannel') final  String? payChannel;
@override@JsonKey(name: 'payUrl') final  String? payUrl;
@override@JsonKey(name: 'paymentCode') final  String? paymentCode;
@override@JsonKey(name: 'productLogo') final  String? productLogo;
@override@JsonKey(name: 'productName') final  String? productName;
@override@JsonKey(name: 'repayAmount') final  num? repayAmount;
@override@JsonKey(name: 'repaymentAmount') final  num? repaymentAmount;
@override@JsonKey(name: 'type') final  int? type;

/// Create a copy of PaymentRespData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRespDataCopyWith<_PaymentRespData> get copyWith => __$PaymentRespDataCopyWithImpl<_PaymentRespData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRespDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRespData&&(identical(other.payChannel, payChannel) || other.payChannel == payChannel)&&(identical(other.payUrl, payUrl) || other.payUrl == payUrl)&&(identical(other.paymentCode, paymentCode) || other.paymentCode == paymentCode)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.repaymentAmount, repaymentAmount) || other.repaymentAmount == repaymentAmount)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payChannel,payUrl,paymentCode,productLogo,productName,repayAmount,repaymentAmount,type);

@override
String toString() {
  return 'PaymentRespData(payChannel: $payChannel, payUrl: $payUrl, paymentCode: $paymentCode, productLogo: $productLogo, productName: $productName, repayAmount: $repayAmount, repaymentAmount: $repaymentAmount, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PaymentRespDataCopyWith<$Res> implements $PaymentRespDataCopyWith<$Res> {
  factory _$PaymentRespDataCopyWith(_PaymentRespData value, $Res Function(_PaymentRespData) _then) = __$PaymentRespDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'payChannel') String? payChannel,@JsonKey(name: 'payUrl') String? payUrl,@JsonKey(name: 'paymentCode') String? paymentCode,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repaymentAmount') num? repaymentAmount,@JsonKey(name: 'type') int? type
});




}
/// @nodoc
class __$PaymentRespDataCopyWithImpl<$Res>
    implements _$PaymentRespDataCopyWith<$Res> {
  __$PaymentRespDataCopyWithImpl(this._self, this._then);

  final _PaymentRespData _self;
  final $Res Function(_PaymentRespData) _then;

/// Create a copy of PaymentRespData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payChannel = freezed,Object? payUrl = freezed,Object? paymentCode = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? repayAmount = freezed,Object? repaymentAmount = freezed,Object? type = freezed,}) {
  return _then(_PaymentRespData(
payChannel: freezed == payChannel ? _self.payChannel : payChannel // ignore: cast_nullable_to_non_nullable
as String?,payUrl: freezed == payUrl ? _self.payUrl : payUrl // ignore: cast_nullable_to_non_nullable
as String?,paymentCode: freezed == paymentCode ? _self.paymentCode : paymentCode // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repaymentAmount: freezed == repaymentAmount ? _self.repaymentAmount : repaymentAmount // ignore: cast_nullable_to_non_nullable
as num?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
