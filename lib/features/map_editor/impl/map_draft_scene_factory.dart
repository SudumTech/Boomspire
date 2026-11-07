import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../domain/models/map_draft.dart';

/// Builds the [GameScene] a hand-made map plays as - the one place a draft
/// becomes a match, so a test-play from the editor and a skirmish started
/// from the placement screen can never disagree about what the map says
/// (starting gold, weather/sun, wave count...).
class MapDraftSceneFactory {
  const MapDraftSceneFactory();

  GameScene sceneFor(
    MapDraft draft, {
    required GameMode mode,
    required String briefing,
  }) => GameScene(
    id: 'draft-${draft.id}',
    name: draft.name.isEmpty ? S.current.untitledMapEditorPage : draft.name,
    briefing: briefing,
    biome: draft.biome,
    mode: mode,
    waveCount: mode == GameMode.waveDefense ? draft.waveCount : 0,
    // The same amount for every side: the player, and the AI opponent in a
    // skirmish (see `BoomspireGame._setupSkirmishState`).
    startingGold: draft.startingGold,
    environment: draft.environment,
  );
}
