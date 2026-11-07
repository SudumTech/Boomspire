import '../domain/models/game_scene.dart';
import '../domain/models/game_scenes.dart';
import '../domain/repos/scene_catalog_repository.dart';

/// Reads the loaded catalog (`GameScenes`: the bundled scenes JSON, layered
/// with synced/cached scenes at boot) and filters it by mode.
class SceneCatalogRepositoryImpl implements SceneCatalogRepository {
  @override
  List<GameScene> scenesFor(GameMode mode) => [
    ...GameScenes.all,
    ...GameScenes.skirmishes,
  ].where((scene) => scene.mode == mode).toList();
}
