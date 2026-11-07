// Regression coverage proving the map editor actually exposes every
// scene-editing tool, biome, and environment/config knob its domain model
// supports - guards against a new EditorTool/Biome/weather field being added
// to the model but left unreachable from MapEditorDraftState (this is
// exactly how the canvas preview once shipped with wind/trees defined in
// the model but never wired into any editable/visible path).
import 'dart:ui';

import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/extensions/game_mode_extensions.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/models/water_path.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/map_editor/presentation/state/map_editor_draft_state.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:boomspire/features/terrain/domain/models/obstacle_kind.dart';
import 'package:boomspire/features/terrain/extensions/biome_extensions.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  MapEditorDraftState newState() =>
      MapEditorDraftState(const MapDraft(id: 'draft', name: 'Draft'));

  // Canvas size matching the draft's default arena so `toWorld` maps
  // on-screen offsets to world coordinates 1:1.
  const canvasSize = Size(1280, 720);

  group('MapEditorDraftState scene edits', () {
    test('every EditorTool has a reachable effect on the draft', () async {
      final state = newState();
      addTearDown(state.dispose);
      await state.initialize();

      // An exhaustive switch (not a loop) so adding a new EditorTool without
      // a case here fails to compile until this test covers it too.
      for (final tool in EditorTool.values) {
        switch (tool) {
          case EditorTool.mountain:
          case EditorTool.dune:
            final kind = tool == EditorTool.mountain
                ? ObstacleKind.mountain
                : ObstacleKind.dune;
            state.setTool(tool);
            state.handlePanStart(const Offset(20, 20), canvasSize);
            state.handlePanEnd();
            expect(
              state.draft.value.paintedCells.any(
                (c) => c.col == 0 && c.row == 0 && c.kind == kind,
              ),
              isTrue,
              reason: '$tool should paint a $kind cell',
            );
          case EditorTool.erase:
            state.setTool(EditorTool.mountain);
            state.handlePanStart(const Offset(20, 20), canvasSize);
            state.handlePanEnd();
            state.setTool(EditorTool.erase);
            state.handlePanStart(const Offset(20, 20), canvasSize);
            state.handlePanEnd();
            expect(
              state.draft.value.paintedCells.any(
                (c) => c.col == 0 && c.row == 0,
              ),
              isFalse,
              reason: 'erase should clear a previously painted cell',
            );
          case EditorTool.tree:
            state.setTool(EditorTool.tree);
            state.handlePanStart(const Offset(700, 20), canvasSize);
            state.handlePanEnd();
            expect(
              state.draft.value.treeCells.any((c) => c.col == 17 && c.row == 0),
              isTrue,
              reason: 'tree tool should place a tree cell on any biome',
            );
            state.setTool(EditorTool.erase);
            state.handlePanStart(const Offset(700, 20), canvasSize);
            state.handlePanEnd();
            expect(
              state.draft.value.treeCells.any((c) => c.col == 17 && c.row == 0),
              isFalse,
              reason: 'erase should also clear a previously painted tree',
            );
          case EditorTool.river:
          case EditorTool.lake:
          case EditorTool.lava:
          case EditorTool.volcanicLake:
            final before = state.draft.value.waterPaths.length;
            state.setTool(tool);
            state.handlePanStart(const Offset(100, 100), canvasSize);
            state.handlePanUpdate(const Offset(300, 100), canvasSize);
            state.handlePanEnd();
            expect(state.draft.value.waterPaths.length, before + 1);
            expect(state.draft.value.waterPaths.last.kind, switch (tool) {
              EditorTool.lake => WaterFeatureKind.lake,
              EditorTool.lava => WaterFeatureKind.lava,
              EditorTool.volcanicLake => WaterFeatureKind.volcanicLake,
              _ => WaterFeatureKind.river,
            });
          case EditorTool.resourceNode:
            state.setTool(EditorTool.resourceNode);
            final before = state.draft.value.resourceNodes.length;
            state.handlePanStart(const Offset(640, 360), canvasSize);
            expect(state.draft.value.resourceNodes.length, before + 1);
            // Tapping the same spot again removes it.
            state.handlePanStart(const Offset(640, 360), canvasSize);
            expect(state.draft.value.resourceNodes.length, before);
          case EditorTool.homeSite:
            state.setTool(EditorTool.homeSite);
            final before = state.draft.value.homeSites.length;
            state.handlePanStart(const Offset(500, 500), canvasSize);
            expect(state.draft.value.homeSites.length, before + 1);
            // Tapping the same spot again toggles the site back off.
            state.handlePanStart(const Offset(500, 500), canvasSize);
            expect(state.draft.value.homeSites.length, before);
        }
      }
    });

    test('the eraser removes rivers, lakes, lava, volcanic lakes and home '
        'sites, not just painted cells and trees', () async {
      final state = newState();
      addTearDown(state.dispose);
      await state.initialize();

      void drag(EditorTool tool, List<Offset> points) {
        state.setTool(tool);
        state.handlePanStart(points.first, canvasSize);
        for (final p in points.skip(1)) {
          state.handlePanUpdate(p, canvasSize);
        }
        state.handlePanEnd();
      }

      // A river along y=100, lava along y=300, a lake and a volcanic lake as
      // closed loops, plus a home site.
      drag(EditorTool.river, const [Offset(100, 100), Offset(500, 100)]);
      drag(EditorTool.lava, const [Offset(100, 300), Offset(500, 300)]);
      drag(EditorTool.lake, const [
        Offset(700, 100),
        Offset(900, 100),
        Offset(900, 250),
        Offset(700, 250),
      ]);
      drag(EditorTool.volcanicLake, const [
        Offset(700, 400),
        Offset(900, 400),
        Offset(900, 550),
        Offset(700, 550),
      ]);
      state.setTool(EditorTool.homeSite);
      state.handlePanStart(const Offset(200, 600), canvasSize);
      expect(state.draft.value.waterPaths, hasLength(4));
      expect(state.draft.value.homeSites, hasLength(1));

      void eraseAt(Offset at) {
        state.setTool(EditorTool.erase);
        state.handlePanStart(at, canvasSize);
        state.handlePanEnd();
      }

      // Touching the middle of a river stroke removes just that river.
      eraseAt(const Offset(300, 100));
      expect(
        state.draft.value.waterPaths.map((p) => p.kind),
        isNot(contains(WaterFeatureKind.river)),
      );
      expect(state.draft.value.waterPaths, hasLength(3));

      eraseAt(const Offset(300, 300)); // lava
      eraseAt(const Offset(800, 175)); // inside the lake
      eraseAt(const Offset(800, 475)); // inside the volcanic lake
      expect(state.draft.value.waterPaths, isEmpty);

      eraseAt(const Offset(200, 600)); // the home site
      expect(state.draft.value.homeSites, isEmpty);
    });

    test('the eraser leaves water it does not touch alone', () async {
      final state = newState();
      addTearDown(state.dispose);
      await state.initialize();

      state.setTool(EditorTool.river);
      state.handlePanStart(const Offset(100, 100), canvasSize);
      state.handlePanUpdate(const Offset(500, 100), canvasSize);
      state.handlePanEnd();

      state.setTool(EditorTool.erase);
      state.handlePanStart(const Offset(300, 600), canvasSize); // far away
      state.handlePanEnd();
      expect(state.draft.value.waterPaths, hasLength(1));
    });

    group('modes and home sites', () {
      test('tower defense has one home, skirmish has two (for now)', () async {
        final state = newState();
        addTearDown(state.dispose);
        await state.initialize();

        expect(GameMode.waveDefense.maxHomeSites, 1);
        expect(GameMode.skirmish.maxHomeSites, 2);

        state.setTool(EditorTool.homeSite);
        state.handlePanStart(const Offset(100, 100), canvasSize);
        state.handlePanStart(const Offset(300, 100), canvasSize);
        expect(
          state.draft.value.homeSites,
          hasLength(1),
          reason: 'tower defense',
        );
        expect(state.notice.value, isNotNull);

        state.setMode(GameMode.skirmish);
        state.handlePanStart(const Offset(300, 100), canvasSize);
        state.handlePanStart(const Offset(500, 100), canvasSize); // a third
        expect(state.draft.value.homeSites, hasLength(2), reason: 'skirmish');
      });

      test('going back to tower defense keeps only the first home', () async {
        final state = newState();
        addTearDown(state.dispose);
        await state.initialize();
        state.setMode(GameMode.skirmish);
        state.setTool(EditorTool.homeSite);
        state.handlePanStart(const Offset(100, 100), canvasSize);
        state.handlePanStart(const Offset(400, 400), canvasSize);
        expect(state.draft.value.homeSites, hasLength(2));

        state.setMode(GameMode.waveDefense);
        expect(state.draft.value.homeSites, hasLength(1));
        expect(state.draft.value.homeSites.single.x, closeTo(100, 1));
      });

      test(
        'a skirmish can only be played with a home for every side',
        () async {
          final state = newState();
          addTearDown(state.dispose);
          await state.initialize();
          state.setMode(GameMode.skirmish);
          expect(state.canPlaySkirmish(), isFalse);
          expect(state.notice.value, isNotNull);

          state.setTool(EditorTool.homeSite);
          state.handlePanStart(const Offset(100, 100), canvasSize);
          expect(state.canPlaySkirmish(), isFalse);
          state.handlePanStart(const Offset(900, 500), canvasSize);
          expect(state.canPlaySkirmish(), isTrue);
        },
      );

      test(
        'resource nodes are capped, saved in the draft and erasable',
        () async {
          final state = newState();
          addTearDown(state.dispose);
          await state.initialize();

          state.setTool(EditorTool.resourceNode);
          for (var i = 0; i < MapEditorDraftState.maxResourceNodes + 3; i++) {
            state.handlePanStart(Offset(60.0 + i * 120, 200), canvasSize);
          }
          expect(
            state.draft.value.resourceNodes,
            hasLength(MapEditorDraftState.maxResourceNodes),
          );
          final json = state.draft.value.toJson();
          expect(MapDraft.fromJson(json).resourceNodes, hasLength(8));

          state.setTool(EditorTool.erase);
          state.handlePanStart(const Offset(60, 200), canvasSize);
          expect(state.draft.value.resourceNodes, hasLength(7));
        },
      );
    });

    test('a brush type (Biome) can be set for every obstacle/water tool and '
        'is stamped onto newly painted cells/paths', () async {
      final state = newState();
      addTearDown(state.dispose);
      await state.initialize();

      expect(state.variant.value, isNull);

      for (final tool in [
        EditorTool.mountain,
        EditorTool.dune,
        EditorTool.river,
        EditorTool.lake,
        EditorTool.lava,
        EditorTool.volcanicLake,
      ]) {
        for (final brushType in Biome.values) {
          state.setVariant(brushType);
          expect(state.variant.value, brushType);
          state.setTool(tool);
          state.handlePanStart(const Offset(20, 20), canvasSize);
          if (tool == EditorTool.river ||
              tool == EditorTool.lake ||
              tool == EditorTool.lava ||
              tool == EditorTool.volcanicLake) {
            state.handlePanUpdate(const Offset(300, 100), canvasSize);
          }
          state.handlePanEnd();
        }
      }

      expect(
        state.draft.value.paintedCells.every(
          (c) => c.variant == Biome.values.last,
        ),
        isTrue,
        reason:
            'the last selected brush type should stick to every '
            'newly painted obstacle cell',
      );
      expect(
        state.draft.value.waterPaths.last.variant,
        Biome.values.last,
        reason:
            'the last selected brush type should stick to the most '
            'recently drawn water path',
      );

      // Switching back to "match biome" (null) stamps no override.
      state.setVariant(null);
      state.setTool(EditorTool.mountain);
      state.handlePanStart(const Offset(700, 500), canvasSize);
      state.handlePanEnd();
      expect(
        state.draft.value.paintedCells
            .firstWhere((c) => c.col == 17 && c.row == 12)
            .variant,
        isNull,
      );
    });

    test('a tree brush-type override is stamped on the TreeCell itself '
        '(honored unconditionally at generation time, same as any other '
        'brush variant - see map_draft_test.dart)', () async {
      final state = newState();
      addTearDown(state.dispose);
      await state.initialize();

      state.setVariant(Biome.snowTundra);
      state.setTool(EditorTool.tree);
      state.handlePanStart(const Offset(20, 20), canvasSize);
      state.handlePanEnd();

      expect(state.draft.value.treeCells.single.variant, Biome.snowTundra);
    });

    test('every Biome is selectable and fully described', () {
      final state = newState();
      addTearDown(state.dispose);

      for (final biome in Biome.values) {
        state.setBiome(biome);
        expect(state.draft.value.biome, biome);
        expect(biome.displayName, isNotEmpty);
        expect(biome.description, isNotEmpty);
      }
    });

    test('every weather keyframe intensity is editable', () {
      final state = newState();
      addTearDown(state.dispose);

      // A fresh draft's environment already carries one default keyframe.
      expect(state.draft.value.environment.timeline, hasLength(1));

      const edited = WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.4,
        rainIntensity: 0.5,
        snowIntensity: 0.6,
        fogDensity: 0.7,
        cloudCover: 0.8,
      );
      state.replaceKeyframe(0, edited);
      expect(state.draft.value.environment.timeline.single, edited);

      state.addKeyframe();
      expect(state.draft.value.environment.timeline, hasLength(2));
      state.removeKeyframe(1);
      expect(state.draft.value.environment.timeline, hasLength(1));
    });

    test('every environment/config knob is settable', () {
      final state = newState();
      addTearDown(state.dispose);

      state.setDynamicWeather(true);
      expect(state.draft.value.environment.dynamicWeather, isTrue);

      state.setSunAngle(0.75);
      expect(state.draft.value.environment.sunAngle, 0.75);

      state.setPreviewProgress(0.5);
      expect(state.previewProgress.value, 0.5);

      state.applyArenaSize('2000', '1500');
      expect(state.draft.value.arenaWidth, 2000);
      expect(state.draft.value.arenaHeight, 1500);

      state.applyStartingGold('500');
      expect(state.draft.value.startingGold, 500);

      state.applyWaveCount('7');
      expect(state.draft.value.waveCount, 7);

      state.setMode(GameMode.skirmish);
      expect(state.maxHomeSites, 2);
      state.setMode(GameMode.waveDefense);
      expect(state.maxHomeSites, 1);

      state.setWaveUnitCount(UnitKind.soldier, 4);
      expect(state.currentLoadout.unitCounts[UnitKind.soldier.name], 4);
      state.randomizeSelectedWave();
      state.randomizeAllWaves();
      expect(state.draft.value.waveLoadouts, isNotEmpty);
      state.clearSelectedWave();
      expect(state.hasCustomLoadout(state.currentLoadout.waveNumber), isFalse);

      expect(state.zoomBy(1.25), closeTo(1.25, 1e-9));
      expect(state.resetZoom(), 1.0);
    });
  });
}
