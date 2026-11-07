import 'dart:math';
import 'dart:ui' as ui;

/// Fills a connected blob of cells as one smooth, organic shape (an area
/// feature, unlike the linear river/valley ribbons): the cells are unioned
/// as slightly overlapping squares (so no gaps open up at cell corners), then
/// the outline is rounded off so a lake reads as a natural pond instead of a
/// stack of square tiles. Shared by `TerrainPainter._paintLake`/
/// `_paintVolcanicLake` (baked once) and `TerrainPainter.lakeShape` (the
/// combined shape passed to the live `paintLakeFlow`/
/// `paintVolcanicLakeFlow` overlays).
ui.Path unionCellsShape(List<Point<int>> cells, double cellSize) {
  var shape = ui.Path();
  for (final cell in cells) {
    shape = ui.Path.combine(
      ui.PathOperation.union,
      shape,
      ui.Path()..addRect(
        ui.Rect.fromLTWH(
          cell.x * cellSize - 1.5,
          cell.y * cellSize - 1.5,
          cellSize + 3,
          cellSize + 3,
        ),
      ),
    );
  }
  return _roundedOutline(shape, cellSize);
}

/// Samples every contour of [shape] (outer edges and holes) and rounds its
/// corners with a few passes of corner-cutting.
ui.Path _roundedOutline(ui.Path shape, double cellSize) {
  const smoothingPasses = 4;
  final spacing = cellSize * 0.7;
  final result = ui.Path();
  for (final metric in shape.computeMetrics()) {
    if (metric.length < spacing * 3) continue;
    var points = <ui.Offset>[
      for (var d = 0.0; d < metric.length; d += spacing)
        metric.getTangentForOffset(d)!.position,
    ];
    for (var pass = 0; pass < smoothingPasses; pass++) {
      points = _cutCorners(points);
    }
    result.addPolygon(points, true);
  }
  return result;
}

/// One Chaikin corner-cutting pass over a closed polyline.
List<ui.Offset> _cutCorners(List<ui.Offset> points) {
  final out = <ui.Offset>[];
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    out
      ..add(ui.Offset.lerp(a, b, 0.25)!)
      ..add(ui.Offset.lerp(a, b, 0.75)!);
  }
  return out;
}
