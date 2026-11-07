import 'dart:convert';

import '../../../core/combat/mobile_unit_repository_impl.dart';
import '../../../core/combat/team.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/impl/building_repository_impl.dart';
import '../../towers/impl/tower_repository_impl.dart';
import '../domain/models/default_build_requirements.dart';
import '../domain/models/game_object_definition.dart';
import 'game_object_definition_mapper.dart';

/// Builds the content manifest (every tower, building, and unit - friendly
/// `unit.buildable.*` and enemy `unit.invader.*` - with cost, damage, range,
/// fire rate, health, speed, weapons and the model asset for that side) from
/// the hardcoded blueprints. The single place both the regeneration step and
/// the "manifest is up to date" test read from.
String buildContentManifestJson() {
  final units = MobileUnitRepositoryImpl();
  final definitions = <GameObjectDefinition>[
    for (final blueprint in TowerRepositoryImpl().all)
      towerToDefinition(
        blueprint,
        requirements: defaultRequirementsForTower(blueprint.type as TowerType),
      ),
    for (final blueprint in BuildingRepositoryImpl().all)
      buildingToDefinition(
        blueprint,
        requirements: defaultRequirementsForBuilding(
          blueprint.type as BuildingType,
        ),
        producibleUnitIds: _producibleUnitIdsFor(
          blueprint.type as BuildingType,
        ),
      ),
    for (final team in [Team.invaders, Team.defaultPlayer])
      for (final kind in units.kindsFor(team))
        mobileUnitToDefinition(units.blueprintFor(team, kind), team.catalog),
  ];
  final json = const JsonEncoder.withIndent('  ')
      .convert(definitions.map((d) => d.toJson()).toList());
  return '$json\n';
}

List<String> _producibleUnitIdsFor(BuildingType type) => switch (type) {
  BuildingType.trainingCenter => const [
    'unit.buildable.soldier',
    'unit.buildable.antiTankSoldier',
    'unit.buildable.antiAirSoldier',
    'unit.buildable.heavySoldier',
  ],
  // War Factory: every buildable unit the Training Center doesn't cover.
  BuildingType.warFactory => const [
    'unit.buildable.tank',
    'unit.buildable.lightVehicle',
    'unit.buildable.aircraft',
    'unit.buildable.attackPlane',
    'unit.buildable.rocketBarrage',
    'unit.buildable.artilleryBarrage',
    'unit.buildable.antiAirVehicle',
    'unit.buildable.helicopter',
    'unit.buildable.drone',
    'unit.buildable.stealthBomber',
  ],
  _ => const [],
};
