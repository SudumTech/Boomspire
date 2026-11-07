import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/pathfinding/grid.dart';

/// Chooses where around its base the AI places a new structure.
class BuildSiteFinder {
  static const _minRadiusCells = 2;
  static const _maxRadiusCells = 6;

  const BuildSiteFinder();

  /// Free cells within a few cells of [base], nearest to [preferred] first.
  /// Defensive structures prefer the side facing the enemy, economy
  /// buildings the safe side behind the base - the caller picks [preferred]
  /// accordingly.
  List<Point<int>> candidates(Grid grid, Vector2 base, Vector2 preferred) {
    final baseCell = grid.worldToCell(base);
    final cells = <Point<int>>[];
    for (var dx = -_maxRadiusCells; dx <= _maxRadiusCells; dx++) {
      for (var dy = -_maxRadiusCells; dy <= _maxRadiusCells; dy++) {
        if (max(dx.abs(), dy.abs()) < _minRadiusCells) continue;
        final col = baseCell.x + dx;
        final row = baseCell.y + dy;
        if (!grid.inBounds(col, row) || grid.isBlocked(col, row)) continue;
        cells.add(Point(col, row));
      }
    }
    double distanceToPreferred(Point<int> c) =>
        grid.cellCenter(c).distanceTo(preferred);
    cells.sort(
      (a, b) => distanceToPreferred(a).compareTo(distanceToPreferred(b)),
    );
    return cells;
  }

  /// A world point [distance] from [base] toward [toward] (or directly away
  /// from it when [distance] is negative).
  Vector2 pointToward(Vector2 base, Vector2 toward, double distance) {
    final direction = (toward - base);
    if (direction.length2 == 0) return base.clone();
    return base + direction.normalized() * distance;
  }
}
