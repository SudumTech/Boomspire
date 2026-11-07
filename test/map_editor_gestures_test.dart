// Drives the map editor canvas with real taps (not state calls), because the
// placement tools - home site and resource node - only work from a tap, which
// once did nothing at all (the canvas only listened for drags).
import 'package:boomspire/core/di/service_locator.dart';
import 'package:boomspire/features/game_core/domain/enums/game_mode.dart';
import 'package:boomspire/features/game_core/extensions/game_mode_extensions.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/extensions/editor_tool_extensions.dart';
import 'package:boomspire/features/map_editor/presentation/map_editor_page.dart';
import 'package:boomspire/features/map_editor/presentation/state/map_editor_draft_state.dart';
import 'package:boomspire/features/map_editor/presentation/widgets/map_editor_canvas_painter.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => S.load(const Locale('en')));

  final canvasFinder = find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is MapEditorCanvasPainter,
  );

  MapEditorCanvasPainter painter(WidgetTester tester) =>
      tester.widget<CustomPaint>(canvasFinder).painter!
          as MapEditorCanvasPainter;

  Future<void> pumpEditor(WidgetTester tester) async {
    setupServiceLocator();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: MapEditorPage(
          initialDraft: MapDraft(id: 'g', name: 'Gestures'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pick(WidgetTester tester, EditorTool tool) async {
    await tester.tap(find.byTooltip(tool.label));
    await tester.pump();
  }

  /// Taps the canvas [dx]/[dy] (fractions of its size) from its top-left.
  Future<void> tapCanvas(WidgetTester tester, double dx, double dy) async {
    final rect = tester.getRect(canvasFinder);
    await tester.tapAt(
      Offset(rect.left + rect.width * dx, rect.top + rect.height * dy),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('tapping with the Home tool places a home, tapping it again '
      'removes it', (tester) async {
    await pumpEditor(tester);
    await pick(tester, EditorTool.homeSite);

    await tapCanvas(tester, 0.2, 0.5);
    expect(painter(tester).homeSites, hasLength(1));

    await tapCanvas(tester, 0.2, 0.5);
    expect(painter(tester).homeSites, isEmpty);
  });

  testWidgets('tower defense accepts one home and explains why a second is '
      'refused', (tester) async {
    await pumpEditor(tester);
    await pick(tester, EditorTool.homeSite);

    await tapCanvas(tester, 0.2, 0.5);
    await tapCanvas(tester, 0.8, 0.5);
    expect(painter(tester).homeSites, hasLength(1));
    expect(
      find.text(S.current.onlyHomeSitesSupportedEditorPage(1)),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4)); // let the toast leave
  });

  testWidgets('skirmish accepts two homes and refuses a third', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.text(S.current.skirmishOptionEditorPage));
    await tester.pump();
    await pick(tester, EditorTool.homeSite);

    await tapCanvas(tester, 0.15, 0.5);
    await tapCanvas(tester, 0.85, 0.5);
    await tapCanvas(tester, 0.5, 0.2);
    expect(painter(tester).homeSites, hasLength(2));
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('the Resource node tool places nodes by tap and the eraser '
      'removes them by tap', (tester) async {
    await pumpEditor(tester);
    await pick(tester, EditorTool.resourceNode);
    await tapCanvas(tester, 0.4, 0.4);
    await tapCanvas(tester, 0.6, 0.6);
    expect(painter(tester).resourceNodes, hasLength(2));

    await pick(tester, EditorTool.erase);
    await tapCanvas(tester, 0.4, 0.4);
    expect(painter(tester).resourceNodes, hasLength(1));
  });

  test(
    'a tap with a brush stamps one cell and with the eraser clears it',
    () async {
      final state = MapEditorDraftState(const MapDraft(id: 't', name: 'T'));
      addTearDown(state.dispose);
      await state.initialize();
      const size = Size(1280, 720);

      state.setTool(EditorTool.mountain);
      state.handleTap(const Offset(100, 100), size);
      expect(state.draft.value.paintedCells, hasLength(1));

      state.setTool(EditorTool.erase);
      state.handleTap(const Offset(100, 100), size);
      expect(state.draft.value.paintedCells, isEmpty);

      // A water tool needs a drag: a tap draws nothing.
      state.setTool(EditorTool.river);
      state.handleTap(const Offset(300, 300), size);
      expect(state.draft.value.waterPaths, isEmpty);
    },
  );

  test('the modes\' home limits are what the placement tools enforce', () {
    expect(GameMode.waveDefense.maxHomeSites, 1);
    expect(GameMode.skirmish.maxHomeSites, 2);
  });
}
