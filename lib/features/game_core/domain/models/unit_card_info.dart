import 'dart:math';

import '../../../../core/combat/mobile_unit_blueprint.dart';
import '../../../../core/combat/unit_domain.dart';

/// Read-only summary of a unit kind shown on its hover card in the build
/// menu: its name, what it can attack, and its power, health and speed.
class UnitCardInfo {
  final String name;

  /// The domains its weapon can hit - empty for an unarmed unit.
  final Set<UnitDomain> targets;

  /// Damage per second against a single target.
  final double power;

  final double health;
  final double speed;
  final double range;

  const UnitCardInfo({
    required this.name,
    required this.targets,
    required this.power,
    required this.health,
    required this.speed,
    required this.range,
  });

  factory UnitCardInfo.fromBlueprint(MobileUnitBlueprint blueprint) {
    final armed = blueprint.attackDamage > 0;
    return UnitCardInfo(
      name: blueprint.name,
      targets: armed ? blueprint.attackDomains : const {},
      power: armed
          ? blueprint.attackDamage / max(blueprint.attackInterval, 0.1)
          : 0,
      health: blueprint.maxHealth,
      speed: blueprint.speed,
      range: blueprint.attackRange,
    );
  }

  bool get isArmed => targets.isNotEmpty;
}
