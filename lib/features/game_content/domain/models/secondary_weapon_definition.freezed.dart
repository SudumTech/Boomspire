// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secondary_weapon_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecondaryWeaponDefinition {

 double get damage; double get range; double get interval; WeaponType get weaponType; int get projectileCount; double get clipShotInterval; Set<UnitDomain> get attackDomains;
/// Create a copy of SecondaryWeaponDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecondaryWeaponDefinitionCopyWith<SecondaryWeaponDefinition> get copyWith => _$SecondaryWeaponDefinitionCopyWithImpl<SecondaryWeaponDefinition>(this as SecondaryWeaponDefinition, _$identity);

  /// Serializes this SecondaryWeaponDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecondaryWeaponDefinition&&(identical(other.damage, damage) || other.damage == damage)&&(identical(other.range, range) || other.range == range)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.weaponType, weaponType) || other.weaponType == weaponType)&&(identical(other.projectileCount, projectileCount) || other.projectileCount == projectileCount)&&(identical(other.clipShotInterval, clipShotInterval) || other.clipShotInterval == clipShotInterval)&&const DeepCollectionEquality().equals(other.attackDomains, attackDomains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,damage,range,interval,weaponType,projectileCount,clipShotInterval,const DeepCollectionEquality().hash(attackDomains));

@override
String toString() {
  return 'SecondaryWeaponDefinition(damage: $damage, range: $range, interval: $interval, weaponType: $weaponType, projectileCount: $projectileCount, clipShotInterval: $clipShotInterval, attackDomains: $attackDomains)';
}


}

/// @nodoc
abstract mixin class $SecondaryWeaponDefinitionCopyWith<$Res>  {
  factory $SecondaryWeaponDefinitionCopyWith(SecondaryWeaponDefinition value, $Res Function(SecondaryWeaponDefinition) _then) = _$SecondaryWeaponDefinitionCopyWithImpl;
@useResult
$Res call({
 double damage, double range, double interval, WeaponType weaponType, int projectileCount, double clipShotInterval, Set<UnitDomain> attackDomains
});




}
/// @nodoc
class _$SecondaryWeaponDefinitionCopyWithImpl<$Res>
    implements $SecondaryWeaponDefinitionCopyWith<$Res> {
  _$SecondaryWeaponDefinitionCopyWithImpl(this._self, this._then);

  final SecondaryWeaponDefinition _self;
  final $Res Function(SecondaryWeaponDefinition) _then;

/// Create a copy of SecondaryWeaponDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? damage = null,Object? range = null,Object? interval = null,Object? weaponType = null,Object? projectileCount = null,Object? clipShotInterval = null,Object? attackDomains = null,}) {
  return _then(SecondaryWeaponDefinition(
damage: null == damage ? _self.damage : damage // ignore: cast_nullable_to_non_nullable
as double,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as double,weaponType: null == weaponType ? _self.weaponType : weaponType // ignore: cast_nullable_to_non_nullable
as WeaponType,projectileCount: null == projectileCount ? _self.projectileCount : projectileCount // ignore: cast_nullable_to_non_nullable
as int,clipShotInterval: null == clipShotInterval ? _self.clipShotInterval : clipShotInterval // ignore: cast_nullable_to_non_nullable
as double,attackDomains: null == attackDomains ? _self.attackDomains : attackDomains // ignore: cast_nullable_to_non_nullable
as Set<UnitDomain>,
  ));
}

}


/// Adds pattern-matching-related methods to [SecondaryWeaponDefinition].
extension SecondaryWeaponDefinitionPatterns on SecondaryWeaponDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecondaryWeaponDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecondaryWeaponDefinition value)  $default,){
final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecondaryWeaponDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double damage,  double range,  double interval,  WeaponType weaponType,  int projectileCount,  double clipShotInterval,  Set<UnitDomain> attackDomains)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition() when $default != null:
return $default(_that.damage,_that.range,_that.interval,_that.weaponType,_that.projectileCount,_that.clipShotInterval,_that.attackDomains);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double damage,  double range,  double interval,  WeaponType weaponType,  int projectileCount,  double clipShotInterval,  Set<UnitDomain> attackDomains)  $default,) {final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition():
return $default(_that.damage,_that.range,_that.interval,_that.weaponType,_that.projectileCount,_that.clipShotInterval,_that.attackDomains);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double damage,  double range,  double interval,  WeaponType weaponType,  int projectileCount,  double clipShotInterval,  Set<UnitDomain> attackDomains)?  $default,) {final _that = this;
switch (_that) {
case _SecondaryWeaponDefinition() when $default != null:
return $default(_that.damage,_that.range,_that.interval,_that.weaponType,_that.projectileCount,_that.clipShotInterval,_that.attackDomains);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecondaryWeaponDefinition implements SecondaryWeaponDefinition {
  const _SecondaryWeaponDefinition({required this.damage, required this.range, required this.interval, required this.weaponType, this.projectileCount = 1, this.clipShotInterval = 0.12,  Set<UnitDomain> attackDomains = const {UnitDomain.ground}}): _attackDomains = attackDomains;
  factory _SecondaryWeaponDefinition.fromJson(Map<String, dynamic> json) => _$SecondaryWeaponDefinitionFromJson(json);

@override final  double damage;
@override final  double range;
@override final  double interval;
@override final  WeaponType weaponType;
@override@JsonKey() final  int projectileCount;
@override@JsonKey() final  double clipShotInterval;
 final  Set<UnitDomain> _attackDomains;
@override@JsonKey() Set<UnitDomain> get attackDomains {
  if (_attackDomains is EqualUnmodifiableSetView) return _attackDomains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_attackDomains);
}


/// Create a copy of SecondaryWeaponDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecondaryWeaponDefinitionCopyWith<_SecondaryWeaponDefinition> get copyWith => __$SecondaryWeaponDefinitionCopyWithImpl<_SecondaryWeaponDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecondaryWeaponDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecondaryWeaponDefinition&&(identical(other.damage, damage) || other.damage == damage)&&(identical(other.range, range) || other.range == range)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.weaponType, weaponType) || other.weaponType == weaponType)&&(identical(other.projectileCount, projectileCount) || other.projectileCount == projectileCount)&&(identical(other.clipShotInterval, clipShotInterval) || other.clipShotInterval == clipShotInterval)&&const DeepCollectionEquality().equals(other._attackDomains, _attackDomains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,damage,range,interval,weaponType,projectileCount,clipShotInterval,const DeepCollectionEquality().hash(_attackDomains));

@override
String toString() {
  return 'SecondaryWeaponDefinition(damage: $damage, range: $range, interval: $interval, weaponType: $weaponType, projectileCount: $projectileCount, clipShotInterval: $clipShotInterval, attackDomains: $attackDomains)';
}


}

/// @nodoc
abstract mixin class _$SecondaryWeaponDefinitionCopyWith<$Res> implements $SecondaryWeaponDefinitionCopyWith<$Res> {
  factory _$SecondaryWeaponDefinitionCopyWith(_SecondaryWeaponDefinition value, $Res Function(_SecondaryWeaponDefinition) _then) = __$SecondaryWeaponDefinitionCopyWithImpl;
@override @useResult
$Res call({
 double damage, double range, double interval, WeaponType weaponType, int projectileCount, double clipShotInterval, Set<UnitDomain> attackDomains
});




}
/// @nodoc
class __$SecondaryWeaponDefinitionCopyWithImpl<$Res>
    implements _$SecondaryWeaponDefinitionCopyWith<$Res> {
  __$SecondaryWeaponDefinitionCopyWithImpl(this._self, this._then);

  final _SecondaryWeaponDefinition _self;
  final $Res Function(_SecondaryWeaponDefinition) _then;

/// Create a copy of SecondaryWeaponDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? damage = null,Object? range = null,Object? interval = null,Object? weaponType = null,Object? projectileCount = null,Object? clipShotInterval = null,Object? attackDomains = null,}) {
  return _then(_SecondaryWeaponDefinition(
damage: null == damage ? _self.damage : damage // ignore: cast_nullable_to_non_nullable
as double,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as double,weaponType: null == weaponType ? _self.weaponType : weaponType // ignore: cast_nullable_to_non_nullable
as WeaponType,projectileCount: null == projectileCount ? _self.projectileCount : projectileCount // ignore: cast_nullable_to_non_nullable
as int,clipShotInterval: null == clipShotInterval ? _self.clipShotInterval : clipShotInterval // ignore: cast_nullable_to_non_nullable
as double,attackDomains: null == attackDomains ? _self._attackDomains : attackDomains // ignore: cast_nullable_to_non_nullable
as Set<UnitDomain>,
  ));
}


}

// dart format on
