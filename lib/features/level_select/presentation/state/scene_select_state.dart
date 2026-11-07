import 'package:flutter/foundation.dart';

import '../../../game_core/domain/models/game_difficulty.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../game_core/domain/repos/scene_catalog_repository.dart';
import '../../../map_editor/domain/models/map_draft.dart';
import '../../../map_editor/domain/repos/map_draft_repository.dart';
import '../../../progress/domain/models/progress_snapshot.dart';
import '../../../progress/domain/repos/progress_repository.dart';

/// Page-owned state for [SceneSelectPage] - the same for every mode: the
/// built-in scenes of [mode] (from the scene catalog), the user's saved maps
/// of that mode, campaign progress, and the chosen difficulty. Instantiated
/// and disposed by the page's own State.
class SceneSelectState {
  final GameMode mode;
  final SceneCatalogRepository _catalog;
  final MapDraftRepository _drafts;
  final ProgressRepository _progress;

  final ValueNotifier<List<MapDraft>?> _draftList = ValueNotifier(null);
  final ValueNotifier<ProgressSnapshot?> _progressValue = ValueNotifier(null);
  final ValueNotifier<GameDifficulty> _difficulty = ValueNotifier(
    GameDifficulty.normal,
  );

  SceneSelectState(this.mode, this._catalog, this._drafts, this._progress);

  ValueListenable<GameDifficulty> get difficulty => _difficulty;

  /// `null` while loading.
  ValueListenable<List<MapDraft>?> get drafts => _draftList;

  ValueListenable<ProgressSnapshot?> get progress => _progressValue;

  /// The built-in scenes that play in this state's [mode].
  List<GameScene> get scenes => _catalog.scenesFor(mode);

  void dispose() {
    _draftList.dispose();
    _progressValue.dispose();
    _difficulty.dispose();
  }

  Future<void> load() async {
    _progressValue.value = await _progress.load();
    final all = await _drafts.listDrafts();
    _draftList.value = all.where((d) => d.mode == mode).toList();
  }

  void selectDifficulty(GameDifficulty value) => _difficulty.value = value;
}
