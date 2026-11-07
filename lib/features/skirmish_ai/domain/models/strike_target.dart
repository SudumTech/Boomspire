import 'package:flame/components.dart';

import '../enums/strike_target_kind.dart';

/// Something the AI army can attack, with how worthwhile it is right now.
class StrikeTarget {
  final StrikeTargetKind kind;
  final Vector2 position;

  /// Short human-readable name, e.g. "Gold Mine" (shown in the AI intel).
  final String label;

  /// Static value of destroying it (income > production > defense).
  final double value;

  /// Enemy fighting power guarding it, relative to the army's power.
  /// Above 1 means the army would likely lose the fight there.
  final double defenseRatio;

  /// Whether destroying/holding it is still possible (false once the
  /// underlying structure is destroyed).
  final bool Function() isAlive;

  const StrikeTarget({
    required this.kind,
    required this.position,
    required this.label,
    required this.value,
    required this.defenseRatio,
    required this.isAlive,
  });

  bool get isWinnable => defenseRatio <= 1.0;
}
