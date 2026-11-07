import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_difficulty.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/impl/editor_terrain_generator.dart';
import '../../map_editor/impl/map_draft_launch_args_factory.dart';

/// Starts a map. The scene's own mode decides what happens - a skirmish map
/// goes to the battlefield-placement screen, a tower-defense map straight
/// into the game - so every select screen launches through here.
class SceneLauncher {
  const SceneLauncher._();

  /// Opens a built-in [scene]; completes when the player comes back.
  static Future<void> openScene(
    BuildContext context,
    GameScene scene,
    GameDifficulty difficulty,
  ) async {
    switch (scene.mode) {
      case GameMode.skirmish:
        await context.push(
          Routes.skirmishPlacement.route,
          extra: SkirmishPlacementArgs(scene: scene, difficulty: difficulty),
        );
      case GameMode.waveDefense:
        await context.push(
          Routes.game.route,
          extra: GameRouteArgs(scene: scene, difficulty: difficulty),
        );
    }
  }

  /// Opens a hand-made [draft] the same way.
  static Future<void> openDraft(
    BuildContext context,
    MapDraft draft,
    GameDifficulty difficulty,
  ) async {
    switch (draft.mode) {
      case GameMode.skirmish:
        await context.push(
          Routes.skirmishPlacement.route,
          extra: SkirmishPlacementArgs(draft: draft, difficulty: difficulty),
        );
      case GameMode.waveDefense:
        final preview = await EditorTerrainGenerator().generate(draft);
        if (!context.mounted) return;
        await context.push(
          Routes.game.route,
          extra: waveDefenseLaunchArgs(
            draft,
            preview,
            briefing: S.current.testingHandDrawnMapBriefingEditorPage,
            difficulty: difficulty,
          ),
        );
    }
  }
}
