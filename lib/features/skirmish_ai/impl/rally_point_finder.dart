import 'package:flame/components.dart';

import '../../../core/pathfinding/grid.dart';
import 'open_ground_finder.dart';

/// Picks the open ground where the AI gathers its army before an attack.
class RallyPointFinder {
  /// How far from the AI base toward the enemy base the rally sits (0..1).
  static const _fractionTowardEnemy = 0.28;

  final OpenGroundFinder _ground;

  const RallyPointFinder([this._ground = const OpenGroundFinder()]);

  /// A free, walkable point between [ownBase] and [enemyBase], or [ownBase]
  /// itself if the ground around the ideal spot is entirely blocked.
  Vector2 find(Grid grid, Vector2 ownBase, Vector2 enemyBase) {
    final ideal = ownBase + (enemyBase - ownBase) * _fractionTowardEnemy;
    return _ground.nearestOpen(grid, ideal) ?? ownBase.clone();
  }
}
