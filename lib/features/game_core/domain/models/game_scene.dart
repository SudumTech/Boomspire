import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../map_editor/domain/models/environment_settings.dart';
import '../../../terrain/domain/models/biome.dart';
import '../enums/game_mode.dart';
import '../enums/home_layout.dart';
import '../enums/home_site_owner.dart';
import '../enums/spawn_layout.dart';

export '../enums/game_mode.dart';
export '../enums/home_layout.dart';
export '../enums/home_site_owner.dart';
export '../enums/spawn_layout.dart';

part 'game_scene.freezed.dart';
part 'game_scene.g.dart';

/// Pure version comparison - mirrors `GameObjectDefinition`'s `needsUpdate`
/// so a server-served [GameScene] only replaces a cached/built-in one when
/// it's actually newer.
bool sceneNeedsUpdate({
  required GameScene cached,
  required GameScene incoming,
}) => incoming.version > cached.version;

/// A playable scene: a terrain flavor (biome) paired with its own campaign
/// length, opening strategy, and the shape of its base/attack layout. Each
/// scene is a full, self-contained mission rather than just a re-skinned
/// map.
///
/// This is the single shape of a map everywhere it exists: the bundled
/// `assets/scenes/scenes.json` (the source of truth the game loads), the
/// server copy, the on-device cache and maps made in the editor all
/// serialize through [toJson]/[fromJson].
@freezed
abstract class GameScene with _$GameScene {
  const factory GameScene({
    required String id,
    required String name,

    /// Flavor text describing the terrain and the incoming strategy.
    required String briefing,
    required Biome biome,
    @Default(GameMode.waveDefense) GameMode mode,

    /// Total number of waves in this scene's campaign. Unused by
    /// [GameMode.skirmish] scenes.
    @Default(0) int waveCount,

    /// Added on top of the AI director's computed aggression each wave (0 =
    /// no change, higher = a harder-fought campaign from the start). Unused
    /// by [GameMode.skirmish] scenes.
    @Default(0.0) double aggressionBias,

    /// Bumped whenever any field changes for this [id] - see
    /// [sceneNeedsUpdate]/`SceneSyncService`, which uses it to decide whether
    /// a server-served scene should replace a cached/built-in one.
    @Default(1) int version,

    /// Unused by [GameMode.skirmish] scenes (see [homeSites] instead).
    @Default(HomeLayout.eastEdge) HomeLayout homeLayout,

    /// Unused by [GameMode.skirmish] scenes.
    @Default(SpawnLayout.single) SpawnLayout spawnLayout,

    /// One entry per team seat, for [GameMode.skirmish] scenes - empty for
    /// [GameMode.waveDefense] scenes, which always use [homeLayout] instead.
    @Default(<HomeSite>[]) List<HomeSite> homeSites,

    /// Capturable second-resource nodes on this scene's map - placed as a
    /// fraction of the arena size so the same scene definition still makes
    /// sense at any arena size. Empty for scenes with no capturable economy.
    @Default(<ResourceNodeSite>[]) List<ResourceNodeSite> resourceNodeSites,

    /// Starting gold for this scene, or null to fall back to
    /// `GameConfig.startingGold`/`GameConfig.startingSkirmishGold` (picked by
    /// `mode`) - lets a scene/map draft author a different economy.
    @JsonKey(includeIfNull: false) int? startingGold,

    /// This scene's lighting, weather and environment sound - defaults to a
    /// static, weather-free look with the natural sound mix.
    @Default(EnvironmentSettings()) EnvironmentSettings environment,
  }) = _GameScene;

  factory GameScene.fromJson(Map<String, dynamic> json) =>
      _$GameSceneFromJson(json);

  const GameScene._();

  /// A copy of this scene with different [homeSites] and everything else
  /// (weather, sound, starting gold, nodes, ...) carried over unchanged.
  GameScene withHomeSites(List<HomeSite> sites) => copyWith(homeSites: sites);
}

/// One buildable home site on a skirmish map - a scene lists one per team
/// seat that can fight in that match.
@freezed
abstract class HomeSite with _$HomeSite {
  const factory HomeSite({
    required HomeLayout layout,
    required HomeSiteOwner owner,
  }) = _HomeSite;

  factory HomeSite.fromJson(Map<String, dynamic> json) =>
      _$HomeSiteFromJson(json);
}

/// A capturable resource node's placement on a scene's map, as a fraction of
/// the arena size (0,0 = top-left, 1,1 = bottom-right) so the same scene
/// definition still makes sense at any arena size.
@freezed
abstract class ResourceNodeSite with _$ResourceNodeSite {
  const factory ResourceNodeSite({required double dx, required double dy}) =
      _ResourceNodeSite;

  factory ResourceNodeSite.fromJson(Map<String, dynamic> json) =>
      _$ResourceNodeSiteFromJson(json);
}
