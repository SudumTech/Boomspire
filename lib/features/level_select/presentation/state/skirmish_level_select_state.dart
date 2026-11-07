import 'package:flutter/foundation.dart';

import '../../../game_core/domain/models/game_difficulty.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../map_editor/domain/models/map_draft.dart';
import '../../../map_editor/domain/repos/map_draft_repository.dart';

/// Page-owned state for [SkirmishLevelSelectPage]: loads the user's
/// skirmish-mode map drafts once and exposes them read-only. Instantiated
/// and disposed by the page's own State.
class SkirmishLevelSelectState {
  final MapDraftRepository _draftRepository;
  final ValueNotifier<List<MapDraft>?> _drafts = ValueNotifier(null);
  final ValueNotifier<GameDifficulty> _difficulty = ValueNotifier(
    GameDifficulty.normal,
  );

  SkirmishLevelSelectState(this._draftRepository);

  ValueListenable<List<MapDraft>?> get drafts => _drafts;

  ValueListenable<GameDifficulty> get difficulty => _difficulty;

  void dispose() {
    _drafts.dispose();
    _difficulty.dispose();
  }

  void selectDifficulty(GameDifficulty value) => _difficulty.value = value;

  Future<void> load() async {
    final all = await _draftRepository.listDrafts();
    _drafts.value = all.where((d) => d.mode == GameMode.skirmish).toList();
  }
}
