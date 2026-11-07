import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/presentation/tower_component.dart';
import '../domain/enums/strike_target_kind.dart';
import '../domain/models/strike_plan.dart';
import '../domain/models/strike_target.dart';
import 'strength_assessor.dart';

/// Works out *where* the army should hit, the way a C&C commander scouts
/// for the soft spot instead of marching into the strongest defense:
/// income and production buildings are worth the most, a lightly guarded
/// one beats a fortified one, and a target the army cannot beat is skipped.
/// A finished target is replaced next round; a still-good one is kept so the
/// army does not dither between two similar choices.
class StrikePlanner {
  static const _economyValue = 90.0;
  static const _productionValue = 80.0;
  static const _nodeValue = 70.0;
  static const _techValue = 50.0;
  static const _defenseValue = 25.0;
  static const _baseValue = 60.0;

  /// Extra base value as the opponent's base health drops: going for the
  /// kill when they are nearly dead.
  static const _baseFinishBonus = 240.0;

  /// Enemy strength within this distance of a target counts as guarding it.
  static const _guardRadius = 260.0;

  static const _defensePenalty = 120.0;
  static const _distancePenaltyPerPixel = 0.02;

  /// A kept target is replaced only when the best alternative scores this
  /// much better.
  static const _stickiness = 1.3;

  /// A raid only goes after targets guarded by at most this share of the
  /// raiding squad's strength.
  static const _raidMaxDefenseRatio = 0.6;

  final BoomspireGame _game;
  final StrengthAssessor _assessor;

  final _Choice _mainChoice = _Choice();
  final _Choice _airChoice = _Choice();

  StrikePlanner(this._game, [this._assessor = const StrengthAssessor()]);

  /// The target the main force should be hitting, plus (when
  /// [allowRaid]) a weak economic target for a fast squad whose strength is
  /// [raidPower].
  StrikePlan plan({
    required Team aiTeam,
    required Vector2 armyCenter,
    required double armyPower,
    required bool allowRaid,
    required double raidPower,
  }) {
    final candidates = _candidates(aiTeam, armyCenter, armyPower);
    final main = _chooseMain(candidates, armyCenter);
    final raid = allowRaid
        ? _chooseRaid(aiTeam, armyCenter, raidPower, main)
        : null;
    return StrikePlan(main: main, raid: raid);
  }

  /// Where an air wing should strike: the best target guarded only by
  /// whatever can shoot aircraft (ground defenses cannot touch them). Null if
  /// nothing is worth, or safe enough, to hit.
  StrikeTarget? planAirStrike({
    required Team aiTeam,
    required Vector2 from,
    required double airPower,
  }) {
    final viable = _candidates(
      aiTeam,
      from,
      airPower,
      airGuardsOnly: true,
    ).where((t) => t.isWinnable).toList();
    if (viable.isEmpty) return null;
    return _select(viable, from, _airChoice);
  }

  StrikeTarget _chooseMain(List<StrikeTarget> candidates, Vector2 from) {
    final viable = candidates.where((t) => t.isWinnable).toList();
    if (viable.isEmpty) {
      return candidates.firstWhere((t) => t.kind == StrikeTargetKind.base);
    }
    return _select(viable, from, _mainChoice);
  }

  /// The highest-scoring of [viable], keeping [choice]'s previous target
  /// unless something clearly better ([_stickiness]) showed up.
  StrikeTarget _select(
    List<StrikeTarget> viable,
    Vector2 from,
    _Choice choice,
  ) {
    viable.sort((a, b) => _score(b, from).compareTo(_score(a, from)));
    final best = viable.first;
    final bestScore = _score(best, from);
    final kept = choice.target;
    if (kept != null &&
        kept.isAlive() &&
        bestScore < choice.score * _stickiness) {
      return kept;
    }
    choice.target = best;
    choice.score = bestScore;
    return best;
  }

  StrikeTarget? _chooseRaid(
    Team aiTeam,
    Vector2 from,
    double raidPower,
    StrikeTarget main,
  ) {
    final soft = _candidates(aiTeam, from, raidPower)
        .where(
          (t) =>
              t.kind != StrikeTargetKind.base &&
              t.kind != StrikeTargetKind.defense &&
              t.defenseRatio <= _raidMaxDefenseRatio &&
              (t.position - main.position).length > _guardRadius,
        )
        .toList();
    if (soft.isEmpty) return null;
    soft.sort((a, b) => _score(b, from).compareTo(_score(a, from)));
    return soft.first;
  }

  double _score(StrikeTarget target, Vector2 from) =>
      target.value -
      _defensePenalty * min(target.defenseRatio, 3) -
      target.position.distanceTo(from) * _distancePenaltyPerPixel;

  List<StrikeTarget> _candidates(
    Team aiTeam,
    Vector2 armyCenter,
    double armyPower, {
    bool airGuardsOnly = false,
  }) {
    final hostileTowers = _game.world.towersHostileTo(aiTeam).toList();
    final hostileUnits = _game.world.unitsHostileTo(aiTeam).toList();
    // Aircraft only fear what can shoot them.
    final guardTowers = airGuardsOnly
        ? hostileTowers.where(_canShootAir).toList()
        : hostileTowers;
    final guardUnits = airGuardsOnly
        ? hostileUnits
              .where((u) => u.blueprint.attackDomains.contains(UnitDomain.air))
              .toList()
        : hostileUnits;
    double guardRatio(Vector2 at) {
      final guards =
          _assessor.ofTowersNear(guardTowers, at, _guardRadius) +
          _assessor.ofUnits(_unitsNear(guardUnits, at));
      return guards.power / max(armyPower, 1);
    }

    return [
      for (final tower in hostileTowers)
        StrikeTarget(
          kind: _kindOfStructure(tower),
          position: tower.position.clone(),
          label: tower.blueprint.name,
          value: _valueOfStructure(tower),
          defenseRatio: guardRatio(tower.position),
          isAlive: () => !tower.destroyed && tower.isMounted,
        ),
      for (final node in _game.world.activeResourceNodes.where(
        (n) => n.owner != null && n.owner!.id != aiTeam.id,
      ))
        StrikeTarget(
          kind: StrikeTargetKind.resourceNode,
          position: node.position.clone(),
          label: 'Resource node',
          value: _nodeValue,
          defenseRatio: guardRatio(node.position),
          isAlive: () => node.owner != null && node.owner!.id != aiTeam.id,
        ),
      _baseTarget(aiTeam, guardRatio),
    ];
  }

  StrikeTarget _baseTarget(Team aiTeam, double Function(Vector2) guardRatio) {
    final position =
        _game.baseTargetFor(aiTeam) ??
        Vector2(_game.terrainMap.basePoint.x, _game.terrainMap.basePoint.y);
    final health = _game.gameState.health / GameConfig.startingHealth;
    return StrikeTarget(
      kind: StrikeTargetKind.base,
      position: position,
      label: 'Home base',
      value: _baseValue + (1 - health.clamp(0.0, 1.0)) * _baseFinishBonus,
      defenseRatio: guardRatio(position),
      isAlive: () => _game.gameState.health > 0,
    );
  }

  bool _canShootAir(TowerComponent tower) =>
      tower.blueprint.attackDomains.contains(UnitDomain.air);

  Iterable<MobileUnitComponent> _unitsNear(
    List<MobileUnitComponent> units,
    Vector2 at,
  ) => units.where((u) => u.position.distanceTo(at) <= _guardRadius);

  StrikeTargetKind _kindOfStructure(TowerComponent tower) =>
      switch (tower.blueprint.type) {
        BuildingType.goldMine => StrikeTargetKind.economy,
        BuildingType.trainingCenter ||
        BuildingType.warFactory => StrikeTargetKind.production,
        _ => StrikeTargetKind.defense,
      };

  double _valueOfStructure(TowerComponent tower) =>
      switch (tower.blueprint.type) {
        BuildingType.goldMine => _economyValue,
        BuildingType.trainingCenter ||
        BuildingType.warFactory => _productionValue,
        BuildingType.techLab || BuildingType.commandPost => _techValue,
        _ => _defenseValue,
      };
}

/// A remembered target and its score, so a good choice is kept between
/// rounds instead of flipping between two similar ones.
class _Choice {
  StrikeTarget? target;
  double score = 0;
}
