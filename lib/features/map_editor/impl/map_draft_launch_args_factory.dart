import '../../../core/router/routes.dart';
import '../../game_core/domain/models/game_difficulty.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../waves/impl/wave_repository_impl.dart';
import '../domain/models/editor_terrain_preview.dart';
import '../domain/models/map_draft.dart';
import 'draft_wave_repository.dart';
import 'map_draft_scene_factory.dart';
import 'map_draft_terrain_repository.dart';

/// Builds the route arguments that play a hand-made tower-defense map: its
/// scene, its terrain and its wave loadouts. Shared by the editor's test
/// play and the scene-select screen, so both start the same match.
GameRouteArgs waveDefenseLaunchArgs(
  MapDraft draft,
  EditorTerrainPreview preview, {
  required String briefing,
  GameDifficulty difficulty = GameDifficulty.normal,
}) => GameRouteArgs(
  scene: const MapDraftSceneFactory().sceneFor(
    draft,
    mode: GameMode.waveDefense,
    briefing: briefing,
  ),
  difficulty: difficulty,
  terrainRepository: MapDraftTerrainRepository(
    draft: draft,
    preview: preview,
    humanBaseSite: draft.homeSites.isNotEmpty ? draft.homeSites.first : null,
  ),
  waveRepository: DraftWaveRepository(
    loadouts: draft.waveLoadouts,
    totalWaves: draft.waveCount,
    fallback: WaveRepositoryImpl(
      totalWaves: draft.waveCount,
      biome: draft.biome,
    ),
  ),
);
