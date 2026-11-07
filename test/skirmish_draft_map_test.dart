import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/map_editor/domain/models/editor_point.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/models/painted_cell.dart';
import 'package:boomspire/features/map_editor/impl/editor_terrain_generator.dart';
import 'package:boomspire/features/map_editor/impl/map_draft_terrain_repository.dart';
import 'package:boomspire/features/game_core/domain/enums/game_mode.dart';
import 'package:boomspire/features/terrain/domain/models/obstacle_kind.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a skirmish map made in the editor plays: two bases, nodes on open '
      'ground', () async {
    const human = EditorPoint(x: 120, y: 360);
    const ai = EditorPoint(x: 1160, y: 360);
    final draft = MapDraft(
      id: 's',
      name: 'Skirmish',
      mode: GameMode.skirmish,
      homeSites: const [human, ai],
      resourceNodes: const [
        EditorPoint(x: 640, y: 200),
        EditorPoint(x: 640, y: 520),
        // Painted over with a mountain below: must still come out open.
        EditorPoint(x: 400, y: 360),
      ],
      paintedCells: const [
        PaintedCell(col: 10, row: 9, kind: ObstacleKind.mountain),
      ],
    );
    final preview = await EditorTerrainGenerator().generate(draft);

    final map = MapDraftTerrainRepository(
      draft: draft,
      preview: preview,
      humanBaseSite: human,
      aiBaseSite: ai,
    ).loadTerrain(scene: GameScenes.skirmishes.first);

    expect(map.secondaryBasePoint, isNotNull, reason: 'the AI gets a base');
    expect(map.resourceNodePoints, hasLength(3));
    for (final node in map.resourceNodePoints) {
      final cell = map.grid.worldToCell(Vector2(node.x, node.y));
      expect(map.grid.isBlocked(cell.x, cell.y), isFalse);
    }
  });
}
