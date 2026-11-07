import 'package:flutter/material.dart';

import '../../../level_select/presentation/widgets/level_select_biome_thumb_painter.dart';
import '../../../terrain/domain/models/terrain_map.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../../domain/models/map_draft.dart';
import '../../impl/editor_terrain_generator.dart';
import '../../impl/map_draft_scene_factory.dart';
import '../../impl/map_draft_terrain_repository.dart';

/// Live terrain preview of a hand-made [MapDraft] - the same render the
/// built-in map cards show (`BiomePreview`), plus a marker for every home
/// site and resource node so a skirmish map's layout reads at a glance.
class MapDraftPreviewWidget extends StatefulWidget {
  final MapDraft draft;

  const MapDraftPreviewWidget({super.key, required this.draft});

  @override
  State<MapDraftPreviewWidget> createState() => _MapDraftPreviewWidgetState();
}

class _MapDraftPreviewWidgetState extends State<MapDraftPreviewWidget> {
  // Generating terrain is not free, so each distinct draft is rendered once
  // per run and reused whenever its card scrolls back into view.
  static final Map<int, Future<TerrainMap>> _cache = {};

  late Future<TerrainMap> _terrain = _load(widget.draft);

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return FutureBuilder<TerrainMap>(
      future: _terrain,
      builder: (context, snapshot) {
        final terrain = snapshot.data;
        if (terrain == null) {
          final palette = draft.biome.palette;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [palette.groundTop, palette.groundBottom],
              ),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: LevelSelectBiomeThumbPainter(terrain)),
            CustomPaint(painter: _MarkersPainter(draft)),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant MapDraftPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) _terrain = _load(widget.draft);
  }

  static Future<TerrainMap> _load(MapDraft draft) =>
      _cache.putIfAbsent(Object.hash(draft.id, draft), () async {
        final preview = await EditorTerrainGenerator().generate(draft);
        final scene = const MapDraftSceneFactory().sceneFor(
          draft,
          mode: draft.mode,
          briefing: '',
        );
        return MapDraftTerrainRepository(
          draft: draft,
          preview: preview,
        ).loadTerrain(scene: scene);
      });
}

class _MarkersPainter extends CustomPainter {
  final MapDraft draft;

  const _MarkersPainter(this.draft);

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(double x, double y) => Offset(
      x / draft.arenaWidth * size.width,
      y / draft.arenaHeight * size.height,
    );

    for (final node in draft.resourceNodes) {
      final p = at(node.x, node.y);
      canvas.drawCircle(p, 4, Paint()..color = const Color(0xFFFFD54F));
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF3E2F00),
      );
    }
    for (final home in draft.homeSites) {
      final p = at(home.x, home.y);
      canvas.drawCircle(p, 7, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(p, 4.5, Paint()..color = const Color(0xFF263238));
    }
  }

  @override
  bool shouldRepaint(covariant _MarkersPainter oldDelegate) =>
      oldDelegate.draft != draft;
}
