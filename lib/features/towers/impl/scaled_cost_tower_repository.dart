import '../../game_content/domain/models/build_requirement.dart';
import '../domain/models/tower_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/repos/tower_repository.dart';

/// Wraps a [TowerRepository] so every combat tower costs [multiplier] times
/// its listed price - how a mode with a bigger economy (skirmish) keeps
/// defenses from being spammed, without touching the base prices that
/// tower defense is balanced around. Only the price changes; stats, upgrade
/// costs (derived from the price) and requirements follow the inner repo.
class ScaledCostTowerRepository implements TowerRepository {
  final TowerRepository _inner;
  final double multiplier;

  const ScaledCostTowerRepository(this._inner, this.multiplier);

  @override
  List<UnitBlueprint> get all =>
      _inner.all.map(_scaled).toList(growable: false);

  @override
  UnitBlueprint blueprintFor(TowerType type) =>
      _scaled(_inner.blueprintFor(type));

  @override
  List<BuildRequirement> requirementsFor(TowerType type) =>
      _inner.requirementsFor(type);

  UnitBlueprint _scaled(UnitBlueprint b) => UnitBlueprint(
    type: b.type,
    name: b.name,
    cost: (b.cost * multiplier).round(),
    range: b.range,
    damage: b.damage,
    fireRate: b.fireRate,
    maxHp: b.maxHp,
    clipSize: b.clipSize,
    clipShotInterval: b.clipShotInterval,
    splashRadius: b.splashRadius,
    minRange: b.minRange,
    domain: b.domain,
    attackDomains: b.attackDomains,
  );
}
