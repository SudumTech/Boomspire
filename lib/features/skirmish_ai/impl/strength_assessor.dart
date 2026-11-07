import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../domain/models/army_strength.dart';

/// Turns live units and towers into [ArmyStrength] numbers the AI can
/// compare - the only place that knows how a component's stats map to
/// "fighting power".
class StrengthAssessor {
  const StrengthAssessor();

  ArmyStrength ofUnit(MobileUnitComponent unit) =>
      _ofBlueprint(unit.blueprint, health: unit.health);

  /// A full-health unit of [blueprint] - used to rate units before they are
  /// built.
  ArmyStrength ofBlueprint(MobileUnitBlueprint blueprint) =>
      _ofBlueprint(blueprint, health: blueprint.maxHealth);

  ArmyStrength _ofBlueprint(
    MobileUnitBlueprint blueprint, {
    required double health,
  }) => ArmyStrength.single(
    health: health,
    dps: blueprint.attackDamage / max(blueprint.attackInterval, 0.1),
  );

  ArmyStrength ofUnits(Iterable<MobileUnitComponent> units) =>
      units.fold(ArmyStrength.zero, (sum, unit) => sum + ofUnit(unit));

  ArmyStrength ofTower(TowerComponent tower) {
    final blueprint = tower.blueprint;
    final salvoDamage = tower.effectiveDamage * blueprint.clipSize;
    return ArmyStrength.single(
      health: tower.hp,
      dps: salvoDamage / max(blueprint.fireRate, 0.1),
    );
  }

  /// Armed towers standing within [radius] of [center] - the static defense
  /// an army would have to push through to reach it.
  ArmyStrength ofTowersNear(
    Iterable<TowerComponent> towers,
    Vector2 center,
    double radius,
  ) => towers
      .where(
        (t) =>
            t.blueprint.damage > 0 && t.position.distanceTo(center) <= radius,
      )
      .fold(ArmyStrength.zero, (sum, tower) => sum + ofTower(tower));
}
