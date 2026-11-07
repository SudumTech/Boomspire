import 'package:boomspire/core/di/service_locator.dart';
import 'package:boomspire/features/game_core/domain/enums/game_mode.dart';
import 'package:boomspire/features/map_editor/domain/enums/editor_tool.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/extensions/editor_tool_extensions.dart';
import 'package:boomspire/features/map_editor/presentation/map_editor_page.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:boomspire/features/terrain/extensions/biome_extensions.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// UI-level regression coverage for the map editor page: proves every
/// config/editor "tool" that [MapEditorDraftState] exposes (see
/// `map_editor_draft_state_test.dart` for the state-layer coverage) is
/// actually reachable as a rendered widget - not just a state API that
/// nothing in the UI wires up.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  Future<void> pumpEditor(WidgetTester tester) async {
    setupServiceLocator();
    // The right-hand control panel is a single scrollable ListView; make
    // the test surface tall enough that every section (Brush/Map/Waves/
    // Environment) actually gets laid out without needing to scroll to it.
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: MapEditorPage(
          initialDraft: MapDraft(id: 'ui-test', name: 'UI Test Map'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('every brush tool has a button in the tool palette', (
    tester,
  ) async {
    await pumpEditor(tester);

    for (final tool in EditorTool.values) {
      expect(
        find.byTooltip(tool.label),
        findsOneWidget,
        reason: 'No palette button renders EditorTool.$tool',
      );
    }
  });

  testWidgets('biome and mode dropdowns offer every enum option', (
    tester,
  ) async {
    await pumpEditor(tester);

    await tester.tap(find.byType(DropdownButtonFormField<Biome>));
    await tester.pumpAndSettle();
    for (final biome in Biome.values) {
      expect(
        find.text(biome.displayName),
        findsWidgets,
        reason: 'Biome dropdown is missing an option for $biome',
      );
    }
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();

    // The mode is a two-way switch: Tower Defense (the default, one home)
    // and Skirmish (two homes), with the allowed home count spelled out.
    expect(find.byType(SegmentedButton<GameMode>), findsOneWidget);
    expect(find.text(S.current.waveDefenseOptionEditorPage), findsOneWidget);
    expect(find.text(S.current.skirmishOptionEditorPage), findsOneWidget);
    expect(find.text(S.current.modeHomesHintEditorPage(1)), findsOneWidget);
    await tester.tap(find.text(S.current.skirmishOptionEditorPage));
    await tester.pumpAndSettle();
    expect(find.text(S.current.modeHomesHintEditorPage(2)), findsOneWidget);
    // Skirmish maps have no waves to author.
    expect(find.text(S.current.wavesLabelEditorPage), findsNothing);

    // The default draft's biome (grassPlains) has no trees - the hint next
    // to the biome picker must say so, proving tree presence is visible in
    // the UI even though there's no separate paintable "tree tool".
    expect(find.text(S.current.treesOffHintEditorPage), findsOneWidget);
  });

  testWidgets('map size and starting gold fields are present', (tester) async {
    await pumpEditor(tester);

    expect(find.text(S.current.widthLabelEditorPage), findsOneWidget);
    expect(find.text(S.current.heightLabelEditorPage), findsOneWidget);
    expect(find.text(S.current.startingGoldLabelEditorPage), findsOneWidget);
  });

  testWidgets('wave editor controls are present for wave-defense mode', (
    tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text(S.current.wavesLabelEditorPage), findsOneWidget);
    expect(find.text(S.current.waveCountLabelEditorPage), findsOneWidget);
    expect(find.widgetWithIcon(OutlinedButton, Icons.shuffle), findsOneWidget);
  });

  testWidgets(
    'environment section renders the dynamic-weather switch, sun/preview '
    'sliders, and every weather-keyframe control',
    (tester) async {
      await pumpEditor(tester);

      expect(
        find.text(S.current.dynamicWeatherLabelEditorPage),
        findsOneWidget,
      );
      expect(
        find.text(S.current.weatherTimelineLabelEditorPage),
        findsOneWidget,
      );
      expect(find.text(S.current.addKeyframeLabelEditorPage), findsOneWidget);

      // Sun angle + preview-progress sliders, plus one Wind/Rain/Snow/Fog/
      // Cloud/Dust/Birds slider each for the single default keyframe.
      expect(find.byType(Slider), findsNWidgets(9));

      expect(find.text(S.current.windLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.rainLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.snowLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.fogLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.cloudLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.dustLabelEditorPage), findsOneWidget);
      expect(find.text(S.current.birdsLabelEditorPage), findsOneWidget);
    },
  );
}
