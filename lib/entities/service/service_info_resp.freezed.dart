// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_info_resp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceInfoResp {

@JsonKey(name: 'code') int? get code;@JsonKey(name: 'msg') String? get msg;@JsonKey(name: 'data') ServiceInfoRespData? get data;
/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceInfoRespCopyWith<ServiceInfoResp> get copyWith => _$ServiceInfoRespCopyWithImpl<ServiceInfoResp>(this as ServiceInfoResp, _$identity);

  /// Serializes this ServiceInfoResp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceInfoResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'ServiceInfoResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class $ServiceInfoRespCopyWith<$Res>  {
  factory $ServiceInfoRespCopyWith(ServiceInfoResp value, $Res Function(ServiceInfoResp) _then) = _$ServiceInfoRespCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') ServiceInfoRespData? data
});


$ServiceInfoRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$ServiceInfoRespCopyWithImpl<$Res>
    implements $ServiceInfoRespCopyWith<$Res> {
  _$ServiceInfoRespCopyWithImpl(this._self, this._then);

  final ServiceInfoResp _self;
  final $Res Function(ServiceInfoResp) _then;

/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ServiceInfoRespData?,
  ));
}
/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceInfoRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $ServiceInfoRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ServiceInfoResp].
extension ServiceInfoRespPatterns on ServiceInfoResp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceInfoResp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceInfoResp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceInfoResp value)  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoResp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceInfoResp value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoResp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  ServiceInfoRespData? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceInfoResp() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  ServiceInfoRespData? data)  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoResp():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int? code, @JsonKey(name: 'msg')  String? msg, @JsonKey(name: 'data')  ServiceInfoRespData? data)?  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoResp() when $default != null:
return $default(_that.code,_that.msg,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceInfoResp implements ServiceInfoResp {
  const _ServiceInfoResp({@JsonKey(name: 'code') this.code, @JsonKey(name: 'msg') this.msg, @JsonKey(name: 'data') this.data});
  factory _ServiceInfoResp.fromJson(Map<String, dynamic> json) => _$ServiceInfoRespFromJson(json);

@override@JsonKey(name: 'code') final  int? code;
@override@JsonKey(name: 'msg') final  String? msg;
@override@JsonKey(name: 'data') final  ServiceInfoRespData? data;

/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceInfoRespCopyWith<_ServiceInfoResp> get copyWith => __$ServiceInfoRespCopyWithImpl<_ServiceInfoResp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceInfoRespToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceInfoResp&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,msg,data);

@override
String toString() {
  return 'ServiceInfoResp(code: $code, msg: $msg, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ServiceInfoRespCopyWith<$Res> implements $ServiceInfoRespCopyWith<$Res> {
  factory _$ServiceInfoRespCopyWith(_ServiceInfoResp value, $Res Function(_ServiceInfoResp) _then) = __$ServiceInfoRespCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int? code,@JsonKey(name: 'msg') String? msg,@JsonKey(name: 'data') ServiceInfoRespData? data
});


@override $ServiceInfoRespDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$ServiceInfoRespCopyWithImpl<$Res>
    implements _$ServiceInfoRespCopyWith<$Res> {
  __$ServiceInfoRespCopyWithImpl(this._self, this._then);

  final _ServiceInfoResp _self;
  final $Res Function(_ServiceInfoResp) _then;

/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? msg = freezed,Object? data = freezed,}) {
  return _then(_ServiceInfoResp(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,msg: freezed == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ServiceInfoRespData?,
  ));
}

/// Create a copy of ServiceInfoResp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceInfoRespDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $ServiceInfoRespDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$ServiceInfoRespData {

@JsonKey(name: 'showType') int? get showType;@JsonKey(name: 'appCustomerServiceInfoResps') List<ServiceInfoRespDataAppCustomerServiceInfo>? get appCustomerServiceInfoResps;@JsonKey(name: 'appCustomerServiceInfo') ServiceInfoRespDataAppCustomerServiceInfo? get appCustomerServiceInfo;
/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceInfoRespDataCopyWith<ServiceInfoRespData> get copyWith => _$ServiceInfoRespDataCopyWithImpl<ServiceInfoRespData>(this as ServiceInfoRespData, _$identity);

  /// Serializes this ServiceInfoRespData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceInfoRespData&&(identical(other.showType, showType) || other.showType == showType)&&const DeepCollectionEquality().equals(other.appCustomerServiceInfoResps, appCustomerServiceInfoResps)&&(identical(other.appCustomerServiceInfo, appCustomerServiceInfo) || other.appCustomerServiceInfo == appCustomerServiceInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showType,const DeepCollectionEquality().hash(appCustomerServiceInfoResps),appCustomerServiceInfo);

@override
String toString() {
  return 'ServiceInfoRespData(showType: $showType, appCustomerServiceInfoResps: $appCustomerServiceInfoResps, appCustomerServiceInfo: $appCustomerServiceInfo)';
}


}

/// @nodoc
abstract mixin class $ServiceInfoRespDataCopyWith<$Res>  {
  factory $ServiceInfoRespDataCopyWith(ServiceInfoRespData value, $Res Function(ServiceInfoRespData) _then) = _$ServiceInfoRespDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'showType') int? showType,@JsonKey(name: 'appCustomerServiceInfoResps') List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps,@JsonKey(name: 'appCustomerServiceInfo') ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo
});


$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>? get appCustomerServiceInfo;

}
/// @nodoc
class _$ServiceInfoRespDataCopyWithImpl<$Res>
    implements $ServiceInfoRespDataCopyWith<$Res> {
  _$ServiceInfoRespDataCopyWithImpl(this._self, this._then);

  final ServiceInfoRespData _self;
  final $Res Function(ServiceInfoRespData) _then;

/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showType = freezed,Object? appCustomerServiceInfoResps = freezed,Object? appCustomerServiceInfo = freezed,}) {
  return _then(_self.copyWith(
showType: freezed == showType ? _self.showType : showType // ignore: cast_nullable_to_non_nullable
as int?,appCustomerServiceInfoResps: freezed == appCustomerServiceInfoResps ? _self.appCustomerServiceInfoResps : appCustomerServiceInfoResps // ignore: cast_nullable_to_non_nullable
as List<ServiceInfoRespDataAppCustomerServiceInfo>?,appCustomerServiceInfo: freezed == appCustomerServiceInfo ? _self.appCustomerServiceInfo : appCustomerServiceInfo // ignore: cast_nullable_to_non_nullable
as ServiceInfoRespDataAppCustomerServiceInfo?,
  ));
}
/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>? get appCustomerServiceInfo {
    if (_self.appCustomerServiceInfo == null) {
    return null;
  }

  return $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>(_self.appCustomerServiceInfo!, (value) {
    return _then(_self.copyWith(appCustomerServiceInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ServiceInfoRespData].
extension ServiceInfoRespDataPatterns on ServiceInfoRespData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceInfoRespData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceInfoRespData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceInfoRespData value)  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoRespData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceInfoRespData value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoRespData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'showType')  int? showType, @JsonKey(name: 'appCustomerServiceInfoResps')  List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps, @JsonKey(name: 'appCustomerServiceInfo')  ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceInfoRespData() when $default != null:
return $default(_that.showType,_that.appCustomerServiceInfoResps,_that.appCustomerServiceInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'showType')  int? showType, @JsonKey(name: 'appCustomerServiceInfoResps')  List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps, @JsonKey(name: 'appCustomerServiceInfo')  ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo)  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoRespData():
return $default(_that.showType,_that.appCustomerServiceInfoResps,_that.appCustomerServiceInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'showType')  int? showType, @JsonKey(name: 'appCustomerServiceInfoResps')  List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps, @JsonKey(name: 'appCustomerServiceInfo')  ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo)?  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoRespData() when $default != null:
return $default(_that.showType,_that.appCustomerServiceInfoResps,_that.appCustomerServiceInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceInfoRespData implements ServiceInfoRespData {
  const _ServiceInfoRespData({@JsonKey(name: 'showType') this.showType, @JsonKey(name: 'appCustomerServiceInfoResps') final  List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps, @JsonKey(name: 'appCustomerServiceInfo') this.appCustomerServiceInfo}): _appCustomerServiceInfoResps = appCustomerServiceInfoResps;
  factory _ServiceInfoRespData.fromJson(Map<String, dynamic> json) => _$ServiceInfoRespDataFromJson(json);

@override@JsonKey(name: 'showType') final  int? showType;
 final  List<ServiceInfoRespDataAppCustomerServiceInfo>? _appCustomerServiceInfoResps;
@override@JsonKey(name: 'appCustomerServiceInfoResps') List<ServiceInfoRespDataAppCustomerServiceInfo>? get appCustomerServiceInfoResps {
  final value = _appCustomerServiceInfoResps;
  if (value == null) return null;
  if (_appCustomerServiceInfoResps is EqualUnmodifiableListView) return _appCustomerServiceInfoResps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'appCustomerServiceInfo') final  ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo;

/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceInfoRespDataCopyWith<_ServiceInfoRespData> get copyWith => __$ServiceInfoRespDataCopyWithImpl<_ServiceInfoRespData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceInfoRespDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceInfoRespData&&(identical(other.showType, showType) || other.showType == showType)&&const DeepCollectionEquality().equals(other._appCustomerServiceInfoResps, _appCustomerServiceInfoResps)&&(identical(other.appCustomerServiceInfo, appCustomerServiceInfo) || other.appCustomerServiceInfo == appCustomerServiceInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showType,const DeepCollectionEquality().hash(_appCustomerServiceInfoResps),appCustomerServiceInfo);

@override
String toString() {
  return 'ServiceInfoRespData(showType: $showType, appCustomerServiceInfoResps: $appCustomerServiceInfoResps, appCustomerServiceInfo: $appCustomerServiceInfo)';
}


}

/// @nodoc
abstract mixin class _$ServiceInfoRespDataCopyWith<$Res> implements $ServiceInfoRespDataCopyWith<$Res> {
  factory _$ServiceInfoRespDataCopyWith(_ServiceInfoRespData value, $Res Function(_ServiceInfoRespData) _then) = __$ServiceInfoRespDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'showType') int? showType,@JsonKey(name: 'appCustomerServiceInfoResps') List<ServiceInfoRespDataAppCustomerServiceInfo>? appCustomerServiceInfoResps,@JsonKey(name: 'appCustomerServiceInfo') ServiceInfoRespDataAppCustomerServiceInfo? appCustomerServiceInfo
});


@override $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>? get appCustomerServiceInfo;

}
/// @nodoc
class __$ServiceInfoRespDataCopyWithImpl<$Res>
    implements _$ServiceInfoRespDataCopyWith<$Res> {
  __$ServiceInfoRespDataCopyWithImpl(this._self, this._then);

  final _ServiceInfoRespData _self;
  final $Res Function(_ServiceInfoRespData) _then;

/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showType = freezed,Object? appCustomerServiceInfoResps = freezed,Object? appCustomerServiceInfo = freezed,}) {
  return _then(_ServiceInfoRespData(
showType: freezed == showType ? _self.showType : showType // ignore: cast_nullable_to_non_nullable
as int?,appCustomerServiceInfoResps: freezed == appCustomerServiceInfoResps ? _self._appCustomerServiceInfoResps : appCustomerServiceInfoResps // ignore: cast_nullable_to_non_nullable
as List<ServiceInfoRespDataAppCustomerServiceInfo>?,appCustomerServiceInfo: freezed == appCustomerServiceInfo ? _self.appCustomerServiceInfo : appCustomerServiceInfo // ignore: cast_nullable_to_non_nullable
as ServiceInfoRespDataAppCustomerServiceInfo?,
  ));
}

/// Create a copy of ServiceInfoRespData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>? get appCustomerServiceInfo {
    if (_self.appCustomerServiceInfo == null) {
    return null;
  }

  return $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>(_self.appCustomerServiceInfo!, (value) {
    return _then(_self.copyWith(appCustomerServiceInfo: value));
  });
}
}


/// @nodoc
mixin _$ServiceInfoRespDataAppCustomerServiceInfo {

@JsonKey(name: 'type') int? get type;@JsonKey(name: 'account') String? get account;@JsonKey(name: 'title') String? get title;@JsonKey(name: 'desc') String? get desc;@JsonKey(name: 'accountList') List<ServiceInfoRespDataAppCustomerServiceInfo>? get accountList;
/// Create a copy of ServiceInfoRespDataAppCustomerServiceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<ServiceInfoRespDataAppCustomerServiceInfo> get copyWith => _$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl<ServiceInfoRespDataAppCustomerServiceInfo>(this as ServiceInfoRespDataAppCustomerServiceInfo, _$identity);

  /// Serializes this ServiceInfoRespDataAppCustomerServiceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceInfoRespDataAppCustomerServiceInfo&&(identical(other.type, type) || other.type == type)&&(identical(other.account, account) || other.account == account)&&(identical(other.title, title) || other.title == title)&&(identical(other.desc, desc) || other.desc == desc)&&const DeepCollectionEquality().equals(other.accountList, accountList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,account,title,desc,const DeepCollectionEquality().hash(accountList));

@override
String toString() {
  return 'ServiceInfoRespDataAppCustomerServiceInfo(type: $type, account: $account, title: $title, desc: $desc, accountList: $accountList)';
}


}

/// @nodoc
abstract mixin class $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res>  {
  factory $ServiceInfoRespDataAppCustomerServiceInfoCopyWith(ServiceInfoRespDataAppCustomerServiceInfo value, $Res Function(ServiceInfoRespDataAppCustomerServiceInfo) _then) = _$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'type') int? type,@JsonKey(name: 'account') String? account,@JsonKey(name: 'title') String? title,@JsonKey(name: 'desc') String? desc,@JsonKey(name: 'accountList') List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList
});




}
/// @nodoc
class _$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl<$Res>
    implements $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res> {
  _$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl(this._self, this._then);

  final ServiceInfoRespDataAppCustomerServiceInfo _self;
  final $Res Function(ServiceInfoRespDataAppCustomerServiceInfo) _then;

/// Create a copy of ServiceInfoRespDataAppCustomerServiceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? account = freezed,Object? title = freezed,Object? desc = freezed,Object? accountList = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,desc: freezed == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String?,accountList: freezed == accountList ? _self.accountList : accountList // ignore: cast_nullable_to_non_nullable
as List<ServiceInfoRespDataAppCustomerServiceInfo>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceInfoRespDataAppCustomerServiceInfo].
extension ServiceInfoRespDataAppCustomerServiceInfoPatterns on ServiceInfoRespDataAppCustomerServiceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceInfoRespDataAppCustomerServiceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceInfoRespDataAppCustomerServiceInfo value)  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceInfoRespDataAppCustomerServiceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'type')  int? type, @JsonKey(name: 'account')  String? account, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'desc')  String? desc, @JsonKey(name: 'accountList')  List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo() when $default != null:
return $default(_that.type,_that.account,_that.title,_that.desc,_that.accountList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'type')  int? type, @JsonKey(name: 'account')  String? account, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'desc')  String? desc, @JsonKey(name: 'accountList')  List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList)  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo():
return $default(_that.type,_that.account,_that.title,_that.desc,_that.accountList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'type')  int? type, @JsonKey(name: 'account')  String? account, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'desc')  String? desc, @JsonKey(name: 'accountList')  List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList)?  $default,) {final _that = this;
switch (_that) {
case _ServiceInfoRespDataAppCustomerServiceInfo() when $default != null:
return $default(_that.type,_that.account,_that.title,_that.desc,_that.accountList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceInfoRespDataAppCustomerServiceInfo implements ServiceInfoRespDataAppCustomerServiceInfo {
  const _ServiceInfoRespDataAppCustomerServiceInfo({@JsonKey(name: 'type') this.type, @JsonKey(name: 'account') this.account, @JsonKey(name: 'title') this.title, @JsonKey(name: 'desc') this.desc, @JsonKey(name: 'accountList') final  List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList}): _accountList = accountList;
  factory _ServiceInfoRespDataAppCustomerServiceInfo.fromJson(Map<String, dynamic> json) => _$ServiceInfoRespDataAppCustomerServiceInfoFromJson(json);

@override@JsonKey(name: 'type') final  int? type;
@override@JsonKey(name: 'account') final  String? account;
@override@JsonKey(name: 'title') final  String? title;
@override@JsonKey(name: 'desc') final  String? desc;
 final  List<ServiceInfoRespDataAppCustomerServiceInfo>? _accountList;
@override@JsonKey(name: 'accountList') List<ServiceInfoRespDataAppCustomerServiceInfo>? get accountList {
  final value = _accountList;
  if (value == null) return null;
  if (_accountList is EqualUnmodifiableListView) return _accountList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ServiceInfoRespDataAppCustomerServiceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<_ServiceInfoRespDataAppCustomerServiceInfo> get copyWith => __$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl<_ServiceInfoRespDataAppCustomerServiceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceInfoRespDataAppCustomerServiceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceInfoRespDataAppCustomerServiceInfo&&(identical(other.type, type) || other.type == type)&&(identical(other.account, account) || other.account == account)&&(identical(other.title, title) || other.title == title)&&(identical(other.desc, desc) || other.desc == desc)&&const DeepCollectionEquality().equals(other._accountList, _accountList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,account,title,desc,const DeepCollectionEquality().hash(_accountList));

@override
String toString() {
  return 'ServiceInfoRespDataAppCustomerServiceInfo(type: $type, account: $account, title: $title, desc: $desc, accountList: $accountList)';
}


}

/// @nodoc
abstract mixin class _$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res> implements $ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res> {
  factory _$ServiceInfoRespDataAppCustomerServiceInfoCopyWith(_ServiceInfoRespDataAppCustomerServiceInfo value, $Res Function(_ServiceInfoRespDataAppCustomerServiceInfo) _then) = __$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'type') int? type,@JsonKey(name: 'account') String? account,@JsonKey(name: 'title') String? title,@JsonKey(name: 'desc') String? desc,@JsonKey(name: 'accountList') List<ServiceInfoRespDataAppCustomerServiceInfo>? accountList
});




}
/// @nodoc
class __$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl<$Res>
    implements _$ServiceInfoRespDataAppCustomerServiceInfoCopyWith<$Res> {
  __$ServiceInfoRespDataAppCustomerServiceInfoCopyWithImpl(this._self, this._then);

  final _ServiceInfoRespDataAppCustomerServiceInfo _self;
  final $Res Function(_ServiceInfoRespDataAppCustomerServiceInfo) _then;

/// Create a copy of ServiceInfoRespDataAppCustomerServiceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? account = freezed,Object? title = freezed,Object? desc = freezed,Object? accountList = freezed,}) {
  return _then(_ServiceInfoRespDataAppCustomerServiceInfo(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,desc: freezed == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String?,accountList: freezed == accountList ? _self._accountList : accountList // ignore: cast_nullable_to_non_nullable
as List<ServiceInfoRespDataAppCustomerServiceInfo>?,
  ));
}


}

// dart format on
