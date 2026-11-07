import '../models/game_scene.dart';

/// Where the scene-select screen gets its maps: every built-in scene that
/// plays in a given [GameMode]. The scene itself decides the gameplay (tower
/// defense or skirmish) - callers never branch on where it came from.
abstract class SceneCatalogRepository {
  List<GameScene> scenesFor(GameMode mode);
}
