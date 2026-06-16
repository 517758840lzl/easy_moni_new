// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repay_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepayResp {

@JsonKey(name: 'acqChannel') String? get acqChannel;@JsonKey(name: 'appOrderId') String? get appOrderId;@JsonKey(name: 'bankCardName') String? get bankCardName;@JsonKey(name: 'bankCardNo') String? get bankCardNo;@JsonKey(name: 'bankCardType') String? get bankCardType;@JsonKey(name: 'closeTime') int? get closeTime;@JsonKey(name: 'countdownTime') int? get countdownTime;@JsonKey(name: 'createTime') String? get createTime;@JsonKey(name: 'interest') num? get interest;@JsonKey(name: 'isExtensionSwitch') bool? get isExtensionSwitch;@JsonKey(name: 'loanAmount') num? get loanAmount;@JsonKey(name: 'orderStatus') int? get orderStatus;@JsonKey(name: 'orderStatusStr') String? get orderStatusStr;@JsonKey(name: 'productLevel') int? get productLevel;@JsonKey(name: 'productLogo') String? get productLogo;@JsonKey(name: 'productName') String? get productName;@JsonKey(name: 'productSetCode') String? get productSetCode;@JsonKey(name: 'receiptAmount') num? get receiptAmount;@JsonKey(name: 'rejectTime') int? get rejectTime;@JsonKey(name: 'remainingDays') int? get remainingDays;@JsonKey(name: 'repaidAmount') num? get repaidAmount;@JsonKey(name: 'repayAmount') num? get repayAmount;@JsonKey(name: 'repayDate') String? get repayDate;@JsonKey(name: 'repayDateStr') String? get repayDateStr;@JsonKey(name: 'sort') int? get sort;@JsonKey(name: 'term') int? get term;@JsonKey(name: 'totalServiceDays') int? get totalServiceDays;@JsonKey(name: 'updateTime') String? get updateTime;
/// Create a copy of RepayResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepayRespCopyWith<RepayResp> get copyWith => _$RepayRespCopyWithImpl<RepayResp>(this as RepayResp, _$identity);

  /// Serializes this RepayResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepayResp&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.countdownTime, countdownTime) || other.countdownTime == countdownTime)&&(identical(other.createTime, createTime) || other.createTime == createTime)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusStr, orderStatusStr) || other.orderStatusStr == orderStatusStr)&&(identical(other.productLevel, productLevel) || other.productLevel == productLevel)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productSetCode, productSetCode) || other.productSetCode == productSetCode)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.repaidAmount, repaidAmount) || other.repaidAmount == repaidAmount)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.repayDateStr, repayDateStr) || other.repayDateStr == repayDateStr)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.term, term) || other.term == term)&&(identical(other.totalServiceDays, totalServiceDays) || other.totalServiceDays == totalServiceDays)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,acqChannel,appOrderId,bankCardName,bankCardNo,bankCardType,closeTime,countdownTime,createTime,interest,isExtensionSwitch,loanAmount,orderStatus,orderStatusStr,productLevel,productLogo,productName,productSetCode,receiptAmount,rejectTime,remainingDays,repaidAmount,repayAmount,repayDate,repayDateStr,sort,term,totalServiceDays,updateTime]);

@override
String toString() {
  return 'RepayResp(acqChannel: $acqChannel, appOrderId: $appOrderId, bankCardName: $bankCardName, bankCardNo: $bankCardNo, bankCardType: $bankCardType, closeTime: $closeTime, countdownTime: $countdownTime, createTime: $createTime, interest: $interest, isExtensionSwitch: $isExtensionSwitch, loanAmount: $loanAmount, orderStatus: $orderStatus, orderStatusStr: $orderStatusStr, productLevel: $productLevel, productLogo: $productLogo, productName: $productName, productSetCode: $productSetCode, receiptAmount: $receiptAmount, rejectTime: $rejectTime, remainingDays: $remainingDays, repaidAmount: $repaidAmount, repayAmount: $repayAmount, repayDate: $repayDate, repayDateStr: $repayDateStr, sort: $sort, term: $term, totalServiceDays: $totalServiceDays, updateTime: $updateTime)';
}


}

/// @nodoc
abstract mixin class $RepayRespCopyWith<$Res>  {
  factory $RepayRespCopyWith(RepayResp value, $Res Function(RepayResp) _then) = _$RepayRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'closeTime') int? closeTime,@JsonKey(name: 'countdownTime') int? countdownTime,@JsonKey(name: 'createTime') String? createTime,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusStr') String? orderStatusStr,@JsonKey(name: 'productLevel') int? productLevel,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productSetCode') String? productSetCode,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'sort') int? sort,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays,@JsonKey(name: 'updateTime') String? updateTime
});




}
/// @nodoc
class _$RepayRespCopyWithImpl<$Res>
    implements $RepayRespCopyWith<$Res> {
  _$RepayRespCopyWithImpl(this._self, this._then);

  final RepayResp _self;
  final $Res Function(RepayResp) _then;

/// Create a copy of RepayResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acqChannel = freezed,Object? appOrderId = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? closeTime = freezed,Object? countdownTime = freezed,Object? createTime = freezed,Object? interest = freezed,Object? isExtensionSwitch = freezed,Object? loanAmount = freezed,Object? orderStatus = freezed,Object? orderStatusStr = freezed,Object? productLevel = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? productSetCode = freezed,Object? receiptAmount = freezed,Object? rejectTime = freezed,Object? remainingDays = freezed,Object? repaidAmount = freezed,Object? repayAmount = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? sort = freezed,Object? term = freezed,Object? totalServiceDays = freezed,Object? updateTime = freezed,}) {
  return _then(_self.copyWith(
acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as int?,countdownTime: freezed == countdownTime ? _self.countdownTime : countdownTime // ignore: cast_nullable_to_non_nullable
as int?,createTime: freezed == createTime ? _self.createTime : createTime // ignore: cast_nullable_to_non_nullable
as String?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusStr: freezed == orderStatusStr ? _self.orderStatusStr : orderStatusStr // ignore: cast_nullable_to_non_nullable
as String?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as int?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productSetCode: freezed == productSetCode ? _self.productSetCode : productSetCode // ignore: cast_nullable_to_non_nullable
as String?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepayResp].
extension RepayRespPatterns on RepayResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepayResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepayResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepayResp value)  $default,){
final _that = this;
switch (_that) {
case _RepayResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepayResp value)?  $default,){
final _that = this;
switch (_that) {
case _RepayResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'countdownTime')  int? countdownTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'updateTime')  String? updateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepayResp() when $default != null:
return $default(_that.acqChannel,_that.appOrderId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.closeTime,_that.countdownTime,_that.createTime,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.orderStatus,_that.orderStatusStr,_that.productLevel,_that.productLogo,_that.productName,_that.productSetCode,_that.receiptAmount,_that.rejectTime,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.sort,_that.term,_that.totalServiceDays,_that.updateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'countdownTime')  int? countdownTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'updateTime')  String? updateTime)  $default,) {final _that = this;
switch (_that) {
case _RepayResp():
return $default(_that.acqChannel,_that.appOrderId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.closeTime,_that.countdownTime,_that.createTime,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.orderStatus,_that.orderStatusStr,_that.productLevel,_that.productLogo,_that.productName,_that.productSetCode,_that.receiptAmount,_that.rejectTime,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.sort,_that.term,_that.totalServiceDays,_that.updateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'acqChannel')  String? acqChannel, @JsonKey(name: 'appOrderId')  String? appOrderId, @JsonKey(name: 'bankCardName')  String? bankCardName, @JsonKey(name: 'bankCardNo')  String? bankCardNo, @JsonKey(name: 'bankCardType')  String? bankCardType, @JsonKey(name: 'closeTime')  int? closeTime, @JsonKey(name: 'countdownTime')  int? countdownTime, @JsonKey(name: 'createTime')  String? createTime, @JsonKey(name: 'interest')  num? interest, @JsonKey(name: 'isExtensionSwitch')  bool? isExtensionSwitch, @JsonKey(name: 'loanAmount')  num? loanAmount, @JsonKey(name: 'orderStatus')  int? orderStatus, @JsonKey(name: 'orderStatusStr')  String? orderStatusStr, @JsonKey(name: 'productLevel')  int? productLevel, @JsonKey(name: 'productLogo')  String? productLogo, @JsonKey(name: 'productName')  String? productName, @JsonKey(name: 'productSetCode')  String? productSetCode, @JsonKey(name: 'receiptAmount')  num? receiptAmount, @JsonKey(name: 'rejectTime')  int? rejectTime, @JsonKey(name: 'remainingDays')  int? remainingDays, @JsonKey(name: 'repaidAmount')  num? repaidAmount, @JsonKey(name: 'repayAmount')  num? repayAmount, @JsonKey(name: 'repayDate')  String? repayDate, @JsonKey(name: 'repayDateStr')  String? repayDateStr, @JsonKey(name: 'sort')  int? sort, @JsonKey(name: 'term')  int? term, @JsonKey(name: 'totalServiceDays')  int? totalServiceDays, @JsonKey(name: 'updateTime')  String? updateTime)?  $default,) {final _that = this;
switch (_that) {
case _RepayResp() when $default != null:
return $default(_that.acqChannel,_that.appOrderId,_that.bankCardName,_that.bankCardNo,_that.bankCardType,_that.closeTime,_that.countdownTime,_that.createTime,_that.interest,_that.isExtensionSwitch,_that.loanAmount,_that.orderStatus,_that.orderStatusStr,_that.productLevel,_that.productLogo,_that.productName,_that.productSetCode,_that.receiptAmount,_that.rejectTime,_that.remainingDays,_that.repaidAmount,_that.repayAmount,_that.repayDate,_that.repayDateStr,_that.sort,_that.term,_that.totalServiceDays,_that.updateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepayResp implements RepayResp {
  const _RepayResp({@JsonKey(name: 'acqChannel') this.acqChannel, @JsonKey(name: 'appOrderId') this.appOrderId, @JsonKey(name: 'bankCardName') this.bankCardName, @JsonKey(name: 'bankCardNo') this.bankCardNo, @JsonKey(name: 'bankCardType') this.bankCardType, @JsonKey(name: 'closeTime') this.closeTime, @JsonKey(name: 'countdownTime') this.countdownTime, @JsonKey(name: 'createTime') this.createTime, @JsonKey(name: 'interest') this.interest, @JsonKey(name: 'isExtensionSwitch') this.isExtensionSwitch, @JsonKey(name: 'loanAmount') this.loanAmount, @JsonKey(name: 'orderStatus') this.orderStatus, @JsonKey(name: 'orderStatusStr') this.orderStatusStr, @JsonKey(name: 'productLevel') this.productLevel, @JsonKey(name: 'productLogo') this.productLogo, @JsonKey(name: 'productName') this.productName, @JsonKey(name: 'productSetCode') this.productSetCode, @JsonKey(name: 'receiptAmount') this.receiptAmount, @JsonKey(name: 'rejectTime') this.rejectTime, @JsonKey(name: 'remainingDays') this.remainingDays, @JsonKey(name: 'repaidAmount') this.repaidAmount, @JsonKey(name: 'repayAmount') this.repayAmount, @JsonKey(name: 'repayDate') this.repayDate, @JsonKey(name: 'repayDateStr') this.repayDateStr, @JsonKey(name: 'sort') this.sort, @JsonKey(name: 'term') this.term, @JsonKey(name: 'totalServiceDays') this.totalServiceDays, @JsonKey(name: 'updateTime') this.updateTime});
  factory _RepayResp.fromJson(Map<String, dynamic> json) => _$RepayRespFromJson(json);

@override@JsonKey(name: 'acqChannel') final  String? acqChannel;
@override@JsonKey(name: 'appOrderId') final  String? appOrderId;
@override@JsonKey(name: 'bankCardName') final  String? bankCardName;
@override@JsonKey(name: 'bankCardNo') final  String? bankCardNo;
@override@JsonKey(name: 'bankCardType') final  String? bankCardType;
@override@JsonKey(name: 'closeTime') final  int? closeTime;
@override@JsonKey(name: 'countdownTime') final  int? countdownTime;
@override@JsonKey(name: 'createTime') final  String? createTime;
@override@JsonKey(name: 'interest') final  num? interest;
@override@JsonKey(name: 'isExtensionSwitch') final  bool? isExtensionSwitch;
@override@JsonKey(name: 'loanAmount') final  num? loanAmount;
@override@JsonKey(name: 'orderStatus') final  int? orderStatus;
@override@JsonKey(name: 'orderStatusStr') final  String? orderStatusStr;
@override@JsonKey(name: 'productLevel') final  int? productLevel;
@override@JsonKey(name: 'productLogo') final  String? productLogo;
@override@JsonKey(name: 'productName') final  String? productName;
@override@JsonKey(name: 'productSetCode') final  String? productSetCode;
@override@JsonKey(name: 'receiptAmount') final  num? receiptAmount;
@override@JsonKey(name: 'rejectTime') final  int? rejectTime;
@override@JsonKey(name: 'remainingDays') final  int? remainingDays;
@override@JsonKey(name: 'repaidAmount') final  num? repaidAmount;
@override@JsonKey(name: 'repayAmount') final  num? repayAmount;
@override@JsonKey(name: 'repayDate') final  String? repayDate;
@override@JsonKey(name: 'repayDateStr') final  String? repayDateStr;
@override@JsonKey(name: 'sort') final  int? sort;
@override@JsonKey(name: 'term') final  int? term;
@override@JsonKey(name: 'totalServiceDays') final  int? totalServiceDays;
@override@JsonKey(name: 'updateTime') final  String? updateTime;

/// Create a copy of RepayResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepayRespCopyWith<_RepayResp> get copyWith => __$RepayRespCopyWithImpl<_RepayResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepayRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepayResp&&(identical(other.acqChannel, acqChannel) || other.acqChannel == acqChannel)&&(identical(other.appOrderId, appOrderId) || other.appOrderId == appOrderId)&&(identical(other.bankCardName, bankCardName) || other.bankCardName == bankCardName)&&(identical(other.bankCardNo, bankCardNo) || other.bankCardNo == bankCardNo)&&(identical(other.bankCardType, bankCardType) || other.bankCardType == bankCardType)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.countdownTime, countdownTime) || other.countdownTime == countdownTime)&&(identical(other.createTime, createTime) || other.createTime == createTime)&&(identical(other.interest, interest) || other.interest == interest)&&(identical(other.isExtensionSwitch, isExtensionSwitch) || other.isExtensionSwitch == isExtensionSwitch)&&(identical(other.loanAmount, loanAmount) || other.loanAmount == loanAmount)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderStatusStr, orderStatusStr) || other.orderStatusStr == orderStatusStr)&&(identical(other.productLevel, productLevel) || other.productLevel == productLevel)&&(identical(other.productLogo, productLogo) || other.productLogo == productLogo)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productSetCode, productSetCode) || other.productSetCode == productSetCode)&&(identical(other.receiptAmount, receiptAmount) || other.receiptAmount == receiptAmount)&&(identical(other.rejectTime, rejectTime) || other.rejectTime == rejectTime)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.repaidAmount, repaidAmount) || other.repaidAmount == repaidAmount)&&(identical(other.repayAmount, repayAmount) || other.repayAmount == repayAmount)&&(identical(other.repayDate, repayDate) || other.repayDate == repayDate)&&(identical(other.repayDateStr, repayDateStr) || other.repayDateStr == repayDateStr)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.term, term) || other.term == term)&&(identical(other.totalServiceDays, totalServiceDays) || other.totalServiceDays == totalServiceDays)&&(identical(other.updateTime, updateTime) || other.updateTime == updateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,acqChannel,appOrderId,bankCardName,bankCardNo,bankCardType,closeTime,countdownTime,createTime,interest,isExtensionSwitch,loanAmount,orderStatus,orderStatusStr,productLevel,productLogo,productName,productSetCode,receiptAmount,rejectTime,remainingDays,repaidAmount,repayAmount,repayDate,repayDateStr,sort,term,totalServiceDays,updateTime]);

@override
String toString() {
  return 'RepayResp(acqChannel: $acqChannel, appOrderId: $appOrderId, bankCardName: $bankCardName, bankCardNo: $bankCardNo, bankCardType: $bankCardType, closeTime: $closeTime, countdownTime: $countdownTime, createTime: $createTime, interest: $interest, isExtensionSwitch: $isExtensionSwitch, loanAmount: $loanAmount, orderStatus: $orderStatus, orderStatusStr: $orderStatusStr, productLevel: $productLevel, productLogo: $productLogo, productName: $productName, productSetCode: $productSetCode, receiptAmount: $receiptAmount, rejectTime: $rejectTime, remainingDays: $remainingDays, repaidAmount: $repaidAmount, repayAmount: $repayAmount, repayDate: $repayDate, repayDateStr: $repayDateStr, sort: $sort, term: $term, totalServiceDays: $totalServiceDays, updateTime: $updateTime)';
}


}

/// @nodoc
abstract mixin class _$RepayRespCopyWith<$Res> implements $RepayRespCopyWith<$Res> {
  factory _$RepayRespCopyWith(_RepayResp value, $Res Function(_RepayResp) _then) = __$RepayRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'acqChannel') String? acqChannel,@JsonKey(name: 'appOrderId') String? appOrderId,@JsonKey(name: 'bankCardName') String? bankCardName,@JsonKey(name: 'bankCardNo') String? bankCardNo,@JsonKey(name: 'bankCardType') String? bankCardType,@JsonKey(name: 'closeTime') int? closeTime,@JsonKey(name: 'countdownTime') int? countdownTime,@JsonKey(name: 'createTime') String? createTime,@JsonKey(name: 'interest') num? interest,@JsonKey(name: 'isExtensionSwitch') bool? isExtensionSwitch,@JsonKey(name: 'loanAmount') num? loanAmount,@JsonKey(name: 'orderStatus') int? orderStatus,@JsonKey(name: 'orderStatusStr') String? orderStatusStr,@JsonKey(name: 'productLevel') int? productLevel,@JsonKey(name: 'productLogo') String? productLogo,@JsonKey(name: 'productName') String? productName,@JsonKey(name: 'productSetCode') String? productSetCode,@JsonKey(name: 'receiptAmount') num? receiptAmount,@JsonKey(name: 'rejectTime') int? rejectTime,@JsonKey(name: 'remainingDays') int? remainingDays,@JsonKey(name: 'repaidAmount') num? repaidAmount,@JsonKey(name: 'repayAmount') num? repayAmount,@JsonKey(name: 'repayDate') String? repayDate,@JsonKey(name: 'repayDateStr') String? repayDateStr,@JsonKey(name: 'sort') int? sort,@JsonKey(name: 'term') int? term,@JsonKey(name: 'totalServiceDays') int? totalServiceDays,@JsonKey(name: 'updateTime') String? updateTime
});




}
/// @nodoc
class __$RepayRespCopyWithImpl<$Res>
    implements _$RepayRespCopyWith<$Res> {
  __$RepayRespCopyWithImpl(this._self, this._then);

  final _RepayResp _self;
  final $Res Function(_RepayResp) _then;

/// Create a copy of RepayResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acqChannel = freezed,Object? appOrderId = freezed,Object? bankCardName = freezed,Object? bankCardNo = freezed,Object? bankCardType = freezed,Object? closeTime = freezed,Object? countdownTime = freezed,Object? createTime = freezed,Object? interest = freezed,Object? isExtensionSwitch = freezed,Object? loanAmount = freezed,Object? orderStatus = freezed,Object? orderStatusStr = freezed,Object? productLevel = freezed,Object? productLogo = freezed,Object? productName = freezed,Object? productSetCode = freezed,Object? receiptAmount = freezed,Object? rejectTime = freezed,Object? remainingDays = freezed,Object? repaidAmount = freezed,Object? repayAmount = freezed,Object? repayDate = freezed,Object? repayDateStr = freezed,Object? sort = freezed,Object? term = freezed,Object? totalServiceDays = freezed,Object? updateTime = freezed,}) {
  return _then(_RepayResp(
acqChannel: freezed == acqChannel ? _self.acqChannel : acqChannel // ignore: cast_nullable_to_non_nullable
as String?,appOrderId: freezed == appOrderId ? _self.appOrderId : appOrderId // ignore: cast_nullable_to_non_nullable
as String?,bankCardName: freezed == bankCardName ? _self.bankCardName : bankCardName // ignore: cast_nullable_to_non_nullable
as String?,bankCardNo: freezed == bankCardNo ? _self.bankCardNo : bankCardNo // ignore: cast_nullable_to_non_nullable
as String?,bankCardType: freezed == bankCardType ? _self.bankCardType : bankCardType // ignore: cast_nullable_to_non_nullable
as String?,closeTime: freezed == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as int?,countdownTime: freezed == countdownTime ? _self.countdownTime : countdownTime // ignore: cast_nullable_to_non_nullable
as int?,createTime: freezed == createTime ? _self.createTime : createTime // ignore: cast_nullable_to_non_nullable
as String?,interest: freezed == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as num?,isExtensionSwitch: freezed == isExtensionSwitch ? _self.isExtensionSwitch : isExtensionSwitch // ignore: cast_nullable_to_non_nullable
as bool?,loanAmount: freezed == loanAmount ? _self.loanAmount : loanAmount // ignore: cast_nullable_to_non_nullable
as num?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as int?,orderStatusStr: freezed == orderStatusStr ? _self.orderStatusStr : orderStatusStr // ignore: cast_nullable_to_non_nullable
as String?,productLevel: freezed == productLevel ? _self.productLevel : productLevel // ignore: cast_nullable_to_non_nullable
as int?,productLogo: freezed == productLogo ? _self.productLogo : productLogo // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productSetCode: freezed == productSetCode ? _self.productSetCode : productSetCode // ignore: cast_nullable_to_non_nullable
as String?,receiptAmount: freezed == receiptAmount ? _self.receiptAmount : receiptAmount // ignore: cast_nullable_to_non_nullable
as num?,rejectTime: freezed == rejectTime ? _self.rejectTime : rejectTime // ignore: cast_nullable_to_non_nullable
as int?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,repaidAmount: freezed == repaidAmount ? _self.repaidAmount : repaidAmount // ignore: cast_nullable_to_non_nullable
as num?,repayAmount: freezed == repayAmount ? _self.repayAmount : repayAmount // ignore: cast_nullable_to_non_nullable
as num?,repayDate: freezed == repayDate ? _self.repayDate : repayDate // ignore: cast_nullable_to_non_nullable
as String?,repayDateStr: freezed == repayDateStr ? _self.repayDateStr : repayDateStr // ignore: cast_nullable_to_non_nullable
as String?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as int?,totalServiceDays: freezed == totalServiceDays ? _self.totalServiceDays : totalServiceDays // ignore: cast_nullable_to_non_nullable
as int?,updateTime: freezed == updateTime ? _self.updateTime : updateTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
