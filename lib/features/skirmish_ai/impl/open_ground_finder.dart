import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/pathfinding/grid.dart';

/// Finds walkable ground near a world point.
class OpenGroundFinder {
  static const _maxSearchRadiusCells = 8;

  const OpenGroundFinder();

  /// The free cell centre closest to [point], or null if nothing within a
  /// few cells is free.
  Vector2? nearestOpen(Grid grid, Vector2 point) {
    final center = grid.worldToCell(point);
    for (var radius = 0; radius <= _maxSearchRadiusCells; radius++) {
      for (var dx = -radius; dx <= radius; dx++) {
        for (var dy = -radius; dy <= radius; dy++) {
          if (max(dx.abs(), dy.abs()) != radius) continue;
          final col = center.x + dx;
          final row = center.y + dy;
          if (grid.isBlocked(col, row)) continue;
          return grid.cellCenter(Point(col, row));
        }
      }
    }
    return null;
  }
}
