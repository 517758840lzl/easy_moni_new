// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_list_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderListResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'msg') String? get msg;@JsonKey(name: 'data') List<OrderListItem>? get data;
/// Create a copy of OrderListResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderListRespCopyWith<OrderListResp> get copyWith => _$OrderListRespCopyWithImpl<OrderListResp>(this as OrderListResp, _$identity);

  /// Serializes this OrderListResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderListResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'OrderListResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class $OrderListRespCopyWith<$Res>  {
  factory $OrderListRespCopyWith(OrderListResp value, $Res Function(OrderListResp) _then) = _$OrderListRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') List<OrderListItem>? data
});




}
/// @nodoc
class _$OrderListRespCopyWithImpl<$Res>
    implements $OrderListRespCopyWith<$Res> {
  _$OrderListRespCopyWithImpl(this._self, this._then);

  final OrderListResp _self;
  final $Res Function(OrderListResp) _then;

/// Create a copy of OrderListResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<OrderListItem>?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderListResp].
extension OrderListRespPatterns on OrderListResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderListResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderListResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderListResp value)  $default,){
final _that = this;
switch (_that) {
case _OrderListResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderListResp value)?  $default,){
final _that = this;
switch (_that) {
case _OrderListResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  List<OrderListItem>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderListResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  List<OrderListItem>? data)  $default,) {final _that = this;
switch (_that) {
case _OrderListResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  List<OrderListItem>? data)?  $default,) {final _that = this;
switch (_that) {
case _OrderListResp() when $default != null:
return $default(_that.code,_that.msg,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderListResp implements OrderListResp {
  const _OrderListResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'msg') this.msg, @JsonKey(name: 'data') final  List<OrderListItem>? data}): _data = data;
  factory _OrderListResp.fromJson(Map<String, dynamic> json) => _$OrderListRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'msg') final  String? msg;
 final  List<OrderListItem>? _data;
@override@JsonKey(name: 'data') List<OrderListItem>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OrderListResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderListRespCopyWith<_OrderListResp> get copyWith => __$OrderListRespCopyWithImpl<_OrderListResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderListRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderListResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'OrderListResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class _$OrderListRespCopyWith<$Res> implements $OrderListRespCopyWith<$Res> {
  factory _$OrderListRespCopyWith(_OrderListResp value, $Res Function(_OrderListResp) _then) = __$OrderListRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') List<OrderListItem>? data
});




}
/// @nodoc
class __$OrderListRespCopyWithImpl<$Res>
    implements _$OrderListRespCopyWith<$Res> {
  __$OrderListRespCopyWithImpl(this._self, this._then);

  final _OrderListResp _self;
  final $Res Function(_OrderListResp) _then;

/// Create a copy of OrderListResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_OrderListResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<OrderListItem>?,
  ));
}


}


/// @nodoc
mixin _$OrderListItem {

@JsonKey(name: 'appOrderId') String? get appOrderId;@JsonKey(name: 'productSetCode') String? get productSetCode;@JsonKey(name: 'productLevel') String? get productLevel;@JsonKey(name: 'orderStatus') int? get orderStatus;@JsonKey(name: 'orderStatusStr') String? get orderStatusStr;@JsonKey(name: 'repayAmount') num? get repayAmount;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'receiptAmount') num? get receiptAmount;@JsonKey(name: 'interest') num? get interest;@JsonKey(name: 'term') int? get term;@JsonKey(name: 'totalServiceDays') int? get totalServiceDays;@JsonKey(name: 'remainingDays') int? get remainingDays;@JsonKey(name: 'productName') String? get productName;@JsonKey(name: 'productLogo') String? get productLogo;@JsonKey(name: 'repayDate') String? get repayDate;@JsonKey(name: 'repayDateStr') String? get repayDateStr;@JsonKey(name: 'repaidAmount') num? get repaidAmount;@JsonKey(name: 'bankCardNo') String? get bankCardNo;@JsonKey(name: 'bankCardName') String? get bankCardName;@JsonKey(name: 'bankCardType') String? get bankCardType;@JsonKey(name: 'updateTime') String? get updateTime;@JsonKey(name: 'createTime') String? get createTime;@JsonKey(name: 'acqChannel') String? get acqChannel;@JsonKey(name: 'closeTime') String? get closeTime;@JsonKey(name: 'rejectTime') int? get rejectTime;@JsonKey(name: 'sort') int? get sort;@JsonKey(name: 'isExtensionSwitch') bool? get isExtensionSwitch;@JsonKey(name: 'countdownTime') int? get countdownTime;
/// Create a copy of OrderListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderListItemCopyWith<OrderListItem> get copyWith => _$OrderListItemCopyWithImpl<OrderListItem>(this as OrderListItem, _$identity);

  /// Serializes this OrderListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderListItem&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.productSetCode, productSetCode) || other.productSetCode == productSetCode)&&(identical(other.productLevel, productLevel) || other.productLevel == productLevel)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusStr, orderStatusStr) || other.orderStatusStr == orderStatusStr)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.term, term) || other.term == term)&&(identical(other.totalServiceDays, totalServiceDays) || other.totalServiceDays == totalServiceDays)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.repayDateStr, repayDateStr) || other.repayDateStr == repayDateStr)&&(identical(other.repaidAmount, repaidAmount) || other.repaidAmount == repaidAmount)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime)&&(identical(other.createTime, createTime) || other.createTime == createTime)&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&(identical(other.countdownTime, countdownTime) || other.countdownTime == countdownTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,appOrderId,productSetCode,productLevel,orderStatus,orderStatusStr,repayAmount,loanAmount,receiptAmount,interest,term,totalServiceDays,remainingDays,productName,productLogo,repayDate,repayDateStr,repaidAmount,bankCardNo,bankCardName,bankCardType,updateTime,createTime,acqChannel,closeTime,rejectTime,sort,isExtensionSwitch,countdownTime]);

@override
String toString() {
  return 'OrderListItem(appOrderId: $appOrderId, productSetCode: $productSetCode, productLevel: $productLevel, orderStatus: $orderStatus, orderStatusStr: $orderStatusStr, repayAmount: $repayAmount, loanAmount: $loanAmount, receiptAmount: $receiptAmount, interest: $interest, term: $term, totalServiceDays: $totalServiceDays, remainingDays: $remainingDays, productName: $productName, productLogo: $productLogo, repayDate: $repayDate, repayDateStr: $repayDateStr, repaidAmount: $repaidAmount, bankCardNo: $bankCardNo, bankCardName: $bankCardName, bankCardType: $bankCardType, updateTime: $updateTime, createTime: $createTime, acqChannel: $acqChannel, closeTime: $closeTime, rejectTime: $rejectTime, sort: $sort, isExtensionSwitch: $isExtensionSwitch, countdownTime: $countdownTime)';
}


}

/// @nodoc
abstract mixin class $OrderListItemCopyWith<$Res>  {
  factory $OrderListItemCopyWith(OrderListItem value, $Res Function(OrderListItem) _then) = _$OrderListItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'productSetCode') String? productSetCode,@JsonKey(name: 'productLevel') String? productLevel,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusStr') String? orderStatusStr,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'updateTime') String? updateTime,@JsonKey(name: 'createTime') String? createTime,@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'closeTime') String? closeTime,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'sort') int? sort,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'countdownTime') int? countdownTime
});




}
/// @nodoc
class _$OrderListItemCopyWithImpl<$Res>
    implements $OrderListItemCopyWith<$Res> {
  _$OrderListItemCopyWithImpl(this._self, this._then);

  final OrderListItem _self;
  final $Res Function(OrderListItem) _then;

/// Create a copy of OrderListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appOrderId = freezed,Object? productSetCode = freezed,Object? productLevel = freezed,Object? orderStatus = freezed,Object? orderStatusStr = freezed,Object? repayAmount = freezed,Object? loanAmount = freezed,Object? receiptAmount = freezed,Object? interest = freezed,Object? term = freezed,Object? totalServiceDays = freezed,Object? remainingDays = freezed,Object? productName = freezed,Object? productLogo = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? repaidAmount = freezed,Object? bankCardNo = freezed,Object? bankCardName = freezed,Object? bankCardType = freezed,Object? updateTime = freezed,Object? createTime = freezed,Object? acqChannel = freezed,Object? closeTime = freezed,Object? rejectTime = freezed,Object? sort = freezed,Object? isExtensionSwitch = freezed,Object? countdownTime = freezed,}) {
  return _then(_self.copyWith(
appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,productSetCode: freezed == productSetCode ? _self.productSetCode : productSetCode // ignore: cast_nullable_to_non_nullable
as String?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusStr: freezed == orderStatusStr ? _self.orderStatusStr : orderStatusStr // ignore: cast_nullable_to_non_nullable
as String?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,createTime: freezed == createTime ? _self.createTime : createTime // ignore: cast_nullable_to_non_nullable
as String?,acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as String?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,countdownTime: freezed == countdownTime ? _self.countdownTime : countdownTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderListItem].
extension OrderListItemPatterns on OrderListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderListItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderListItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'productLevel')  String? productLevel, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  String? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'countdownTime')  int? countdownTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderListItem() when $default != null:
return $default(_that.appOrderId,_that.productSetCode,_that.productLevel,_that.orderStatus,_that.orderStatusStr,_that.repayAmount,_that.loanAmount,_that.receiptAmount,_that.interest,_that.term,_that.totalServiceDays,_that.remainingDays,_that.productName,_that.productLogo,_that.repayDate,_that.repayDateStr,_that.repaidAmount,_that.bankCardNo,_that.bankCardName,_that.bankCardType,_that.updateTime,_that.createTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.sort,_that.isExtensionSwitch,_that.countdownTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'productLevel')  String? productLevel, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  String? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'countdownTime')  int? countdownTime)  $default,) {final _that = this;
switch (_that) {
case _OrderListItem():
return $default(_that.appOrderId,_that.productSetCode,_that.productLevel,_that.orderStatus,_that.orderStatusStr,_that.repayAmount,_that.loanAmount,_that.receiptAmount,_that.interest,_that.term,_that.totalServiceDays,_that.remainingDays,_that.productName,_that.productLogo,_that.repayDate,_that.repayDateStr,_that.repaidAmount,_that.bankCardNo,_that.bankCardName,_that.bankCardType,_that.updateTime,_that.createTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.sort,_that.isExtensionSwitch,_that.countdownTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'productLevel')  String? productLevel, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'updateTime')  String? updateTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'closeTime')  String? closeTime, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'countdownTime')  int? countdownTime)?  $default,) {final _that = this;
switch (_that) {
case _OrderListItem() when $default != null:
return $default(_that.appOrderId,_that.productSetCode,_that.productLevel,_that.orderStatus,_that.orderStatusStr,_that.repayAmount,_that.loanAmount,_that.receiptAmount,_that.interest,_that.term,_that.totalServiceDays,_that.remainingDays,_that.productName,_that.productLogo,_that.repayDate,_that.repayDateStr,_that.repaidAmount,_that.bankCardNo,_that.bankCardName,_that.bankCardType,_that.updateTime,_that.createTime,_that.acqChannel,_that.closeTime,_that.rejectTime,_that.sort,_that.isExtensionSwitch,_that.countdownTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderListItem implements OrderListItem {
  const _OrderListItem({@JsonKey(name: 'appOrderId') this.appOrderId, @JsonKey(name: 'productSetCode') this.productSetCode, @JsonKey(name: 'productLevel') this.productLevel, @JsonKey(name: 'orderStatus') this.orderStatus, @JsonKey(name: 'orderStatusStr') this.orderStatusStr, @JsonKey(name: 'repayAmount') this.repayAmount, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'receiptAmount') this.receiptAmount, @JsonKey(name: 'interest') this.interest, @JsonKey(name: 'term') this.term, @JsonKey(name: 'totalServiceDays') this.totalServiceDays, @JsonKey(name: 'remainingDays') this.remainingDays, @JsonKey(name: 'productName') this.productName, @JsonKey(name: 'productLogo') this.productLogo, @JsonKey(name: 'repayDate') this.repayDate, @JsonKey(name: 'repayDateStr') this.repayDateStr, @JsonKey(name: 'repaidAmount') this.repaidAmount, @JsonKey(name: 'bankCardNo') this.bankCardNo, @JsonKey(name: 'bankCardName') this.bankCardName, @JsonKey(name: 'bankCardType') this.bankCardType, @JsonKey(name: 'updateTime') this.updateTime, @JsonKey(name: 'createTime') this.createTime, @JsonKey(name: 'acqChannel') this.acqChannel, @JsonKey(name: 'closeTime') this.closeTime, @JsonKey(name: 'rejectTime') this.rejectTime, @JsonKey(name: 'sort') this.sort, @JsonKey(name: 'isExtensionSwitch') this.isExtensionSwitch, @JsonKey(name: 'countdownTime') this.countdownTime});
  factory _OrderListItem.fromJson(Map<String, dynamic> json) => _$OrderListItemFromJson(json);

@override@JsonKey(name: 'appOrderId') final  String? appOrderId;
@override@JsonKey(name: 'productSetCode') final  String? productSetCode;
@override@JsonKey(name: 'productLevel') final  String? productLevel;
@override@JsonKey(name: 'orderStatus') final  int? orderStatus;
@override@JsonKey(name: 'orderStatusStr') final  String? orderStatusStr;
@override@JsonKey(name: 'repayAmount') final  num? repayAmount;
@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'receiptAmount') final  num? receiptAmount;
@override@JsonKey(name: 'interest') final  num? interest;
@override@JsonKey(name: 'term') final  int? term;
@override@JsonKey(name: 'totalServiceDays') final  int? totalServiceDays;
@override@JsonKey(name: 'remainingDays') final  int? remainingDays;
@override@JsonKey(name: 'productName') final  String? productName;
@override@JsonKey(name: 'productLogo') final  String? productLogo;
@override@JsonKey(name: 'repayDate') final  String? repayDate;
@override@JsonKey(name: 'repayDateStr') final  String? repayDateStr;
@override@JsonKey(name: 'repaidAmount') final  num? repaidAmount;
@override@JsonKey(name: 'bankCardNo') final  String? bankCardNo;
@override@JsonKey(name: 'bankCardName') final  String? bankCardName;
@override@JsonKey(name: 'bankCardType') final  String? bankCardType;
@override@JsonKey(name: 'updateTime') final  String? updateTime;
@override@JsonKey(name: 'createTime') final  String? createTime;
@override@JsonKey(name: 'acqChannel') final  String? acqChannel;
@override@JsonKey(name: 'closeTime') final  String? closeTime;
@override@JsonKey(name: 'rejectTime') final  int? rejectTime;
@override@JsonKey(name: 'sort') final  int? sort;
@override@JsonKey(name: 'isExtensionSwitch') final  bool? isExtensionSwitch;
@override@JsonKey(name: 'countdownTime') final  int? countdownTime;

/// Create a copy of OrderListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderListItemCopyWith<_OrderListItem> get copyWith => __$OrderListItemCopyWithImpl<_OrderListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderListItem&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.productSetCode, productSetCode) || other.productSetCode == productSetCode)&&(identical(other.productLevel, productLevel) || other.productLevel == productLevel)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusStr, orderStatusStr) || other.orderStatusStr == orderStatusStr)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.term, term) || other.term == term)&&(identical(other.totalServiceDays, totalServiceDays) || other.totalServiceDays == totalServiceDays)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.repayDateStr, repayDateStr) || other.repayDateStr == repayDateStr)&&(identical(other.repaidAmount, repaidAmount) || other.repaidAmount == repaidAmount)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime)&&(identical(other.createTime, createTime) || other.createTime == createTime)&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&(identical(other.countdownTime, countdownTime) || other.countdownTime == countdownTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,appOrderId,productSetCode,productLevel,orderStatus,orderStatusStr,repayAmount,loanAmount,receiptAmount,interest,term,totalServiceDays,remainingDays,productName,productLogo,repayDate,repayDateStr,repaidAmount,bankCardNo,bankCardName,bankCardType,updateTime,createTime,acqChannel,closeTime,rejectTime,sort,isExtensionSwitch,countdownTime]);

@override
String toString() {
  return 'OrderListItem(appOrderId: $appOrderId, productSetCode: $productSetCode, productLevel: $productLevel, orderStatus: $orderStatus, orderStatusStr: $orderStatusStr, repayAmount: $repayAmount, loanAmount: $loanAmount, receiptAmount: $receiptAmount, interest: $interest, term: $term, totalServiceDays: $totalServiceDays, remainingDays: $remainingDays, productName: $productName, productLogo: $productLogo, repayDate: $repayDate, repayDateStr: $repayDateStr, repaidAmount: $repaidAmount, bankCardNo: $bankCardNo, bankCardName: $bankCardName, bankCardType: $bankCardType, updateTime: $updateTime, createTime: $createTime, acqChannel: $acqChannel, closeTime: $closeTime, rejectTime: $rejectTime, sort: $sort, isExtensionSwitch: $isExtensionSwitch, countdownTime: $countdownTime)';
}


}

/// @nodoc
abstract mixin class _$OrderListItemCopyWith<$Res> implements $OrderListItemCopyWith<$Res> {
  factory _$OrderListItemCopyWith(_OrderListItem value, $Res Function(_OrderListItem) _then) = __$OrderListItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'productSetCode') String? productSetCode,@JsonKey(name: 'productLevel') String? productLevel,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusStr') String? orderStatusStr,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'updateTime') String? updateTime,@JsonKey(name: 'createTime') String? createTime,@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'closeTime') String? closeTime,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'sort') int? sort,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'countdownTime') int? countdownTime
});




}
/// @nodoc
class __$OrderListItemCopyWithImpl<$Res>
    implements _$OrderListItemCopyWith<$Res> {
  __$OrderListItemCopyWithImpl(this._self, this._then);

  final _OrderListItem _self;
  final $Res Function(_OrderListItem) _then;

/// Create a copy of OrderListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appOrderId = freezed,Object? productSetCode = freezed,Object? productLevel = freezed,Object? orderStatus = freezed,Object? orderStatusStr = freezed,Object? repayAmount = freezed,Object? loanAmount = freezed,Object? receiptAmount = freezed,Object? interest = freezed,Object? term = freezed,Object? totalServiceDays = freezed,Object? remainingDays = freezed,Object? productName = freezed,Object? productLogo = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? repaidAmount = freezed,Object? bankCardNo = freezed,Object? bankCardName = freezed,Object? bankCardType = freezed,Object? updateTime = freezed,Object? createTime = freezed,Object? acqChannel = freezed,Object? closeTime = freezed,Object? rejectTime = freezed,Object? sort = freezed,Object? isExtensionSwitch = freezed,Object? countdownTime = freezed,}) {
  return _then(_OrderListItem(
appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,productSetCode: freezed == productSetCode ? _self.productSetCode : productSetCode // ignore: cast_nullable_to_non_nullable
as String?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusStr: freezed == orderStatusStr ? _self.orderStatusStr : orderStatusStr // ignore: cast_nullable_to_non_nullable
as String?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,createTime: freezed == createTime ? _self.createTime : createTime // ignore: cast_nullable_to_non_nullable
as String?,acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as String?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,countdownTime: freezed == countdownTime ? _self.countdownTime : countdownTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
