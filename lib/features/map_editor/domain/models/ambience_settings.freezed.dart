// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ambience_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AmbienceSettings {

/// Master switch for this map's environment sound.
 bool get enabled;/// Scales every layer together.
 double get volume; double get wind; double get rain; double get snow; double get dust; double get birds;/// Rustling leaves - follows how many trees are in view.
 double get leaves;/// Rivers and lakes.
 double get water; double get sea; double get lava;
/// Create a copy of AmbienceSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbienceSettingsCopyWith<AmbienceSettings> get copyWith => _$AmbienceSettingsCopyWithImpl<AmbienceSettings>(this as AmbienceSettings, _$identity);

  /// Serializes this AmbienceSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmbienceSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.wind, wind) || other.wind == wind)&&(identical(other.rain, rain) || other.rain == rain)&&(identical(other.snow, snow) || other.snow == snow)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.birds, birds) || other.birds == birds)&&(identical(other.leaves, leaves) || other.leaves == leaves)&&(identical(other.water, water) || other.water == water)&&(identical(other.sea, sea) || other.sea == sea)&&(identical(other.lava, lava) || other.lava == lava));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,volume,wind,rain,snow,dust,birds,leaves,water,sea,lava);

@override
String toString() {
  return 'AmbienceSettings(enabled: $enabled, volume: $volume, wind: $wind, rain: $rain, snow: $snow, dust: $dust, birds: $birds, leaves: $leaves, water: $water, sea: $sea, lava: $lava)';
}


}

/// @nodoc
abstract mixin class $AmbienceSettingsCopyWith<$Res>  {
  factory $AmbienceSettingsCopyWith(AmbienceSettings value, $Res Function(AmbienceSettings) _then) = _$AmbienceSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, double volume, double wind, double rain, double snow, double dust, double birds, double leaves, double water, double sea, double lava
});




}
/// @nodoc
class _$AmbienceSettingsCopyWithImpl<$Res>
    implements $AmbienceSettingsCopyWith<$Res> {
  _$AmbienceSettingsCopyWithImpl(this._self, this._then);

  final AmbienceSettings _self;
  final $Res Function(AmbienceSettings) _then;

/// Create a copy of AmbienceSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? volume = null,Object? wind = null,Object? rain = null,Object? snow = null,Object? dust = null,Object? birds = null,Object? leaves = null,Object? water = null,Object? sea = null,Object? lava = null,}) {
  return _then(AmbienceSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,wind: null == wind ? _self.wind : wind // ignore: cast_nullable_to_non_nullable
as double,rain: null == rain ? _self.rain : rain // ignore: cast_nullable_to_non_nullable
as double,snow: null == snow ? _self.snow : snow // ignore: cast_nullable_to_non_nullable
as double,dust: null == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as double,birds: null == birds ? _self.birds : birds // ignore: cast_nullable_to_non_nullable
as double,leaves: null == leaves ? _self.leaves : leaves // ignore: cast_nullable_to_non_nullable
as double,water: null == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as double,sea: null == sea ? _self.sea : sea // ignore: cast_nullable_to_non_nullable
as double,lava: null == lava ? _self.lava : lava // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AmbienceSettings].
extension AmbienceSettingsPatterns on AmbienceSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmbienceSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmbienceSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmbienceSettings value)  $default,){
final _that = this;
switch (_that) {
case _AmbienceSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmbienceSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AmbienceSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  double volume,  double wind,  double rain,  double snow,  double dust,  double birds,  double leaves,  double water,  double sea,  double lava)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmbienceSettings() when $default != null:
return $default(_that.enabled,_that.volume,_that.wind,_that.rain,_that.snow,_that.dust,_that.birds,_that.leaves,_that.water,_that.sea,_that.lava);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  double volume,  double wind,  double rain,  double snow,  double dust,  double birds,  double leaves,  double water,  double sea,  double lava)  $default,) {final _that = this;
switch (_that) {
case _AmbienceSettings():
return $default(_that.enabled,_that.volume,_that.wind,_that.rain,_that.snow,_that.dust,_that.birds,_that.leaves,_that.water,_that.sea,_that.lava);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  double volume,  double wind,  double rain,  double snow,  double dust,  double birds,  double leaves,  double water,  double sea,  double lava)?  $default,) {final _that = this;
switch (_that) {
case _AmbienceSettings() when $default != null:
return $default(_that.enabled,_that.volume,_that.wind,_that.rain,_that.snow,_that.dust,_that.birds,_that.leaves,_that.water,_that.sea,_that.lava);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AmbienceSettings extends AmbienceSettings {
  const _AmbienceSettings({this.enabled = true, this.volume = 1.0, this.wind = 1.0, this.rain = 1.0, this.snow = 1.0, this.dust = 1.0, this.birds = 1.0, this.leaves = 1.0, this.water = 1.0, this.sea = 1.0, this.lava = 1.0}): super._();
  factory _AmbienceSettings.fromJson(Map<String, dynamic> json) => _$AmbienceSettingsFromJson(json);

/// Master switch for this map's environment sound.
@override@JsonKey() final  bool enabled;
/// Scales every layer together.
@override@JsonKey() final  double volume;
@override@JsonKey() final  double wind;
@override@JsonKey() final  double rain;
@override@JsonKey() final  double snow;
@override@JsonKey() final  double dust;
@override@JsonKey() final  double birds;
/// Rustling leaves - follows how many trees are in view.
@override@JsonKey() final  double leaves;
/// Rivers and lakes.
@override@JsonKey() final  double water;
@override@JsonKey() final  double sea;
@override@JsonKey() final  double lava;

/// Create a copy of AmbienceSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbienceSettingsCopyWith<_AmbienceSettings> get copyWith => __$AmbienceSettingsCopyWithImpl<_AmbienceSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmbienceSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmbienceSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.wind, wind) || other.wind == wind)&&(identical(other.rain, rain) || other.rain == rain)&&(identical(other.snow, snow) || other.snow == snow)&&(identical(other.dust, dust) || other.dust == dust)&&(identical(other.birds, birds) || other.birds == birds)&&(identical(other.leaves, leaves) || other.leaves == leaves)&&(identical(other.water, water) || other.water == water)&&(identical(other.sea, sea) || other.sea == sea)&&(identical(other.lava, lava) || other.lava == lava));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,volume,wind,rain,snow,dust,birds,leaves,water,sea,lava);

@override
String toString() {
  return 'AmbienceSettings(enabled: $enabled, volume: $volume, wind: $wind, rain: $rain, snow: $snow, dust: $dust, birds: $birds, leaves: $leaves, water: $water, sea: $sea, lava: $lava)';
}


}

/// @nodoc
abstract mixin class _$AmbienceSettingsCopyWith<$Res> implements $AmbienceSettingsCopyWith<$Res> {
  factory _$AmbienceSettingsCopyWith(_AmbienceSettings value, $Res Function(_AmbienceSettings) _then) = __$AmbienceSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, double volume, double wind, double rain, double snow, double dust, double birds, double leaves, double water, double sea, double lava
});




}
/// @nodoc
class __$AmbienceSettingsCopyWithImpl<$Res>
    implements _$AmbienceSettingsCopyWith<$Res> {
  __$AmbienceSettingsCopyWithImpl(this._self, this._then);

  final _AmbienceSettings _self;
  final $Res Function(_AmbienceSettings) _then;

/// Create a copy of AmbienceSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? volume = null,Object? wind = null,Object? rain = null,Object? snow = null,Object? dust = null,Object? birds = null,Object? leaves = null,Object? water = null,Object? sea = null,Object? lava = null,}) {
  return _then(_AmbienceSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,wind: null == wind ? _self.wind : wind // ignore: cast_nullable_to_non_nullable
as double,rain: null == rain ? _self.rain : rain // ignore: cast_nullable_to_non_nullable
as double,snow: null == snow ? _self.snow : snow // ignore: cast_nullable_to_non_nullable
as double,dust: null == dust ? _self.dust : dust // ignore: cast_nullable_to_non_nullable
as double,birds: null == birds ? _self.birds : birds // ignore: cast_nullable_to_non_nullable
as double,leaves: null == leaves ? _self.leaves : leaves // ignore: cast_nullable_to_non_nullable
as double,water: null == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as double,sea: null == sea ? _self.sea : sea // ignore: cast_nullable_to_non_nullable
as double,lava: null == lava ? _self.lava : lava // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
