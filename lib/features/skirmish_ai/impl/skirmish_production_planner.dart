import 'dart:math';

import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit_kind.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/presentation/training_center_component.dart';
import '../../towers/presentation/war_factory_component.dart';
import 'ai_base_queries.dart';
import 'player_weakness_analyzer.dart';
import 'strength_assessor.dart';

/// Mans the AI's Training Centers and War Factories every round it can
/// afford to, choosing *what* to build by scoring each producible kind on
/// cost-efficiency, how well it counters the player's current army, and
/// variety within the AI's own army.
class SkirmishProductionPlanner {
  static const _counterBonus = 2.5;
  static const _varietyPenalty = 0.4;

  /// Score bonus for armed aircraft while the opponent cannot shoot them.
  static const _airWeaknessBonus = 3.0;

  /// Score bonus for units that can shoot aircraft while the AI fields fewer
  /// of them than the air power it has seen calls for.
  static const _antiAirNeedBonus = 3.0;

  /// Below this many own combat units the AI never saves gold for
  /// buildings - a minimum defense comes first.
  static const _minArmyBeforeSaving = 3;

  /// Most anti-air units the AI ever wants at once.
  static const _maxAntiAirUnits = 8;

  final BoomspireGame _game;
  final AiBaseQueries _queries;
  final StrengthAssessor _assessor;
  final PlayerWeaknessAnalyzer _weakness;

  SkirmishProductionPlanner(
    this._game, {
    this._assessor = const StrengthAssessor(),
  }) : _queries = AiBaseQueries(_game),
       _weakness = PlayerWeaknessAnalyzer(_game);

  /// Mans every idle production building. [savingsTarget] gold is held back
  /// for the AI's next building, once it fields a minimal army.
  void produce(Team aiTeam, {int savingsTarget = 0}) {
    final enemy = _queries.enemyComposition(aiTeam);
    final exploitAir = _weakness.analyze(aiTeam).lacksAntiAir;
    final keepGold = _ownUnitCount(aiTeam) >= _minArmyBeforeSaving
        ? savingsTarget
        : 0;
    final context = (
      enemy: enemy,
      exploitAir: exploitAir,
      keepGold: keepGold,
      antiAirDeficit: _antiAirUnitDeficit(aiTeam),
    );
    for (final tower in _queries.ownedStructures(aiTeam)) {
      if (tower is TrainingCenterComponent && tower.canProduce) {
        _produceFrom(
          aiTeam,
          context,
          TrainingCenterComponent.producibleKinds,
          tower.costFor,
          tower.produceUnit,
        );
      } else if (tower is WarFactoryComponent && tower.canProduce) {
        final kinds = _game.unitRepository
            .kindsFor(aiTeam)
            .where((k) => !TrainingCenterComponent.producibleKinds.contains(k))
            .toList();
        _produceFrom(
          aiTeam,
          context,
          kinds,
          tower.costFor,
          (kind) => tower.produceUnit(kind),
        );
      }
    }
  }

  void _produceFrom(
    Team aiTeam,
    _Context context,
    List<UnitKind> kinds,
    int Function(UnitKind) costOf,
    bool Function(UnitKind) produce,
  ) {
    final spendable = _game.goldFor(aiTeam) - context.keepGold;
    final affordable = kinds.where((k) => costOf(k) <= spendable).toList();
    if (affordable.isEmpty) return;
    produce(_pickKind(aiTeam, affordable, context));
  }

  int _ownUnitCount(Team aiTeam) => _game.world.activeUnits
      .where((u) => !u.destroyed && u.team.id == aiTeam.id)
      .length;

  UnitKind _pickKind(Team aiTeam, List<UnitKind> kinds, _Context context) {
    final blueprints = {
      for (final kind in kinds)
        kind: _game.unitRepository.blueprintFor(aiTeam, kind),
    };
    final bestValue = blueprints.values.map(_valueForCost).reduce(max);
    final ownCounts = _ownKindCounts(aiTeam);
    final ownTotal = max(1, ownCounts.values.fold(0, (a, b) => a + b));

    UnitKind best = kinds.first;
    var bestScore = double.negativeInfinity;
    for (final kind in kinds) {
      final blueprint = blueprints[kind]!;
      final score =
          _valueForCost(blueprint) / bestValue +
          _counterScore(blueprint, context.enemy) +
          _weaknessScore(blueprint, context) +
          _antiAirNeedScore(blueprint, context) -
          _varietyPenalty * (ownCounts[kind] ?? 0) / ownTotal;
      if (score > bestScore) {
        bestScore = score;
        best = kind;
      }
    }
    return best;
  }

  /// Fighting power per gold spent.
  double _valueForCost(MobileUnitBlueprint blueprint) =>
      _assessor.ofBlueprint(blueprint).power / max(1, blueprint.cost);

  double _counterScore(
    MobileUnitBlueprint blueprint,
    ({int air, int vehicle, int total}) enemy,
  ) {
    if (enemy.total == 0) return 0;
    var score = 0.0;
    if (blueprint.attackDomains.contains(UnitDomain.air)) {
      score += _counterBonus * enemy.air / enemy.total;
    }
    if (blueprint.kind == UnitKind.antiTankSoldier) {
      score += _counterBonus * enemy.vehicle / enemy.total;
    }
    return score;
  }

  /// Armed aircraft are strongly preferred while the opponent has nothing
  /// that can shoot them down.
  double _weaknessScore(MobileUnitBlueprint blueprint, _Context context) {
    final armedAircraft =
        blueprint.domain == UnitDomain.air && blueprint.attackDamage > 0;
    return context.exploitAir && armedAircraft ? _airWeaknessBonus : 0;
  }

  /// How many more units that can shoot aircraft the AI wants right now:
  /// one per enemy aircraft seen (more once the opponent can build planes at
  /// all), minus the ones it already has.
  int _antiAirUnitDeficit(Team aiTeam) {
    final enemy = _queries.enemyComposition(aiTeam);
    final potential = _queries.enemyCanBuildAircraft(aiTeam) ? 2 : 0;
    final wanted = (enemy.air > potential ? enemy.air : potential).clamp(
      0,
      _maxAntiAirUnits,
    );
    final owned = _queries.ownedAntiAirUnits(aiTeam).length;
    return wanted > owned ? wanted - owned : 0;
  }

  double _antiAirNeedScore(MobileUnitBlueprint blueprint, _Context context) {
    final shootsAir =
        blueprint.attackDamage > 0 &&
        blueprint.attackDomains.contains(UnitDomain.air);
    return context.antiAirDeficit > 0 && shootsAir ? _antiAirNeedBonus : 0;
  }

  Map<UnitKind, int> _ownKindCounts(Team aiTeam) {
    final counts = <UnitKind, int>{};
    for (final unit in _game.world.activeUnits) {
      if (unit.destroyed || unit.team.id != aiTeam.id) continue;
      counts.update(unit.blueprint.kind, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts;
  }
}

typedef _Enemy = ({int air, int vehicle, int total});

/// What one production round knows: the opponent's army makeup, whether to
/// exploit missing anti-air, and how much gold to hold back.
typedef _Context = ({
  _Enemy enemy,
  bool exploitAir,
  int keepGold,
  int antiAirDeficit,
});
