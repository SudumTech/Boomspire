import 'dart:math';

import '../domain/models/editor_point.dart';
import '../domain/models/water_path.dart';

/// Answers "is this point on that river/lake/lava stroke?" so the eraser can
/// remove a hand-drawn water feature by touching any part of it.
class WaterPathHitTester {
  const WaterPathHitTester();

  /// Whether [point] touches [path]. Channels ([WaterFeatureKind.river],
  /// [WaterFeatureKind.lava]) are hit within half their width of the
  /// stroke; closed bodies ([WaterFeatureKind.lake],
  /// [WaterFeatureKind.volcanicLake]) when [point] is inside the outline or
  /// close to its edge. [reach] widens every hit zone slightly so a brush
  /// the size of one terrain cell never needs pixel precision.
  bool hits(WaterPath path, EditorPoint point, {required double reach}) {
    if (path.points.isEmpty) return false;
    return switch (path.kind) {
      WaterFeatureKind.river || WaterFeatureKind.lava =>
        _distanceToStroke(path.points, point) <= path.width / 2 + reach,
      WaterFeatureKind.lake || WaterFeatureKind.volcanicLake =>
        _inside(path.points, point) ||
            _distanceToStroke([...path.points, path.points.first], point) <=
                reach,
    };
  }

  double _distanceToStroke(List<EditorPoint> points, EditorPoint p) {
    if (points.length == 1) return _distance(points.first, p);
    var best = double.infinity;
    for (var i = 0; i < points.length - 1; i++) {
      best = min(best, _distanceToSegment(p, points[i], points[i + 1]));
    }
    return best;
  }

  double _distanceToSegment(EditorPoint p, EditorPoint a, EditorPoint b) {
    final abx = b.x - a.x;
    final aby = b.y - a.y;
    final lengthSquared = abx * abx + aby * aby;
    final t = lengthSquared == 0
        ? 0.0
        : (((p.x - a.x) * abx + (p.y - a.y) * aby) / lengthSquared).clamp(
            0.0,
            1.0,
          );
    return _distance(p, EditorPoint(x: a.x + abx * t, y: a.y + aby * t));
  }

  double _distance(EditorPoint a, EditorPoint b) =>
      sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

  /// Even-odd ray-casting point-in-polygon test.
  bool _inside(List<EditorPoint> polygon, EditorPoint p) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final a = polygon[i];
      final b = polygon[j];
      final crosses =
          (a.y > p.y) != (b.y > p.y) &&
          p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x;
      if (crosses) inside = !inside;
    }
    return inside;
  }
}
