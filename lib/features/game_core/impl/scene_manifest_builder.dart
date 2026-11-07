import 'dart:convert';

import '../domain/models/game_scenes.dart';

/// The scene manifest - every built-in map (tower defense and skirmish) with
/// its weather and environment-sound mix - as JSON. Written to both the
/// bundled `assets/scenes/scenes.json` and the server copy, and compared
/// against them in tests so they can never drift from the catalog.
String buildSceneManifestJson() {
  GameScenes.resetOverridesForTest();
  final scenes = [...GameScenes.all, ...GameScenes.skirmishes];
  final json = const JsonEncoder.withIndent('  ')
      .convert(scenes.map((s) => s.toJson()).toList());
  return '$json\n';
}
