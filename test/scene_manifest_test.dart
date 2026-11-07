// The scene manifest is the source of truth for every built-in map. These
// tests prove the bundled JSON parses into valid freezed GameScenes, stays
// in sync with the Dart catalog and the server copy, and carries each map's
// weather and environment sound.
import 'dart:convert';
import 'dart:io';

import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/bundled_scenes_seed.dart';
import 'package:boomspire/features/game_core/impl/scene_manifest_builder.dart';
import 'package:flutter_test/flutter_test.dart';

const _bundled = 'assets/scenes/scenes.json';
const _server = 'server/scene_manifest.json';

List<GameScene> _read(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as List<dynamic>)
        .map((e) => GameScene.fromJson(e as Map<String, dynamic>))
        .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `BOOMSPIRE_WRITE_SCENES=1 flutter test test/scene_manifest_test.dart`
  // rewrites both copies from the Dart catalog.
  if (Platform.environment['BOOMSPIRE_WRITE_SCENES'] == '1') {
    final json = buildSceneManifestJson();
    File(_bundled).writeAsStringSync(json);
    File(_server).writeAsStringSync(json);
  }

  test('scenes.json parses into valid GameScenes', () {
    final scenes = _read(_bundled);
    expect(scenes, isNotEmpty);
    expect(scenes.map((s) => s.id).toSet(), hasLength(scenes.length));
    for (final s in scenes) {
      expect(s.version, greaterThan(0));
    }
  });

  test('scenes.json covers every built-in scene and equals the catalog', () {
    GameScenes.resetOverridesForTest();
    final catalog = [...GameScenes.all, ...GameScenes.skirmishes];
    expect(_read(_bundled), catalog);
  });

  test('bundled and server copies are identical', () {
    expect(File(_bundled).readAsStringSync(), File(_server).readAsStringSync());
    expect(File(_bundled).readAsStringSync(), buildSceneManifestJson());
  });

  test('every map has its own weather and an environment sound mix', () {
    for (final scene in _read(_bundled)) {
      final env = scene.environment;
      expect(env.timeline, isNotEmpty, reason: scene.id);
      expect(env.ambience.enabled, isTrue, reason: scene.id);
      // Not the empty default: some weather is authored.
      final k = env.timeline.first;
      expect(
        k.windStrength +
            k.snowIntensity +
            k.rainIntensity +
            k.dustIntensity +
            k.birdActivity,
        greaterThan(0),
        reason: '${scene.id} has no weather',
      );
    }
  });

  test('a scene survives a JSON round trip unchanged', () {
    for (final scene in _read(_bundled)) {
      expect(GameScene.fromJson(scene.toJson()), scene);
    }
  });

  test('the bundled seed loads as the catalog the game boots with', () async {
    final seed = await loadBundledScenesSeed();
    expect(seed.length, GameScenes.all.length + GameScenes.skirmishes.length);
    GameScenes.applyOverrides(seed);
    addTearDown(GameScenes.resetOverridesForTest);
    expect(
      GameScenes.all
          .firstWhere((s) => s.id == 'howling-icefield')
          .environment
          .ambience
          .wind,
      1.4,
    );
  });
}
