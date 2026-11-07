// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameScene {

 String get id; String get name;/// Flavor text describing the terrain and the incoming strategy.
 String get briefing; Biome get biome; GameMode get mode;/// Total number of waves in this scene's campaign. Unused by
/// [GameMode.skirmish] scenes.
 int get waveCount;/// Added on top of the AI director's computed aggression each wave (0 =
/// no change, higher = a harder-fought campaign from the start). Unused
/// by [GameMode.skirmish] scenes.
 double get aggressionBias;/// Bumped whenever any field changes for this [id] - see
/// [sceneNeedsUpdate]/`SceneSyncService`, which uses it to decide whether
/// a server-served scene should replace a cached/built-in one.
 int get version;/// Unused by [GameMode.skirmish] scenes (see [homeSites] instead).
 HomeLayout get homeLayout;/// Unused by [GameMode.skirmish] scenes.
 SpawnLayout get spawnLayout;/// One entry per team seat, for [GameMode.skirmish] scenes - empty for
/// [GameMode.waveDefense] scenes, which always use [homeLayout] instead.
 List<HomeSite> get homeSites;/// Capturable second-resource nodes on this scene's map - placed as a
/// fraction of the arena size so the same scene definition still makes
/// sense at any arena size. Empty for scenes with no capturable economy.
 List<ResourceNodeSite> get resourceNodeSites;/// Starting gold for this scene, or null to fall back to
/// `GameConfig.startingGold`/`GameConfig.startingSkirmishGold` (picked by
/// `mode`) - lets a scene/map draft author a different economy.
@JsonKey(includeIfNull: false) int? get startingGold;/// This scene's lighting, weather and environment sound - defaults to a
/// static, weather-free look with the natural sound mix.
 EnvironmentSettings get environment;
/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSceneCopyWith<GameScene> get copyWith => _$GameSceneCopyWithImpl<GameScene>(this as GameScene, _$identity);

  /// Serializes this GameScene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameScene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.briefing, briefing) || other.briefing == briefing)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.waveCount, waveCount) || other.waveCount == waveCount)&&(identical(other.aggressionBias, aggressionBias) || other.aggressionBias == aggressionBias)&&(identical(other.version, version) || other.version == version)&&(identical(other.homeLayout, homeLayout) || other.homeLayout == homeLayout)&&(identical(other.spawnLayout, spawnLayout) || other.spawnLayout == spawnLayout)&&const DeepCollectionEquality().equals(other.homeSites, homeSites)&&const DeepCollectionEquality().equals(other.resourceNodeSites, resourceNodeSites)&&(identical(other.startingGold, startingGold) || other.startingGold == startingGold)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,briefing,biome,mode,waveCount,aggressionBias,version,homeLayout,spawnLayout,const DeepCollectionEquality().hash(homeSites),const DeepCollectionEquality().hash(resourceNodeSites),startingGold,environment);

@override
String toString() {
  return 'GameScene(id: $id, name: $name, briefing: $briefing, biome: $biome, mode: $mode, waveCount: $waveCount, aggressionBias: $aggressionBias, version: $version, homeLayout: $homeLayout, spawnLayout: $spawnLayout, homeSites: $homeSites, resourceNodeSites: $resourceNodeSites, startingGold: $startingGold, environment: $environment)';
}


}

/// @nodoc
abstract mixin class $GameSceneCopyWith<$Res>  {
  factory $GameSceneCopyWith(GameScene value, $Res Function(GameScene) _then) = _$GameSceneCopyWithImpl;
@useResult
$Res call({
 String id, String name, String briefing, Biome biome, GameMode mode, int waveCount, double aggressionBias, int version, HomeLayout homeLayout, SpawnLayout spawnLayout, List<HomeSite> homeSites, List<ResourceNodeSite> resourceNodeSites,@JsonKey(includeIfNull: false) int? startingGold, EnvironmentSettings environment
});


$EnvironmentSettingsCopyWith<$Res> get environment;

}
/// @nodoc
class _$GameSceneCopyWithImpl<$Res>
    implements $GameSceneCopyWith<$Res> {
  _$GameSceneCopyWithImpl(this._self, this._then);

  final GameScene _self;
  final $Res Function(GameScene) _then;

/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? briefing = null,Object? biome = null,Object? mode = null,Object? waveCount = null,Object? aggressionBias = null,Object? version = null,Object? homeLayout = null,Object? spawnLayout = null,Object? homeSites = null,Object? resourceNodeSites = null,Object? startingGold = freezed,Object? environment = null,}) {
  return _then(GameScene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,briefing: null == briefing ? _self.briefing : briefing // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,waveCount: null == waveCount ? _self.waveCount : waveCount // ignore: cast_nullable_to_non_nullable
as int,aggressionBias: null == aggressionBias ? _self.aggressionBias : aggressionBias // ignore: cast_nullable_to_non_nullable
as double,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,homeLayout: null == homeLayout ? _self.homeLayout : homeLayout // ignore: cast_nullable_to_non_nullable
as HomeLayout,spawnLayout: null == spawnLayout ? _self.spawnLayout : spawnLayout // ignore: cast_nullable_to_non_nullable
as SpawnLayout,homeSites: null == homeSites ? _self.homeSites : homeSites // ignore: cast_nullable_to_non_nullable
as List<HomeSite>,resourceNodeSites: null == resourceNodeSites ? _self.resourceNodeSites : resourceNodeSites // ignore: cast_nullable_to_non_nullable
as List<ResourceNodeSite>,startingGold: freezed == startingGold ? _self.startingGold : startingGold // ignore: cast_nullable_to_non_nullable
as int?,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,
  ));
}
/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvironmentSettingsCopyWith<$Res> get environment {
  
  return $EnvironmentSettingsCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameScene].
extension GameScenePatterns on GameScene {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameScene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameScene() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameScene value)  $default,){
final _that = this;
switch (_that) {
case _GameScene():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameScene value)?  $default,){
final _that = this;
switch (_that) {
case _GameScene() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String briefing,  Biome biome,  GameMode mode,  int waveCount,  double aggressionBias,  int version,  HomeLayout homeLayout,  SpawnLayout spawnLayout,  List<HomeSite> homeSites,  List<ResourceNodeSite> resourceNodeSites, @JsonKey(includeIfNull: false)  int? startingGold,  EnvironmentSettings environment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameScene() when $default != null:
return $default(_that.id,_that.name,_that.briefing,_that.biome,_that.mode,_that.waveCount,_that.aggressionBias,_that.version,_that.homeLayout,_that.spawnLayout,_that.homeSites,_that.resourceNodeSites,_that.startingGold,_that.environment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String briefing,  Biome biome,  GameMode mode,  int waveCount,  double aggressionBias,  int version,  HomeLayout homeLayout,  SpawnLayout spawnLayout,  List<HomeSite> homeSites,  List<ResourceNodeSite> resourceNodeSites, @JsonKey(includeIfNull: false)  int? startingGold,  EnvironmentSettings environment)  $default,) {final _that = this;
switch (_that) {
case _GameScene():
return $default(_that.id,_that.name,_that.briefing,_that.biome,_that.mode,_that.waveCount,_that.aggressionBias,_that.version,_that.homeLayout,_that.spawnLayout,_that.homeSites,_that.resourceNodeSites,_that.startingGold,_that.environment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String briefing,  Biome biome,  GameMode mode,  int waveCount,  double aggressionBias,  int version,  HomeLayout homeLayout,  SpawnLayout spawnLayout,  List<HomeSite> homeSites,  List<ResourceNodeSite> resourceNodeSites, @JsonKey(includeIfNull: false)  int? startingGold,  EnvironmentSettings environment)?  $default,) {final _that = this;
switch (_that) {
case _GameScene() when $default != null:
return $default(_that.id,_that.name,_that.briefing,_that.biome,_that.mode,_that.waveCount,_that.aggressionBias,_that.version,_that.homeLayout,_that.spawnLayout,_that.homeSites,_that.resourceNodeSites,_that.startingGold,_that.environment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameScene extends GameScene {
  const _GameScene({required this.id, required this.name, required this.briefing, required this.biome, this.mode = GameMode.waveDefense, this.waveCount = 0, this.aggressionBias = 0.0, this.version = 1, this.homeLayout = HomeLayout.eastEdge, this.spawnLayout = SpawnLayout.single,  List<HomeSite> homeSites = const <HomeSite>[],  List<ResourceNodeSite> resourceNodeSites = const <ResourceNodeSite>[], @JsonKey(includeIfNull: false) this.startingGold, this.environment = const EnvironmentSettings()}): _homeSites = homeSites,_resourceNodeSites = resourceNodeSites,super._();
  factory _GameScene.fromJson(Map<String, dynamic> json) => _$GameSceneFromJson(json);

@override final  String id;
@override final  String name;
/// Flavor text describing the terrain and the incoming strategy.
@override final  String briefing;
@override final  Biome biome;
@override@JsonKey() final  GameMode mode;
/// Total number of waves in this scene's campaign. Unused by
/// [GameMode.skirmish] scenes.
@override@JsonKey() final  int waveCount;
/// Added on top of the AI director's computed aggression each wave (0 =
/// no change, higher = a harder-fought campaign from the start). Unused
/// by [GameMode.skirmish] scenes.
@override@JsonKey() final  double aggressionBias;
/// Bumped whenever any field changes for this [id] - see
/// [sceneNeedsUpdate]/`SceneSyncService`, which uses it to decide whether
/// a server-served scene should replace a cached/built-in one.
@override@JsonKey() final  int version;
/// Unused by [GameMode.skirmish] scenes (see [homeSites] instead).
@override@JsonKey() final  HomeLayout homeLayout;
/// Unused by [GameMode.skirmish] scenes.
@override@JsonKey() final  SpawnLayout spawnLayout;
/// One entry per team seat, for [GameMode.skirmish] scenes - empty for
/// [GameMode.waveDefense] scenes, which always use [homeLayout] instead.
 final  List<HomeSite> _homeSites;
/// One entry per team seat, for [GameMode.skirmish] scenes - empty for
/// [GameMode.waveDefense] scenes, which always use [homeLayout] instead.
@override@JsonKey() List<HomeSite> get homeSites {
  if (_homeSites is EqualUnmodifiableListView) return _homeSites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeSites);
}

/// Capturable second-resource nodes on this scene's map - placed as a
/// fraction of the arena size so the same scene definition still makes
/// sense at any arena size. Empty for scenes with no capturable economy.
 final  List<ResourceNodeSite> _resourceNodeSites;
/// Capturable second-resource nodes on this scene's map - placed as a
/// fraction of the arena size so the same scene definition still makes
/// sense at any arena size. Empty for scenes with no capturable economy.
@override@JsonKey() List<ResourceNodeSite> get resourceNodeSites {
  if (_resourceNodeSites is EqualUnmodifiableListView) return _resourceNodeSites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resourceNodeSites);
}

/// Starting gold for this scene, or null to fall back to
/// `GameConfig.startingGold`/`GameConfig.startingSkirmishGold` (picked by
/// `mode`) - lets a scene/map draft author a different economy.
@override@JsonKey(includeIfNull: false) final  int? startingGold;
/// This scene's lighting, weather and environment sound - defaults to a
/// static, weather-free look with the natural sound mix.
@override@JsonKey() final  EnvironmentSettings environment;

/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSceneCopyWith<_GameScene> get copyWith => __$GameSceneCopyWithImpl<_GameScene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameSceneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameScene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.briefing, briefing) || other.briefing == briefing)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.waveCount, waveCount) || other.waveCount == waveCount)&&(identical(other.aggressionBias, aggressionBias) || other.aggressionBias == aggressionBias)&&(identical(other.version, version) || other.version == version)&&(identical(other.homeLayout, homeLayout) || other.homeLayout == homeLayout)&&(identical(other.spawnLayout, spawnLayout) || other.spawnLayout == spawnLayout)&&const DeepCollectionEquality().equals(other._homeSites, _homeSites)&&const DeepCollectionEquality().equals(other._resourceNodeSites, _resourceNodeSites)&&(identical(other.startingGold, startingGold) || other.startingGold == startingGold)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,briefing,biome,mode,waveCount,aggressionBias,version,homeLayout,spawnLayout,const DeepCollectionEquality().hash(_homeSites),const DeepCollectionEquality().hash(_resourceNodeSites),startingGold,environment);

@override
String toString() {
  return 'GameScene(id: $id, name: $name, briefing: $briefing, biome: $biome, mode: $mode, waveCount: $waveCount, aggressionBias: $aggressionBias, version: $version, homeLayout: $homeLayout, spawnLayout: $spawnLayout, homeSites: $homeSites, resourceNodeSites: $resourceNodeSites, startingGold: $startingGold, environment: $environment)';
}


}

/// @nodoc
abstract mixin class _$GameSceneCopyWith<$Res> implements $GameSceneCopyWith<$Res> {
  factory _$GameSceneCopyWith(_GameScene value, $Res Function(_GameScene) _then) = __$GameSceneCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String briefing, Biome biome, GameMode mode, int waveCount, double aggressionBias, int version, HomeLayout homeLayout, SpawnLayout spawnLayout, List<HomeSite> homeSites, List<ResourceNodeSite> resourceNodeSites,@JsonKey(includeIfNull: false) int? startingGold, EnvironmentSettings environment
});


@override $EnvironmentSettingsCopyWith<$Res> get environment;

}
/// @nodoc
class __$GameSceneCopyWithImpl<$Res>
    implements _$GameSceneCopyWith<$Res> {
  __$GameSceneCopyWithImpl(this._self, this._then);

  final _GameScene _self;
  final $Res Function(_GameScene) _then;

/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? briefing = null,Object? biome = null,Object? mode = null,Object? waveCount = null,Object? aggressionBias = null,Object? version = null,Object? homeLayout = null,Object? spawnLayout = null,Object? homeSites = null,Object? resourceNodeSites = null,Object? startingGold = freezed,Object? environment = null,}) {
  return _then(_GameScene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,briefing: null == briefing ? _self.briefing : briefing // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,waveCount: null == waveCount ? _self.waveCount : waveCount // ignore: cast_nullable_to_non_nullable
as int,aggressionBias: null == aggressionBias ? _self.aggressionBias : aggressionBias // ignore: cast_nullable_to_non_nullable
as double,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,homeLayout: null == homeLayout ? _self.homeLayout : homeLayout // ignore: cast_nullable_to_non_nullable
as HomeLayout,spawnLayout: null == spawnLayout ? _self.spawnLayout : spawnLayout // ignore: cast_nullable_to_non_nullable
as SpawnLayout,homeSites: null == homeSites ? _self._homeSites : homeSites // ignore: cast_nullable_to_non_nullable
as List<HomeSite>,resourceNodeSites: null == resourceNodeSites ? _self._resourceNodeSites : resourceNodeSites // ignore: cast_nullable_to_non_nullable
as List<ResourceNodeSite>,startingGold: freezed == startingGold ? _self.startingGold : startingGold // ignore: cast_nullable_to_non_nullable
as int?,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,
  ));
}

/// Create a copy of GameScene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvironmentSettingsCopyWith<$Res> get environment {
  
  return $EnvironmentSettingsCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}
}


/// @nodoc
mixin _$HomeSite {

 HomeLayout get layout; HomeSiteOwner get owner;
/// Create a copy of HomeSite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSiteCopyWith<HomeSite> get copyWith => _$HomeSiteCopyWithImpl<HomeSite>(this as HomeSite, _$identity);

  /// Serializes this HomeSite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSite&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.owner, owner) || other.owner == owner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layout,owner);

@override
String toString() {
  return 'HomeSite(layout: $layout, owner: $owner)';
}


}

/// @nodoc
abstract mixin class $HomeSiteCopyWith<$Res>  {
  factory $HomeSiteCopyWith(HomeSite value, $Res Function(HomeSite) _then) = _$HomeSiteCopyWithImpl;
@useResult
$Res call({
 HomeLayout layout, HomeSiteOwner owner
});




}
/// @nodoc
class _$HomeSiteCopyWithImpl<$Res>
    implements $HomeSiteCopyWith<$Res> {
  _$HomeSiteCopyWithImpl(this._self, this._then);

  final HomeSite _self;
  final $Res Function(HomeSite) _then;

/// Create a copy of HomeSite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layout = null,Object? owner = null,}) {
  return _then(HomeSite(
layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as HomeLayout,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as HomeSiteOwner,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSite].
extension HomeSitePatterns on HomeSite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSite value)  $default,){
final _that = this;
switch (_that) {
case _HomeSite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSite value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HomeLayout layout,  HomeSiteOwner owner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSite() when $default != null:
return $default(_that.layout,_that.owner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HomeLayout layout,  HomeSiteOwner owner)  $default,) {final _that = this;
switch (_that) {
case _HomeSite():
return $default(_that.layout,_that.owner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HomeLayout layout,  HomeSiteOwner owner)?  $default,) {final _that = this;
switch (_that) {
case _HomeSite() when $default != null:
return $default(_that.layout,_that.owner);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSite implements HomeSite {
  const _HomeSite({required this.layout, required this.owner});
  factory _HomeSite.fromJson(Map<String, dynamic> json) => _$HomeSiteFromJson(json);

@override final  HomeLayout layout;
@override final  HomeSiteOwner owner;

/// Create a copy of HomeSite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSiteCopyWith<_HomeSite> get copyWith => __$HomeSiteCopyWithImpl<_HomeSite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSite&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.owner, owner) || other.owner == owner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layout,owner);

@override
String toString() {
  return 'HomeSite(layout: $layout, owner: $owner)';
}


}

/// @nodoc
abstract mixin class _$HomeSiteCopyWith<$Res> implements $HomeSiteCopyWith<$Res> {
  factory _$HomeSiteCopyWith(_HomeSite value, $Res Function(_HomeSite) _then) = __$HomeSiteCopyWithImpl;
@override @useResult
$Res call({
 HomeLayout layout, HomeSiteOwner owner
});




}
/// @nodoc
class __$HomeSiteCopyWithImpl<$Res>
    implements _$HomeSiteCopyWith<$Res> {
  __$HomeSiteCopyWithImpl(this._self, this._then);

  final _HomeSite _self;
  final $Res Function(_HomeSite) _then;

/// Create a copy of HomeSite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layout = null,Object? owner = null,}) {
  return _then(_HomeSite(
layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as HomeLayout,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as HomeSiteOwner,
  ));
}


}


/// @nodoc
mixin _$ResourceNodeSite {

 double get dx; double get dy;
/// Create a copy of ResourceNodeSite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceNodeSiteCopyWith<ResourceNodeSite> get copyWith => _$ResourceNodeSiteCopyWithImpl<ResourceNodeSite>(this as ResourceNodeSite, _$identity);

  /// Serializes this ResourceNodeSite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceNodeSite&&(identical(other.dx, dx) || other.dx == dx)&&(identical(other.dy, dy) || other.dy == dy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dx,dy);

@override
String toString() {
  return 'ResourceNodeSite(dx: $dx, dy: $dy)';
}


}

/// @nodoc
abstract mixin class $ResourceNodeSiteCopyWith<$Res>  {
  factory $ResourceNodeSiteCopyWith(ResourceNodeSite value, $Res Function(ResourceNodeSite) _then) = _$ResourceNodeSiteCopyWithImpl;
@useResult
$Res call({
 double dx, double dy
});




}
/// @nodoc
class _$ResourceNodeSiteCopyWithImpl<$Res>
    implements $ResourceNodeSiteCopyWith<$Res> {
  _$ResourceNodeSiteCopyWithImpl(this._self, this._then);

  final ResourceNodeSite _self;
  final $Res Function(ResourceNodeSite) _then;

/// Create a copy of ResourceNodeSite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dx = null,Object? dy = null,}) {
  return _then(ResourceNodeSite(
dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ResourceNodeSite].
extension ResourceNodeSitePatterns on ResourceNodeSite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResourceNodeSite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResourceNodeSite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResourceNodeSite value)  $default,){
final _that = this;
switch (_that) {
case _ResourceNodeSite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResourceNodeSite value)?  $default,){
final _that = this;
switch (_that) {
case _ResourceNodeSite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double dx,  double dy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResourceNodeSite() when $default != null:
return $default(_that.dx,_that.dy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double dx,  double dy)  $default,) {final _that = this;
switch (_that) {
case _ResourceNodeSite():
return $default(_that.dx,_that.dy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double dx,  double dy)?  $default,) {final _that = this;
switch (_that) {
case _ResourceNodeSite() when $default != null:
return $default(_that.dx,_that.dy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResourceNodeSite implements ResourceNodeSite {
  const _ResourceNodeSite({required this.dx, required this.dy});
  factory _ResourceNodeSite.fromJson(Map<String, dynamic> json) => _$ResourceNodeSiteFromJson(json);

@override final  double dx;
@override final  double dy;

/// Create a copy of ResourceNodeSite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResourceNodeSiteCopyWith<_ResourceNodeSite> get copyWith => __$ResourceNodeSiteCopyWithImpl<_ResourceNodeSite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResourceNodeSiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResourceNodeSite&&(identical(other.dx, dx) || other.dx == dx)&&(identical(other.dy, dy) || other.dy == dy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dx,dy);

@override
String toString() {
  return 'ResourceNodeSite(dx: $dx, dy: $dy)';
}


}

/// @nodoc
abstract mixin class _$ResourceNodeSiteCopyWith<$Res> implements $ResourceNodeSiteCopyWith<$Res> {
  factory _$ResourceNodeSiteCopyWith(_ResourceNodeSite value, $Res Function(_ResourceNodeSite) _then) = __$ResourceNodeSiteCopyWithImpl;
@override @useResult
$Res call({
 double dx, double dy
});




}
/// @nodoc
class __$ResourceNodeSiteCopyWithImpl<$Res>
    implements _$ResourceNodeSiteCopyWith<$Res> {
  __$ResourceNodeSiteCopyWithImpl(this._self, this._then);

  final _ResourceNodeSite _self;
  final $Res Function(_ResourceNodeSite) _then;

/// Create a copy of ResourceNodeSite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dx = null,Object? dy = null,}) {
  return _then(_ResourceNodeSite(
dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
