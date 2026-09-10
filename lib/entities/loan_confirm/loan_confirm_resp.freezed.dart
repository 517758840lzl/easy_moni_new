// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_confirm_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoanConfirmResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'data') LoanConfirmData? get data;@JsonKey(name: 'msg') String? get msg;
/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanConfirmRespCopyWith<LoanConfirmResp> get copyWith => _$LoanConfirmRespCopyWithImpl<LoanConfirmResp>(this as LoanConfirmResp, _$identity);

  /// Serializes this LoanConfirmResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoanConfirmResp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoanConfirmResp&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.msg, _this.msg) || other.msg == _this.msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoanConfirmResp;
  return Object.hash(runtimeType,_this.code,_this.data,_this.msg);
}

@override
String toString() {
  final _this = this as LoanConfirmResp;
  return 'LoanConfirmResp(code: ${_this.code}, data: ${_this.data}, msg: ${_this.msg})';
}


}

/// @nodoc
abstract mixin class $LoanConfirmRespCopyWith<$Res>  {
  factory $LoanConfirmRespCopyWith(LoanConfirmResp value, $Res Function(LoanConfirmResp) _then) = _$LoanConfirmRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') LoanConfirmData? data,@JsonKey(name: 'msg') String? msg
});


$LoanConfirmDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$LoanConfirmRespCopyWithImpl<$Res>
    implements $LoanConfirmRespCopyWith<$Res> {
  _$LoanConfirmRespCopyWithImpl(this._self, this._then);

  final LoanConfirmResp _self;
  final $Res Function(LoanConfirmResp) _then;

/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(LoanConfirmResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LoanConfirmData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoanConfirmDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $LoanConfirmDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoanConfirmResp].
extension LoanConfirmRespPatterns on LoanConfirmResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoanConfirmResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoanConfirmResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoanConfirmResp value)  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoanConfirmResp value)?  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  LoanConfirmData? data, @JsonKey(name: 'msg')  String? msg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoanConfirmResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  LoanConfirmData? data, @JsonKey(name: 'msg')  String? msg)  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'data')  LoanConfirmData? data, @JsonKey(name: 'msg')  String? msg)?  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmResp() when $default != null:
return $default(_that.code,_that.data,_that.msg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoanConfirmResp implements LoanConfirmResp {
  const _LoanConfirmResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'data') this.data, @JsonKey(name: 'msg') this.msg});
  factory _LoanConfirmResp.fromJson(Map<String, dynamic> json) => _$LoanConfirmRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'data') final  LoanConfirmData? data;
@override@JsonKey(name: 'msg') final  String? msg;

/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanConfirmRespCopyWith<_LoanConfirmResp> get copyWith => __$LoanConfirmRespCopyWithImpl<_LoanConfirmResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoanConfirmRespToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoanConfirmResp&&(identical(other.code, code) || other.code == code)&&(identical(other.data, data) || other.data == data)&&(identical(other.msg, msg) || other.msg == msg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,data,msg);
}

@override
String toString() {
    return 'LoanConfirmResp(code: $code, data: $data, msg: $msg)';
}


}

/// @nodoc
abstract mixin class _$LoanConfirmRespCopyWith<$Res> implements $LoanConfirmRespCopyWith<$Res> {
  factory _$LoanConfirmRespCopyWith(_LoanConfirmResp value, $Res Function(_LoanConfirmResp) _then) = __$LoanConfirmRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'data') LoanConfirmData? data,@JsonKey(name: 'msg') String? msg
});


@override $LoanConfirmDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$LoanConfirmRespCopyWithImpl<$Res>
    implements _$LoanConfirmRespCopyWith<$Res> {
  __$LoanConfirmRespCopyWithImpl(this._self, this._then);

  final _LoanConfirmResp _self;
  final $Res Function(_LoanConfirmResp) _then;

/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? data = freezed,Object? msg = freezed,}) {
  return _then(_LoanConfirmResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as LoanConfirmData?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LoanConfirmResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoanConfirmDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $LoanConfirmDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$LoanConfirmData {

@JsonKey(name: 'actualToAccountMoney') num? get actualToAccountMoney;@JsonKey(name: 'autoConfirmTips') String? get autoConfirmTips;@JsonKey(name: 'autoLoan') int? get autoLoan;@JsonKey(name: 'bankCardId') int? get bankCardId;@JsonKey(name: 'bankCardName') String? get bankCardName;@JsonKey(name: 'bankCardNo') String? get bankCardNo;@JsonKey(name: 'bankCardType') String? get bankCardType;@JsonKey(name: 'cancelAutoConfirmSwitch') int? get cancelAutoConfirmSwitch;@JsonKey(name: 'countDownTime') int? get countDownTime;@JsonKey(name: 'isPopUpConfirmAutoLoan') int? get isPopUpConfirmAutoLoan;@JsonKey(name: 'list') List<LoanConfirmOrder>? get list;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'payDate') String? get payDate;@JsonKey(name: 'rent') num? get rent;@JsonKey(name: 'repayDate') String? get repayDate;@JsonKey(name: 'serviceFee') num? get serviceFee;
/// Create a copy of LoanConfirmData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanConfirmDataCopyWith<LoanConfirmData> get copyWith => _$LoanConfirmDataCopyWithImpl<LoanConfirmData>(this as LoanConfirmData, _$identity);

  /// Serializes this LoanConfirmData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoanConfirmData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoanConfirmData&&(identical(other.actualToAccountMoney, _this.actualToAccountMoney) || other.actualToAccountMoney == _this.actualToAccountMoney)&&(identical(other.autoConfirmTips, _this.autoConfirmTips) || other.autoConfirmTips == _this.autoConfirmTips)&&(identical(other.autoLoan, _this.autoLoan) || other.autoLoan == _this.autoLoan)&&(identical(other.bankCardId, _this.bankCardId) || other.bankCardId == _this.bankCardId)&&(identical(other.bankCardName, _this.bankCardName) || other.bankCardName == _this.bankCardName)&&(identical(other.bankCardNo, _this.bankCardNo) || other.bankCardNo == _this.bankCardNo)&&(identical(other.bankCardType, _this.bankCardType) || other.bankCardType == _this.bankCardType)&&(identical(other.cancelAutoConfirmSwitch, _this.cancelAutoConfirmSwitch) || other.cancelAutoConfirmSwitch == _this.cancelAutoConfirmSwitch)&&(identical(other.countDownTime, _this.countDownTime) || other.countDownTime == _this.countDownTime)&&(identical(other.isPopUpConfirmAutoLoan, _this.isPopUpConfirmAutoLoan) || other.isPopUpConfirmAutoLoan == _this.isPopUpConfirmAutoLoan)&&const DeepCollectionEquality().equals(other.list, _this.list)&&(identical(other.loanAmount, _this.loanAmount) || other.loanAmount == _this.loanAmount)&&(identical(other.payDate, _this.payDate) || other.payDate == _this.payDate)&&(identical(other.rent, _this.rent) || other.rent == _this.rent)&&(identical(other.repayDate, _this.repayDate) || other.repayDate == _this.repayDate)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoanConfirmData;
  return Object.hash(runtimeType,_this.actualToAccountMoney,_this.autoConfirmTips,_this.autoLoan,_this.bankCardId,_this.bankCardName,_this.bankCardNo,_this.bankCardType,_this.cancelAutoConfirmSwitch,_this.countDownTime,_this.isPopUpConfirmAutoLoan,const DeepCollectionEquality().hash(_this.list),_this.loanAmount,_this.payDate,_this.rent,_this.repayDate,_this.serviceFee);
}

@override
String toString() {
  final _this = this as LoanConfirmData;
  return 'LoanConfirmData(actualToAccountMoney: ${_this.actualToAccountMoney}, autoConfirmTips: ${_this.autoConfirmTips}, autoLoan: ${_this.autoLoan}, bankCardId: ${_this.bankCardId}, bankCardName: ${_this.bankCardName}, bankCardNo: ${_this.bankCardNo}, bankCardType: ${_this.bankCardType}, cancelAutoConfirmSwitch: ${_this.cancelAutoConfirmSwitch}, countDownTime: ${_this.countDownTime}, isPopUpConfirmAutoLoan: ${_this.isPopUpConfirmAutoLoan}, list: ${_this.list}, loanAmount: ${_this.loanAmount}, payDate: ${_this.payDate}, rent: ${_this.rent}, repayDate: ${_this.repayDate}, serviceFee: ${_this.serviceFee})';
}


}

/// @nodoc
abstract mixin class $LoanConfirmDataCopyWith<$Res>  {
  factory $LoanConfirmDataCopyWith(LoanConfirmData value, $Res Function(LoanConfirmData) _then) = _$LoanConfirmDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,@JsonKey(name: 'autoConfirmTips') String? autoConfirmTips,@JsonKey(name: 'autoLoan') int? autoLoan,@JsonKey(name: 'bankCardId') int? bankCardId,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'cancelAutoConfirmSwitch') int? cancelAutoConfirmSwitch,@JsonKey(name: 'countDownTime') int? countDownTime,@JsonKey(name: 'isPopUpConfirmAutoLoan') int? isPopUpConfirmAutoLoan,@JsonKey(name: 'list') List<LoanConfirmOrder>? list,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'payDate') String? payDate,@JsonKey(name: 'rent') num? rent,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'serviceFee') num? serviceFee
});




}
/// @nodoc
class _$LoanConfirmDataCopyWithImpl<$Res>
    implements $LoanConfirmDataCopyWith<$Res> {
  _$LoanConfirmDataCopyWithImpl(this._self, this._then);

  final LoanConfirmData _self;
  final $Res Function(LoanConfirmData) _then;

/// Create a copy of LoanConfirmData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actualToAccountMoney = freezed,Object? autoConfirmTips = freezed,Object? autoLoan = freezed,Object? bankCardId = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? cancelAutoConfirmSwitch = freezed,Object? countDownTime = freezed,Object? isPopUpConfirmAutoLoan = freezed,Object? list = freezed,Object? loanAmount = freezed,Object? payDate = freezed,Object? rent = freezed,Object? repayDate = freezed,Object? serviceFee = freezed,}) {
  return _then(LoanConfirmData(
actualToAccountMoney: freezed == actualToAccountMoney ? _self.actualToAccountMoney : actualToAccountMoney // ignore: cast_nullable_to_non_nullable
as num?,autoConfirmTips: freezed == autoConfirmTips ? _self.autoConfirmTips : autoConfirmTips // ignore: cast_nullable_to_non_nullable
as String?,autoLoan: freezed == autoLoan ? _self.autoLoan : autoLoan // ignore: cast_nullable_to_non_nullable
as int?,bankCardId: freezed == bankCardId ? _self.bankCardId : bankCardId // ignore: cast_nullable_to_non_nullable
as int?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,cancelAutoConfirmSwitch: freezed == cancelAutoConfirmSwitch ? _self.cancelAutoConfirmSwitch : cancelAutoConfirmSwitch // ignore: cast_nullable_to_non_nullable
as int?,countDownTime: freezed == countDownTime ? _self.countDownTime : countDownTime // ignore: cast_nullable_to_non_nullable
as int?,isPopUpConfirmAutoLoan: freezed == isPopUpConfirmAutoLoan ? _self.isPopUpConfirmAutoLoan : isPopUpConfirmAutoLoan // ignore: cast_nullable_to_non_nullable
as int?,list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as List<LoanConfirmOrder>?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,payDate: freezed == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as String?,rent: freezed == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoanConfirmData].
extension LoanConfirmDataPatterns on LoanConfirmData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoanConfirmData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoanConfirmData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoanConfirmData value)  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoanConfirmData value)?  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'autoConfirmTips')  String? autoConfirmTips, @JsonKey(name: 'autoLoan')  int? autoLoan, @JsonKey(name: 'bankCardId')  int? bankCardId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'cancelAutoConfirmSwitch')  int? cancelAutoConfirmSwitch, @JsonKey(name: 'countDownTime')  int? countDownTime, @JsonKey(name: 'isPopUpConfirmAutoLoan')  int? isPopUpConfirmAutoLoan, @JsonKey(name: 'list')  List<LoanConfirmOrder>? list, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'payDate')  String? payDate, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'serviceFee')  num? serviceFee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoanConfirmData() when $default != null:
return $default(_that.actualToAccountMoney,_that.autoConfirmTips,_that.autoLoan,_that.bankCardId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.cancelAutoConfirmSwitch,_that.countDownTime,_that.isPopUpConfirmAutoLoan,_that.list,_that.loanAmount,_that.payDate,_that.rent,_that.repayDate,_that.serviceFee);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'autoConfirmTips')  String? autoConfirmTips, @JsonKey(name: 'autoLoan')  int? autoLoan, @JsonKey(name: 'bankCardId')  int? bankCardId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'cancelAutoConfirmSwitch')  int? cancelAutoConfirmSwitch, @JsonKey(name: 'countDownTime')  int? countDownTime, @JsonKey(name: 'isPopUpConfirmAutoLoan')  int? isPopUpConfirmAutoLoan, @JsonKey(name: 'list')  List<LoanConfirmOrder>? list, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'payDate')  String? payDate, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'serviceFee')  num? serviceFee)  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmData():
return $default(_that.actualToAccountMoney,_that.autoConfirmTips,_that.autoLoan,_that.bankCardId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.cancelAutoConfirmSwitch,_that.countDownTime,_that.isPopUpConfirmAutoLoan,_that.list,_that.loanAmount,_that.payDate,_that.rent,_that.repayDate,_that.serviceFee);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'actualToAccountMoney')  num? actualToAccountMoney, @JsonKey(name: 'autoConfirmTips')  String? autoConfirmTips, @JsonKey(name: 'autoLoan')  int? autoLoan, @JsonKey(name: 'bankCardId')  int? bankCardId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'cancelAutoConfirmSwitch')  int? cancelAutoConfirmSwitch, @JsonKey(name: 'countDownTime')  int? countDownTime, @JsonKey(name: 'isPopUpConfirmAutoLoan')  int? isPopUpConfirmAutoLoan, @JsonKey(name: 'list')  List<LoanConfirmOrder>? list, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'payDate')  String? payDate, @JsonKey(name: 'rent')  num? rent, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'serviceFee')  num? serviceFee)?  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmData() when $default != null:
return $default(_that.actualToAccountMoney,_that.autoConfirmTips,_that.autoLoan,_that.bankCardId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.cancelAutoConfirmSwitch,_that.countDownTime,_that.isPopUpConfirmAutoLoan,_that.list,_that.loanAmount,_that.payDate,_that.rent,_that.repayDate,_that.serviceFee);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoanConfirmData implements LoanConfirmData {
  const _LoanConfirmData({@JsonKey(name: 'actualToAccountMoney') this.actualToAccountMoney, @JsonKey(name: 'autoConfirmTips') this.autoConfirmTips, @JsonKey(name: 'autoLoan') this.autoLoan, @JsonKey(name: 'bankCardId') this.bankCardId, @JsonKey(name: 'bankCardName') this.bankCardName, @JsonKey(name: 'bankCardNo') this.bankCardNo, @JsonKey(name: 'bankCardType') this.bankCardType, @JsonKey(name: 'cancelAutoConfirmSwitch') this.cancelAutoConfirmSwitch, @JsonKey(name: 'countDownTime') this.countDownTime, @JsonKey(name: 'isPopUpConfirmAutoLoan') this.isPopUpConfirmAutoLoan, @JsonKey(name: 'list')  List<LoanConfirmOrder>? list, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'payDate') this.payDate, @JsonKey(name: 'rent') this.rent, @JsonKey(name: 'repayDate') this.repayDate, @JsonKey(name: 'serviceFee') this.serviceFee}): _list = list;
  factory _LoanConfirmData.fromJson(Map<String, dynamic> json) => _$LoanConfirmDataFromJson(json);

@override@JsonKey(name: 'actualToAccountMoney') final  num? actualToAccountMoney;
@override@JsonKey(name: 'autoConfirmTips') final  String? autoConfirmTips;
@override@JsonKey(name: 'autoLoan') final  int? autoLoan;
@override@JsonKey(name: 'bankCardId') final  int? bankCardId;
@override@JsonKey(name: 'bankCardName') final  String? bankCardName;
@override@JsonKey(name: 'bankCardNo') final  String? bankCardNo;
@override@JsonKey(name: 'bankCardType') final  String? bankCardType;
@override@JsonKey(name: 'cancelAutoConfirmSwitch') final  int? cancelAutoConfirmSwitch;
@override@JsonKey(name: 'countDownTime') final  int? countDownTime;
@override@JsonKey(name: 'isPopUpConfirmAutoLoan') final  int? isPopUpConfirmAutoLoan;
 final  List<LoanConfirmOrder>? _list;
@override@JsonKey(name: 'list') List<LoanConfirmOrder>? get list {
  final value = _list;
  if (value == null) return null;
  if (_list is EqualUnmodifiableListView) return _list;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'payDate') final  String? payDate;
@override@JsonKey(name: 'rent') final  num? rent;
@override@JsonKey(name: 'repayDate') final  String? repayDate;
@override@JsonKey(name: 'serviceFee') final  num? serviceFee;

/// Create a copy of LoanConfirmData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanConfirmDataCopyWith<_LoanConfirmData> get copyWith => __$LoanConfirmDataCopyWithImpl<_LoanConfirmData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoanConfirmDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoanConfirmData&&(identical(other.actualToAccountMoney, actualToAccountMoney) || other.actualToAccountMoney == actualToAccountMoney)&&(identical(other.autoConfirmTips, autoConfirmTips) || other.autoConfirmTips == autoConfirmTips)&&(identical(other.autoLoan, autoLoan) || other.autoLoan == autoLoan)&&(identical(other.bankCardId, bankCardId) || other.bankCardId == bankCardId)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.cancelAutoConfirmSwitch, cancelAutoConfirmSwitch) || other.cancelAutoConfirmSwitch == cancelAutoConfirmSwitch)&&(identical(other.countDownTime, countDownTime) || other.countDownTime == countDownTime)&&(identical(other.isPopUpConfirmAutoLoan, isPopUpConfirmAutoLoan) || other.isPopUpConfirmAutoLoan == isPopUpConfirmAutoLoan)&&const DeepCollectionEquality().equals(other.list, _list)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.payDate, payDate) || other.payDate == payDate)&&(identical(other.rent, rent) || other.rent == rent)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,actualToAccountMoney,autoConfirmTips,autoLoan,bankCardId,bankCardName,bankCardNo,bankCardType,cancelAutoConfirmSwitch,countDownTime,isPopUpConfirmAutoLoan,const DeepCollectionEquality().hash(_list),loanAmount,payDate,rent,repayDate,serviceFee);
}

@override
String toString() {
    return 'LoanConfirmData(actualToAccountMoney: $actualToAccountMoney, autoConfirmTips: $autoConfirmTips, autoLoan: $autoLoan, bankCardId: $bankCardId, bankCardName: $bankCardName, bankCardNo: $bankCardNo, bankCardType: $bankCardType, cancelAutoConfirmSwitch: $cancelAutoConfirmSwitch, countDownTime: $countDownTime, isPopUpConfirmAutoLoan: $isPopUpConfirmAutoLoan, list: $list, loanAmount: $loanAmount, payDate: $payDate, rent: $rent, repayDate: $repayDate, serviceFee: $serviceFee)';
}


}

/// @nodoc
abstract mixin class _$LoanConfirmDataCopyWith<$Res> implements $LoanConfirmDataCopyWith<$Res> {
  factory _$LoanConfirmDataCopyWith(_LoanConfirmData value, $Res Function(_LoanConfirmData) _then) = __$LoanConfirmDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'actualToAccountMoney') num? actualToAccountMoney,@JsonKey(name: 'autoConfirmTips') String? autoConfirmTips,@JsonKey(name: 'autoLoan') int? autoLoan,@JsonKey(name: 'bankCardId') int? bankCardId,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'cancelAutoConfirmSwitch') int? cancelAutoConfirmSwitch,@JsonKey(name: 'countDownTime') int? countDownTime,@JsonKey(name: 'isPopUpConfirmAutoLoan') int? isPopUpConfirmAutoLoan,@JsonKey(name: 'list') List<LoanConfirmOrder>? list,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'payDate') String? payDate,@JsonKey(name: 'rent') num? rent,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'serviceFee') num? serviceFee
});




}
/// @nodoc
class __$LoanConfirmDataCopyWithImpl<$Res>
    implements _$LoanConfirmDataCopyWith<$Res> {
  __$LoanConfirmDataCopyWithImpl(this._self, this._then);

  final _LoanConfirmData _self;
  final $Res Function(_LoanConfirmData) _then;

/// Create a copy of LoanConfirmData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actualToAccountMoney = freezed,Object? autoConfirmTips = freezed,Object? autoLoan = freezed,Object? bankCardId = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? cancelAutoConfirmSwitch = freezed,Object? countDownTime = freezed,Object? isPopUpConfirmAutoLoan = freezed,Object? list = freezed,Object? loanAmount = freezed,Object? payDate = freezed,Object? rent = freezed,Object? repayDate = freezed,Object? serviceFee = freezed,}) {
  return _then(_LoanConfirmData(
actualToAccountMoney: freezed == actualToAccountMoney ? _self.actualToAccountMoney : actualToAccountMoney // ignore: cast_nullable_to_non_nullable
as num?,autoConfirmTips: freezed == autoConfirmTips ? _self.autoConfirmTips : autoConfirmTips // ignore: cast_nullable_to_non_nullable
as String?,autoLoan: freezed == autoLoan ? _self.autoLoan : autoLoan // ignore: cast_nullable_to_non_nullable
as int?,bankCardId: freezed == bankCardId ? _self.bankCardId : bankCardId // ignore: cast_nullable_to_non_nullable
as int?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,cancelAutoConfirmSwitch: freezed == cancelAutoConfirmSwitch ? _self.cancelAutoConfirmSwitch : cancelAutoConfirmSwitch // ignore: cast_nullable_to_non_nullable
as int?,countDownTime: freezed == countDownTime ? _self.countDownTime : countDownTime // ignore: cast_nullable_to_non_nullable
as int?,isPopUpConfirmAutoLoan: freezed == isPopUpConfirmAutoLoan ? _self.isPopUpConfirmAutoLoan : isPopUpConfirmAutoLoan // ignore: cast_nullable_to_non_nullable
as int?,list: freezed == list ? _self._list : list // ignore: cast_nullable_to_non_nullable
as List<LoanConfirmOrder>?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,payDate: freezed == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as String?,rent: freezed == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}


/// @nodoc
mixin _$LoanConfirmOrder {

@JsonKey(name: 'actualToAccount') num? get actualToAccount;@JsonKey(name: 'appOrderId') int? get appOrderId;@JsonKey(name: 'appOrderIdStr') String? get appOrderIdStr;@JsonKey(name: 'appOrderStatus') int? get appOrderStatus;@JsonKey(name: 'bankCardName') String? get bankCardName;@JsonKey(name: 'bankCardNo') String? get bankCardNo;@JsonKey(name: 'bankCardType') String? get bankCardType;@JsonKey(name: 'borrowRetryDate') String? get borrowRetryDate;@JsonKey(name: 'customerLevelUnlock') int? get customerLevelUnlock;@JsonKey(name: 'dailyInterestRateFrom') num? get dailyInterestRateFrom;@JsonKey(name: 'dailyInterestRateTo') num? get dailyInterestRateTo;@JsonKey(name: 'daysPerTermFrom') int? get daysPerTermFrom;@JsonKey(name: 'daysPerTermTo') int? get daysPerTermTo;@JsonKey(name: 'dueDate') String? get dueDate;@JsonKey(name: 'interest') num? get interest;@JsonKey(name: 'isExtensionSwitch') bool? get isExtensionSwitch;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'loanLimitFrom') num? get loanLimitFrom;@JsonKey(name: 'loanLimitTo') num? get loanLimitTo;@JsonKey(name: 'productAccount') num? get productAccount;@JsonKey(name: 'productCode') String? get productCode;@JsonKey(name: 'productInterest') num? get productInterest;@JsonKey(name: 'productLevel') int? get productLevel;@JsonKey(name: 'productLogo') String? get productLogo;@JsonKey(name: 'productName') String? get productName;@JsonKey(name: 'productStatus') int? get productStatus;@JsonKey(name: 'receiptAmount') num? get receiptAmount;@JsonKey(name: 'remainingDays') int? get remainingDays;@JsonKey(name: 'repaidAmount') num? get repaidAmount;@JsonKey(name: 'repayAmount') num? get repayAmount;@JsonKey(name: 'repayDate') String? get repayDate;@JsonKey(name: 'repayDateStr') String? get repayDateStr;@JsonKey(name: 'serviceFee') num? get serviceFee;@JsonKey(name: 'term') int? get term;@JsonKey(name: 'totalServiceDays') int? get totalServiceDays;
/// Create a copy of LoanConfirmOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanConfirmOrderCopyWith<LoanConfirmOrder> get copyWith => _$LoanConfirmOrderCopyWithImpl<LoanConfirmOrder>(this as LoanConfirmOrder, _$identity);

  /// Serializes this LoanConfirmOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoanConfirmOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoanConfirmOrder&&(identical(other.actualToAccount, _this.actualToAccount) || other.actualToAccount == _this.actualToAccount)&&(identical(other.appOrderId, _this.appOrderId) || other.appOrderId == _this.appOrderId)&&(identical(other.appOrderIdStr, _this.appOrderIdStr) || other.appOrderIdStr == _this.appOrderIdStr)&&(identical(other.appOrderStatus, _this.appOrderStatus) || other.appOrderStatus == _this.appOrderStatus)&&(identical(other.bankCardName, _this.bankCardName) || other.bankCardName == _this.bankCardName)&&(identical(other.bankCardNo, _this.bankCardNo) || other.bankCardNo == _this.bankCardNo)&&(identical(other.bankCardType, _this.bankCardType) || other.bankCardType == _this.bankCardType)&&(identical(other.borrowRetryDate, _this.borrowRetryDate) || other.borrowRetryDate == _this.borrowRetryDate)&&(identical(other.customerLevelUnlock, _this.customerLevelUnlock) || other.customerLevelUnlock == _this.customerLevelUnlock)&&(identical(other.dailyInterestRateFrom, _this.dailyInterestRateFrom) || other.dailyInterestRateFrom == _this.dailyInterestRateFrom)&&(identical(other.dailyInterestRateTo, _this.dailyInterestRateTo) || other.dailyInterestRateTo == _this.dailyInterestRateTo)&&(identical(other.daysPerTermFrom, _this.daysPerTermFrom) || other.daysPerTermFrom == _this.daysPerTermFrom)&&(identical(other.daysPerTermTo, _this.daysPerTermTo) || other.daysPerTermTo == _this.daysPerTermTo)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.interest, _this.interest) || other.interest == _this.interest)&&(identical(other.isExtensionSwitch, _this.isExtensionSwitch) || other.isExtensionSwitch == _this.isExtensionSwitch)&&(identical(other.loanAmount, _this.loanAmount) || other.loanAmount == _this.loanAmount)&&(identical(other.loanLimitFrom, _this.loanLimitFrom) || other.loanLimitFrom == _this.loanLimitFrom)&&(identical(other.loanLimitTo, _this.loanLimitTo) || other.loanLimitTo == _this.loanLimitTo)&&(identical(other.productAccount, _this.productAccount) || other.productAccount == _this.productAccount)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productInterest, _this.productInterest) || other.productInterest == _this.productInterest)&&(identical(other.productLevel, _this.productLevel) || other.productLevel == _this.productLevel)&&(identical(other.productLogo, _this.productLogo) || other.productLogo == _this.productLogo)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.productStatus, _this.productStatus) || other.productStatus == _this.productStatus)&&(identical(other.receiptAmount, _this.receiptAmount) || other.receiptAmount == _this.receiptAmount)&&(identical(other.remainingDays, _this.remainingDays) || other.remainingDays == _this.remainingDays)&&(identical(other.repaidAmount, _this.repaidAmount) || other.repaidAmount == _this.repaidAmount)&&(identical(other.repayAmount, _this.repayAmount) || other.repayAmount == _this.repayAmount)&&(identical(other.repayDate, _this.repayDate) || other.repayDate == _this.repayDate)&&(identical(other.repayDateStr, _this.repayDateStr) || other.repayDateStr == _this.repayDateStr)&&(identical(other.serviceFee, _this.serviceFee) || other.serviceFee == _this.serviceFee)&&(identical(other.term, _this.term) || other.term == _this.term)&&(identical(other.totalServiceDays, _this.totalServiceDays) || other.totalServiceDays == _this.totalServiceDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoanConfirmOrder;
  return Object.hashAll([runtimeType,_this.actualToAccount,_this.appOrderId,_this.appOrderIdStr,_this.appOrderStatus,_this.bankCardName,_this.bankCardNo,_this.bankCardType,_this.borrowRetryDate,_this.customerLevelUnlock,_this.dailyInterestRateFrom,_this.dailyInterestRateTo,_this.daysPerTermFrom,_this.daysPerTermTo,_this.dueDate,_this.interest,_this.isExtensionSwitch,_this.loanAmount,_this.loanLimitFrom,_this.loanLimitTo,_this.productAccount,_this.productCode,_this.productInterest,_this.productLevel,_this.productLogo,_this.productName,_this.productStatus,_this.receiptAmount,_this.remainingDays,_this.repaidAmount,_this.repayAmount,_this.repayDate,_this.repayDateStr,_this.serviceFee,_this.term,_this.totalServiceDays]);
}

@override
String toString() {
  final _this = this as LoanConfirmOrder;
  return 'LoanConfirmOrder(actualToAccount: ${_this.actualToAccount}, appOrderId: ${_this.appOrderId}, appOrderIdStr: ${_this.appOrderIdStr}, appOrderStatus: ${_this.appOrderStatus}, bankCardName: ${_this.bankCardName}, bankCardNo: ${_this.bankCardNo}, bankCardType: ${_this.bankCardType}, borrowRetryDate: ${_this.borrowRetryDate}, customerLevelUnlock: ${_this.customerLevelUnlock}, dailyInterestRateFrom: ${_this.dailyInterestRateFrom}, dailyInterestRateTo: ${_this.dailyInterestRateTo}, daysPerTermFrom: ${_this.daysPerTermFrom}, daysPerTermTo: ${_this.daysPerTermTo}, dueDate: ${_this.dueDate}, interest: ${_this.interest}, isExtensionSwitch: ${_this.isExtensionSwitch}, loanAmount: ${_this.loanAmount}, loanLimitFrom: ${_this.loanLimitFrom}, loanLimitTo: ${_this.loanLimitTo}, productAccount: ${_this.productAccount}, productCode: ${_this.productCode}, productInterest: ${_this.productInterest}, productLevel: ${_this.productLevel}, productLogo: ${_this.productLogo}, productName: ${_this.productName}, productStatus: ${_this.productStatus}, receiptAmount: ${_this.receiptAmount}, remainingDays: ${_this.remainingDays}, repaidAmount: ${_this.repaidAmount}, repayAmount: ${_this.repayAmount}, repayDate: ${_this.repayDate}, repayDateStr: ${_this.repayDateStr}, serviceFee: ${_this.serviceFee}, term: ${_this.term}, totalServiceDays: ${_this.totalServiceDays})';
}


}

/// @nodoc
abstract mixin class $LoanConfirmOrderCopyWith<$Res>  {
  factory $LoanConfirmOrderCopyWith(LoanConfirmOrder value, $Res Function(LoanConfirmOrder) _then) = _$LoanConfirmOrderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'actualToAccount') num? actualToAccount,@JsonKey(name: 'appOrderId') int? appOrderId,@JsonKey(name: 'appOrderIdStr') String? appOrderIdStr,@JsonKey(name: 'appOrderStatus') int? appOrderStatus,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'borrowRetryDate') String? borrowRetryDate,@JsonKey(name: 'customerLevelUnlock') int? customerLevelUnlock,@JsonKey(name: 'dailyInterestRateFrom') num? dailyInterestRateFrom,@JsonKey(name: 'dailyInterestRateTo') num? dailyInterestRateTo,@JsonKey(name: 'daysPerTermFrom') int? daysPerTermFrom,@JsonKey(name: 'daysPerTermTo') int? daysPerTermTo,@JsonKey(name: 'dueDate') String? dueDate,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'loanLimitFrom') num? loanLimitFrom,@JsonKey(name: 'loanLimitTo') num? loanLimitTo,@JsonKey(name: 'productAccount') num? productAccount,@JsonKey(name: 'productCode') String? productCode,@JsonKey(name: 'productInterest') num? productInterest,@JsonKey(name: 'productLevel') int? productLevel,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productStatus') int? productStatus,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays
});




}
/// @nodoc
class _$LoanConfirmOrderCopyWithImpl<$Res>
    implements $LoanConfirmOrderCopyWith<$Res> {
  _$LoanConfirmOrderCopyWithImpl(this._self, this._then);

  final LoanConfirmOrder _self;
  final $Res Function(LoanConfirmOrder) _then;

/// Create a copy of LoanConfirmOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actualToAccount = freezed,Object? appOrderId = freezed,Object? appOrderIdStr = freezed,Object? appOrderStatus = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? borrowRetryDate = freezed,Object? customerLevelUnlock = freezed,Object? dailyInterestRateFrom = freezed,Object? dailyInterestRateTo = freezed,Object? daysPerTermFrom = freezed,Object? daysPerTermTo = freezed,Object? dueDate = freezed,Object? interest = freezed,Object? isExtensionSwitch = freezed,Object? loanAmount = freezed,Object? loanLimitFrom = freezed,Object? loanLimitTo = freezed,Object? productAccount = freezed,Object? productCode = freezed,Object? productInterest = freezed,Object? productLevel = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? productStatus = freezed,Object? receiptAmount = freezed,Object? remainingDays = freezed,Object? repaidAmount = freezed,Object? repayAmount = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? serviceFee = freezed,Object? term = freezed,Object? totalServiceDays = freezed,}) {
  return _then(LoanConfirmOrder(
actualToAccount: freezed == actualToAccount ? _self.actualToAccount : actualToAccount // ignore: cast_nullable_to_non_nullable
as num?,appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as int?,appOrderIdStr: freezed == appOrderIdStr ? _self.appOrderIdStr : appOrderIdStr // ignore: cast_nullable_to_non_nullable
as String?,appOrderStatus: freezed == appOrderStatus ? _self.appOrderStatus : appOrderStatus // ignore: cast_nullable_to_non_nullable
as int?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,borrowRetryDate: freezed == borrowRetryDate ? _self.borrowRetryDate : borrowRetryDate // ignore: cast_nullable_to_non_nullable
as String?,customerLevelUnlock: freezed == customerLevelUnlock ? _self.customerLevelUnlock : customerLevelUnlock // ignore: cast_nullable_to_non_nullable
as int?,dailyInterestRateFrom: freezed == dailyInterestRateFrom ? _self.dailyInterestRateFrom : dailyInterestRateFrom // ignore: cast_nullable_to_non_nullable
as num?,dailyInterestRateTo: freezed == dailyInterestRateTo ? _self.dailyInterestRateTo : dailyInterestRateTo // ignore: cast_nullable_to_non_nullable
as num?,daysPerTermFrom: freezed == daysPerTermFrom ? _self.daysPerTermFrom : daysPerTermFrom // ignore: cast_nullable_to_non_nullable
as int?,daysPerTermTo: freezed == daysPerTermTo ? _self.daysPerTermTo : daysPerTermTo // ignore: cast_nullable_to_non_nullable
as int?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,loanLimitFrom: freezed == loanLimitFrom ? _self.loanLimitFrom : loanLimitFrom // ignore: cast_nullable_to_non_nullable
as num?,loanLimitTo: freezed == loanLimitTo ? _self.loanLimitTo : loanLimitTo // ignore: cast_nullable_to_non_nullable
as num?,productAccount: freezed == productAccount ? _self.productAccount : productAccount // ignore: cast_nullable_to_non_nullable
as num?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productInterest: freezed == productInterest ? _self.productInterest : productInterest // ignore: cast_nullable_to_non_nullable
as num?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as int?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productStatus: freezed == productStatus ? _self.productStatus : productStatus // ignore: cast_nullable_to_non_nullable
as int?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoanConfirmOrder].
extension LoanConfirmOrderPatterns on LoanConfirmOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoanConfirmOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoanConfirmOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoanConfirmOrder value)  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoanConfirmOrder value)?  $default,){
final _that = this;
switch (_that) {
case _LoanConfirmOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccount')  num? actualToAccount, @JsonKey(name: 'appOrderId')  int? appOrderId, @JsonKey(name: 'appOrderIdStr')  String? appOrderIdStr, @JsonKey(name: 'appOrderStatus')  int? appOrderStatus, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'borrowRetryDate')  String? borrowRetryDate, @JsonKey(name: 'customerLevelUnlock')  int? customerLevelUnlock, @JsonKey(name: 'dailyInterestRateFrom')  num? dailyInterestRateFrom, @JsonKey(name: 'dailyInterestRateTo')  num? dailyInterestRateTo, @JsonKey(name: 'daysPerTermFrom')  int? daysPerTermFrom, @JsonKey(name: 'daysPerTermTo')  int? daysPerTermTo, @JsonKey(name: 'dueDate')  String? dueDate, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'loanLimitFrom')  num? loanLimitFrom, @JsonKey(name: 'loanLimitTo')  num? loanLimitTo, @JsonKey(name: 'productAccount')  num? productAccount, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productInterest')  num? productInterest, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productStatus')  int? productStatus, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoanConfirmOrder() when $default != null:
return $default(_that.actualToAccount,_that.appOrderId,_that.appOrderIdStr,_that.appOrderStatus,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.borrowRetryDate,_that.customerLevelUnlock,_that.dailyInterestRateFrom,_that.dailyInterestRateTo,_that.daysPerTermFrom,_that.daysPerTermTo,_that.dueDate,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.loanLimitFrom,_that.loanLimitTo,_that.productAccount,_that.productCode,_that.productInterest,_that.productLevel,_that.productLogo,_that.productName,_that.productStatus,_that.receiptAmount,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.serviceFee,_that.term,_that.totalServiceDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'actualToAccount')  num? actualToAccount, @JsonKey(name: 'appOrderId')  int? appOrderId, @JsonKey(name: 'appOrderIdStr')  String? appOrderIdStr, @JsonKey(name: 'appOrderStatus')  int? appOrderStatus, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'borrowRetryDate')  String? borrowRetryDate, @JsonKey(name: 'customerLevelUnlock')  int? customerLevelUnlock, @JsonKey(name: 'dailyInterestRateFrom')  num? dailyInterestRateFrom, @JsonKey(name: 'dailyInterestRateTo')  num? dailyInterestRateTo, @JsonKey(name: 'daysPerTermFrom')  int? daysPerTermFrom, @JsonKey(name: 'daysPerTermTo')  int? daysPerTermTo, @JsonKey(name: 'dueDate')  String? dueDate, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'loanLimitFrom')  num? loanLimitFrom, @JsonKey(name: 'loanLimitTo')  num? loanLimitTo, @JsonKey(name: 'productAccount')  num? productAccount, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productInterest')  num? productInterest, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productStatus')  int? productStatus, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays)  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmOrder():
return $default(_that.actualToAccount,_that.appOrderId,_that.appOrderIdStr,_that.appOrderStatus,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.borrowRetryDate,_that.customerLevelUnlock,_that.dailyInterestRateFrom,_that.dailyInterestRateTo,_that.daysPerTermFrom,_that.daysPerTermTo,_that.dueDate,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.loanLimitFrom,_that.loanLimitTo,_that.productAccount,_that.productCode,_that.productInterest,_that.productLevel,_that.productLogo,_that.productName,_that.productStatus,_that.receiptAmount,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.serviceFee,_that.term,_that.totalServiceDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'actualToAccount')  num? actualToAccount, @JsonKey(name: 'appOrderId')  int? appOrderId, @JsonKey(name: 'appOrderIdStr')  String? appOrderIdStr, @JsonKey(name: 'appOrderStatus')  int? appOrderStatus, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'borrowRetryDate')  String? borrowRetryDate, @JsonKey(name: 'customerLevelUnlock')  int? customerLevelUnlock, @JsonKey(name: 'dailyInterestRateFrom')  num? dailyInterestRateFrom, @JsonKey(name: 'dailyInterestRateTo')  num? dailyInterestRateTo, @JsonKey(name: 'daysPerTermFrom')  int? daysPerTermFrom, @JsonKey(name: 'daysPerTermTo')  int? daysPerTermTo, @JsonKey(name: 'dueDate')  String? dueDate, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'loanLimitFrom')  num? loanLimitFrom, @JsonKey(name: 'loanLimitTo')  num? loanLimitTo, @JsonKey(name: 'productAccount')  num? productAccount, @JsonKey(name: 'productCode')  String? productCode, @JsonKey(name: 'productInterest')  num? productInterest, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productStatus')  int? productStatus, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'serviceFee')  num? serviceFee, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays)?  $default,) {final _that = this;
switch (_that) {
case _LoanConfirmOrder() when $default != null:
return $default(_that.actualToAccount,_that.appOrderId,_that.appOrderIdStr,_that.appOrderStatus,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.borrowRetryDate,_that.customerLevelUnlock,_that.dailyInterestRateFrom,_that.dailyInterestRateTo,_that.daysPerTermFrom,_that.daysPerTermTo,_that.dueDate,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.loanLimitFrom,_that.loanLimitTo,_that.productAccount,_that.productCode,_that.productInterest,_that.productLevel,_that.productLogo,_that.productName,_that.productStatus,_that.receiptAmount,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.serviceFee,_that.term,_that.totalServiceDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoanConfirmOrder implements LoanConfirmOrder {
  const _LoanConfirmOrder({@JsonKey(name: 'actualToAccount') this.actualToAccount, @JsonKey(name: 'appOrderId') this.appOrderId, @JsonKey(name: 'appOrderIdStr') this.appOrderIdStr, @JsonKey(name: 'appOrderStatus') this.appOrderStatus, @JsonKey(name: 'bankCardName') this.bankCardName, @JsonKey(name: 'bankCardNo') this.bankCardNo, @JsonKey(name: 'bankCardType') this.bankCardType, @JsonKey(name: 'borrowRetryDate') this.borrowRetryDate, @JsonKey(name: 'customerLevelUnlock') this.customerLevelUnlock, @JsonKey(name: 'dailyInterestRateFrom') this.dailyInterestRateFrom, @JsonKey(name: 'dailyInterestRateTo') this.dailyInterestRateTo, @JsonKey(name: 'daysPerTermFrom') this.daysPerTermFrom, @JsonKey(name: 'daysPerTermTo') this.daysPerTermTo, @JsonKey(name: 'dueDate') this.dueDate, @JsonKey(name: 'interest') this.interest, @JsonKey(name: 'isExtensionSwitch') this.isExtensionSwitch, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'loanLimitFrom') this.loanLimitFrom, @JsonKey(name: 'loanLimitTo') this.loanLimitTo, @JsonKey(name: 'productAccount') this.productAccount, @JsonKey(name: 'productCode') this.productCode, @JsonKey(name: 'productInterest') this.productInterest, @JsonKey(name: 'productLevel') this.productLevel, @JsonKey(name: 'productLogo') this.productLogo, @JsonKey(name: 'productName') this.productName, @JsonKey(name: 'productStatus') this.productStatus, @JsonKey(name: 'receiptAmount') this.receiptAmount, @JsonKey(name: 'remainingDays') this.remainingDays, @JsonKey(name: 'repaidAmount') this.repaidAmount, @JsonKey(name: 'repayAmount') this.repayAmount, @JsonKey(name: 'repayDate') this.repayDate, @JsonKey(name: 'repayDateStr') this.repayDateStr, @JsonKey(name: 'serviceFee') this.serviceFee, @JsonKey(name: 'term') this.term, @JsonKey(name: 'totalServiceDays') this.totalServiceDays});
  factory _LoanConfirmOrder.fromJson(Map<String, dynamic> json) => _$LoanConfirmOrderFromJson(json);

@override@JsonKey(name: 'actualToAccount') final  num? actualToAccount;
@override@JsonKey(name: 'appOrderId') final  int? appOrderId;
@override@JsonKey(name: 'appOrderIdStr') final  String? appOrderIdStr;
@override@JsonKey(name: 'appOrderStatus') final  int? appOrderStatus;
@override@JsonKey(name: 'bankCardName') final  String? bankCardName;
@override@JsonKey(name: 'bankCardNo') final  String? bankCardNo;
@override@JsonKey(name: 'bankCardType') final  String? bankCardType;
@override@JsonKey(name: 'borrowRetryDate') final  String? borrowRetryDate;
@override@JsonKey(name: 'customerLevelUnlock') final  int? customerLevelUnlock;
@override@JsonKey(name: 'dailyInterestRateFrom') final  num? dailyInterestRateFrom;
@override@JsonKey(name: 'dailyInterestRateTo') final  num? dailyInterestRateTo;
@override@JsonKey(name: 'daysPerTermFrom') final  int? daysPerTermFrom;
@override@JsonKey(name: 'daysPerTermTo') final  int? daysPerTermTo;
@override@JsonKey(name: 'dueDate') final  String? dueDate;
@override@JsonKey(name: 'interest') final  num? interest;
@override@JsonKey(name: 'isExtensionSwitch') final  bool? isExtensionSwitch;
@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'loanLimitFrom') final  num? loanLimitFrom;
@override@JsonKey(name: 'loanLimitTo') final  num? loanLimitTo;
@override@JsonKey(name: 'productAccount') final  num? productAccount;
@override@JsonKey(name: 'productCode') final  String? productCode;
@override@JsonKey(name: 'productInterest') final  num? productInterest;
@override@JsonKey(name: 'productLevel') final  int? productLevel;
@override@JsonKey(name: 'productLogo') final  String? productLogo;
@override@JsonKey(name: 'productName') final  String? productName;
@override@JsonKey(name: 'productStatus') final  int? productStatus;
@override@JsonKey(name: 'receiptAmount') final  num? receiptAmount;
@override@JsonKey(name: 'remainingDays') final  int? remainingDays;
@override@JsonKey(name: 'repaidAmount') final  num? repaidAmount;
@override@JsonKey(name: 'repayAmount') final  num? repayAmount;
@override@JsonKey(name: 'repayDate') final  String? repayDate;
@override@JsonKey(name: 'repayDateStr') final  String? repayDateStr;
@override@JsonKey(name: 'serviceFee') final  num? serviceFee;
@override@JsonKey(name: 'term') final  int? term;
@override@JsonKey(name: 'totalServiceDays') final  int? totalServiceDays;

/// Create a copy of LoanConfirmOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanConfirmOrderCopyWith<_LoanConfirmOrder> get copyWith => __$LoanConfirmOrderCopyWithImpl<_LoanConfirmOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoanConfirmOrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoanConfirmOrder&&(identical(other.actualToAccount, actualToAccount) || other.actualToAccount == actualToAccount)&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.appOrderIdStr, appOrderIdStr) || other.appOrderIdStr == appOrderIdStr)&&(identical(other.appOrderStatus, appOrderStatus) || other.appOrderStatus == appOrderStatus)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.borrowRetryDate, borrowRetryDate) || other.borrowRetryDate == borrowRetryDate)&&(identical(other.customerLevelUnlock, customerLevelUnlock) || other.customerLevelUnlock == customerLevelUnlock)&&(identical(other.dailyInterestRateFrom, dailyInterestRateFrom) || other.dailyInterestRateFrom == dailyInterestRateFrom)&&(identical(other.dailyInterestRateTo, dailyInterestRateTo) || other.dailyInterestRateTo == dailyInterestRateTo)&&(identical(other.daysPerTermFrom, daysPerTermFrom) || other.daysPerTermFrom == daysPerTermFrom)&&(identical(other.daysPerTermTo, daysPerTermTo) || other.daysPerTermTo == daysPerTermTo)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.loanLimitFrom, loanLimitFrom) || other.loanLimitFrom == loanLimitFrom)&&(identical(other.loanLimitTo, loanLimitTo) || other.loanLimitTo == loanLimitTo)&&(identical(other.productAccount, productAccount) || other.productAccount == productAccount)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productInterest, productInterest) || other.productInterest == productInterest)&&(identical(other.productLevel, productLevel) || other.productLevel == productLevel)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productStatus, productStatus) || other.productStatus == productStatus)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.repaidAmount, repaidAmount) || other.repaidAmount == repaidAmount)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.repayDateStr, repayDateStr) || other.repayDateStr == repayDateStr)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.term, term) || other.term == term)&&(identical(other.totalServiceDays, totalServiceDays) || other.totalServiceDays == totalServiceDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,actualToAccount,appOrderId,appOrderIdStr,appOrderStatus,bankCardName,bankCardNo,bankCardType,borrowRetryDate,customerLevelUnlock,dailyInterestRateFrom,dailyInterestRateTo,daysPerTermFrom,daysPerTermTo,dueDate,interest,isExtensionSwitch,loanAmount,loanLimitFrom,loanLimitTo,productAccount,productCode,productInterest,productLevel,productLogo,productName,productStatus,receiptAmount,remainingDays,repaidAmount,repayAmount,repayDate,repayDateStr,serviceFee,term,totalServiceDays]);
}

@override
String toString() {
    return 'LoanConfirmOrder(actualToAccount: $actualToAccount, appOrderId: $appOrderId, appOrderIdStr: $appOrderIdStr, appOrderStatus: $appOrderStatus, bankCardName: $bankCardName, bankCardNo: $bankCardNo, bankCardType: $bankCardType, borrowRetryDate: $borrowRetryDate, customerLevelUnlock: $customerLevelUnlock, dailyInterestRateFrom: $dailyInterestRateFrom, dailyInterestRateTo: $dailyInterestRateTo, daysPerTermFrom: $daysPerTermFrom, daysPerTermTo: $daysPerTermTo, dueDate: $dueDate, interest: $interest, isExtensionSwitch: $isExtensionSwitch, loanAmount: $loanAmount, loanLimitFrom: $loanLimitFrom, loanLimitTo: $loanLimitTo, productAccount: $productAccount, productCode: $productCode, productInterest: $productInterest, productLevel: $productLevel, productLogo: $productLogo, productName: $productName, productStatus: $productStatus, receiptAmount: $receiptAmount, remainingDays: $remainingDays, repaidAmount: $repaidAmount, repayAmount: $repayAmount, repayDate: $repayDate, repayDateStr: $repayDateStr, serviceFee: $serviceFee, term: $term, totalServiceDays: $totalServiceDays)';
}


}

/// @nodoc
abstract mixin class _$LoanConfirmOrderCopyWith<$Res> implements $LoanConfirmOrderCopyWith<$Res> {
  factory _$LoanConfirmOrderCopyWith(_LoanConfirmOrder value, $Res Function(_LoanConfirmOrder) _then) = __$LoanConfirmOrderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'actualToAccount') num? actualToAccount,@JsonKey(name: 'appOrderId') int? appOrderId,@JsonKey(name: 'appOrderIdStr') String? appOrderIdStr,@JsonKey(name: 'appOrderStatus') int? appOrderStatus,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'borrowRetryDate') String? borrowRetryDate,@JsonKey(name: 'customerLevelUnlock') int? customerLevelUnlock,@JsonKey(name: 'dailyInterestRateFrom') num? dailyInterestRateFrom,@JsonKey(name: 'dailyInterestRateTo') num? dailyInterestRateTo,@JsonKey(name: 'daysPerTermFrom') int? daysPerTermFrom,@JsonKey(name: 'daysPerTermTo') int? daysPerTermTo,@JsonKey(name: 'dueDate') String? dueDate,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'loanLimitFrom') num? loanLimitFrom,@JsonKey(name: 'loanLimitTo') num? loanLimitTo,@JsonKey(name: 'productAccount') num? productAccount,@JsonKey(name: 'productCode') String? productCode,@JsonKey(name: 'productInterest') num? productInterest,@JsonKey(name: 'productLevel') int? productLevel,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productStatus') int? productStatus,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'serviceFee') num? serviceFee,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays
});




}
/// @nodoc
class __$LoanConfirmOrderCopyWithImpl<$Res>
    implements _$LoanConfirmOrderCopyWith<$Res> {
  __$LoanConfirmOrderCopyWithImpl(this._self, this._then);

  final _LoanConfirmOrder _self;
  final $Res Function(_LoanConfirmOrder) _then;

/// Create a copy of LoanConfirmOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actualToAccount = freezed,Object? appOrderId = freezed,Object? appOrderIdStr = freezed,Object? appOrderStatus = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? borrowRetryDate = freezed,Object? customerLevelUnlock = freezed,Object? dailyInterestRateFrom = freezed,Object? dailyInterestRateTo = freezed,Object? daysPerTermFrom = freezed,Object? daysPerTermTo = freezed,Object? dueDate = freezed,Object? interest = freezed,Object? isExtensionSwitch = freezed,Object? loanAmount = freezed,Object? loanLimitFrom = freezed,Object? loanLimitTo = freezed,Object? productAccount = freezed,Object? productCode = freezed,Object? productInterest = freezed,Object? productLevel = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? productStatus = freezed,Object? receiptAmount = freezed,Object? remainingDays = freezed,Object? repaidAmount = freezed,Object? repayAmount = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? serviceFee = freezed,Object? term = freezed,Object? totalServiceDays = freezed,}) {
  return _then(_LoanConfirmOrder(
actualToAccount: freezed == actualToAccount ? _self.actualToAccount : actualToAccount // ignore: cast_nullable_to_non_nullable
as num?,appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as int?,appOrderIdStr: freezed == appOrderIdStr ? _self.appOrderIdStr : appOrderIdStr // ignore: cast_nullable_to_non_nullable
as String?,appOrderStatus: freezed == appOrderStatus ? _self.appOrderStatus : appOrderStatus // ignore: cast_nullable_to_non_nullable
as int?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,borrowRetryDate: freezed == borrowRetryDate ? _self.borrowRetryDate : borrowRetryDate // ignore: cast_nullable_to_non_nullable
as String?,customerLevelUnlock: freezed == customerLevelUnlock ? _self.customerLevelUnlock : customerLevelUnlock // ignore: cast_nullable_to_non_nullable
as int?,dailyInterestRateFrom: freezed == dailyInterestRateFrom ? _self.dailyInterestRateFrom : dailyInterestRateFrom // ignore: cast_nullable_to_non_nullable
as num?,dailyInterestRateTo: freezed == dailyInterestRateTo ? _self.dailyInterestRateTo : dailyInterestRateTo // ignore: cast_nullable_to_non_nullable
as num?,daysPerTermFrom: freezed == daysPerTermFrom ? _self.daysPerTermFrom : daysPerTermFrom // ignore: cast_nullable_to_non_nullable
as int?,daysPerTermTo: freezed == daysPerTermTo ? _self.daysPerTermTo : daysPerTermTo // ignore: cast_nullable_to_non_nullable
as int?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,loanLimitFrom: freezed == loanLimitFrom ? _self.loanLimitFrom : loanLimitFrom // ignore: cast_nullable_to_non_nullable
as num?,loanLimitTo: freezed == loanLimitTo ? _self.loanLimitTo : loanLimitTo // ignore: cast_nullable_to_non_nullable
as num?,productAccount: freezed == productAccount ? _self.productAccount : productAccount // ignore: cast_nullable_to_non_nullable
as num?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productInterest: freezed == productInterest ? _self.productInterest : productInterest // ignore: cast_nullable_to_non_nullable
as num?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as int?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productStatus: freezed == productStatus ? _self.productStatus : productStatus // ignore: cast_nullable_to_non_nullable
as int?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as num?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
