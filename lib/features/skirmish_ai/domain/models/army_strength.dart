import 'dart:math';

/// A force's fighting power - total hit points paired with total damage per
/// second. Power is `sqrt(health * dps)`, so doubling an army's headcount
/// roughly doubles its power while stacking more of one stat alone never
/// helps much (a Lanchester-style estimate, good enough to decide "can we
/// win this fight").
class ArmyStrength {
  static const ArmyStrength zero = ArmyStrength(health: 0, dps: 0);

  final double health;
  final double dps;

  const ArmyStrength({required this.health, required this.dps});

  double get power => sqrt(health * dps);

  ArmyStrength operator +(ArmyStrength other) =>
      ArmyStrength(health: health + other.health, dps: dps + other.dps);

  /// A single unit/tower's strength from its current [health] and the
  /// damage it deals per second.
  factory ArmyStrength.single({required double health, required double dps}) =>
      ArmyStrength(health: max(0, health), dps: max(0, dps));
}
