import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/models/unit_type.dart';
import '../../towers/presentation/tower_component.dart';

/// Read-only questions the AI planners ask about the battlefield - shared
/// so build/production/upgrade planners all count things the same way.
class AiBaseQueries {
  /// Every tower type that shoots (as opposed to economy/production
  /// buildings).
  static const combatTowerTypes = [
    TowerType.machineGun,
    TowerType.rocket,
    TowerType.cannon,
    TowerType.antiAir,
    TowerType.laser,
    TowerType.rocketSilo,
    TowerType.artilleryBunker,
    TowerType.sam,
  ];

  /// Hostile units this close to the AI base count as an assault on it.
  static const threatRadius = 420.0;

  /// Most anti-air towers the AI ever wants (a cap, not a knowledge limit).
  static const maxAntiAirTowers = 4;

  final BoomspireGame _game;

  const AiBaseQueries(this._game);

  Iterable<TowerComponent> ownedStructures(Team team) =>
      _game.world.activeTowers.where((t) => t.owner.id == team.id);

  int ownedCountOf(Team team, UnitType type) =>
      ownedStructures(team).where((t) => t.blueprint.type == type).length;

  int ownedCombatTowerCount(Team team) =>
      ownedStructures(team)
          .where((t) => combatTowerTypes.contains(t.blueprint.type))
          .length;

  bool hasProduction(Team team) =>
      ownedCountOf(team, BuildingType.trainingCenter) > 0 ||
      ownedCountOf(team, BuildingType.warFactory) > 0;

  /// The cheapest unit [team] could ever produce - what it must keep in
  /// reserve so it never owns buildings it cannot afford to use.
  int cheapestUnitCost(Team team) => _game.unitRepository
      .kindsFor(team)
      .map((k) => _game.unitRepository.blueprintFor(team, k).cost)
      .reduce(min);

  List<MobileUnitComponent> threatsNear(Team team, Vector2 basePosition) =>
      _game.world
          .unitsHostileTo(team)
          .where((u) => u.position.distanceTo(basePosition) <= threatRadius)
          .toList();

  /// Air takes priority: ground-only towers cannot hit aircraft at all.
  UnitDomain counterDomainFor(Iterable<MobileUnitComponent> threats) =>
      threats.any((u) => u.blueprint.domain == UnitDomain.air)
      ? UnitDomain.air
      : UnitDomain.ground;

  /// Own armed towers that can shoot aircraft.
  int ownedAntiAirTowerCount(Team team) => ownedStructures(team)
      .where(
        (t) =>
            t.blueprint.damage > 0 &&
            t.blueprint.attackDomains.contains(UnitDomain.air),
      )
      .length;

  /// Own mobile units that can shoot aircraft (ground defenders and fighters
  /// alike).
  List<MobileUnitComponent> ownedAntiAirUnits(Team team) => _game
      .world
      .activeUnits
      .where(
        (u) =>
            !u.destroyed &&
            u.team.id == team.id &&
            u.blueprint.attackDamage > 0 &&
            u.blueprint.attackDomains.contains(UnitDomain.air),
      )
      .toList();

  /// Whether the opponent has built a Command Post - the building that
  /// unlocks aircraft - so an air force may be coming even if none has
  /// shown up yet.
  bool enemyCanBuildAircraft(Team team) => _game.world
      .towersHostileTo(team)
      .any((t) => t.blueprint.type == BuildingType.commandPost);

  /// How many anti-air defenders (towers + units) the AI wants given the
  /// air power it has seen: one per two enemy aircraft, and at least one as
  /// soon as the opponent is able to build aircraft at all.
  int desiredAntiAirTowers(Team team) {
    final aircraft = enemyComposition(team).air;
    final seen = (aircraft / 2).ceil();
    final potential = enemyCanBuildAircraft(team) ? 1 : 0;
    return (seen > potential ? seen : potential).clamp(0, maxAntiAirTowers);
  }

  /// How many hostile units of each broad class [team] currently faces.
  ({int air, int vehicle, int total}) enemyComposition(Team team) {
    var air = 0;
    var vehicle = 0;
    var total = 0;
    for (final unit in _game.world.unitsHostileTo(team)) {
      total++;
      if (unit.blueprint.domain == UnitDomain.air) air++;
      if (unit.blueprint.isVehicle) vehicle++;
    }
    return (air: air, vehicle: vehicle, total: total);
  }
}
