import 'package:boomspire/features/game_core/domain/enums/game_mode.dart';
import 'package:boomspire/features/level_select/presentation/widgets/level_select_biome_thumb_painter.dart';
import 'package:boomspire/features/map_editor/domain/models/editor_point.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/presentation/widgets/map_draft_card_widget.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a saved map card shows a live terrain preview, name and '
      'delete', (tester) async {
    await S.load(const Locale('en'));
    var deleted = false;
    const draft = MapDraft(
      id: 'card',
      name: 'My Valley',
      mode: GameMode.skirmish,
      homeSites: [EditorPoint(x: 100, y: 300), EditorPoint(x: 1100, y: 300)],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 228,
            child: MapDraftCardWidget(
              draft: draft,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      ),
    );
    // Terrain generation runs off the UI thread; let it finish.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump();

    expect(find.text('My Valley'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is LevelSelectBiomeThumbPainter,
      ),
      findsOneWidget,
      reason: 'same terrain render as the built-in map cards',
    );
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted, isTrue);
  });
}
