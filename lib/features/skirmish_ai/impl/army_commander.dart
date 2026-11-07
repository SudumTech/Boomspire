import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit_objective.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../domain/enums/army_stance.dart';
import '../domain/enums/strike_target_kind.dart';
import '../domain/models/army_strength.dart';
import '../domain/models/skirmish_ai_profile.dart';
import '../domain/models/strike_plan.dart';
import '../domain/models/strike_target.dart';
import 'open_ground_finder.dart';
import 'player_weakness_analyzer.dart';
import 'rally_point_finder.dart';
import 'strength_assessor.dart';
import 'strike_planner.dart';

/// Directs the AI's whole field army as one force instead of letting every
/// freshly-built unit trickle across the map alone and die:
///
/// - **muster**: new units gather at a rally point near the AI base.
/// - **attack**: once the army out-powers everything it would face (enemy
///   units plus the defense towers around their base), it is released to
///   march on the enemy base together.
/// - **defend**: units attacking the AI's own base pull the army back to
///   intercept them (a trivial raid does not interrupt an attack).
///
/// An attack that turns into a losing fight falls back to the rally point
/// and re-musters instead of feeding the enemy kills.
class ArmyCommander {
  /// Hostile units this close to the AI base count as an assault on it.
  static const _threatRadius = 420.0;

  /// Enemy towers this close to the enemy base defend it in an assault.
  static const _defenseRadius = 380.0;

  /// A defending unit is re-pointed once the threat moved this far.
  static const _defenseRetargetDistance = 90.0;

  /// A threat weaker than this share of the army's power is ignored while
  /// the army is busy attacking.
  static const _significantThreatShare = 0.3;

  /// A unit this close to its destination counts as having arrived.
  static const _arrivedRadius = 70.0;

  /// Fewest armed aircraft that count as an air wing worth sending alone.
  static const _minAirWing = 2;

  /// Re-point a striking group only when its target moved this far.
  static const _approachTolerance = 60.0;

  /// Upper bound on how far short of a target the army stops.
  static const _defaultApproachDistance = 140.0;

  final BoomspireGame _game;
  final SkirmishAiProfile _profile;
  final StrengthAssessor _assessor;
  final RallyPointFinder _rallyFinder;
  final OpenGroundFinder _groundFinder;
  final StrikePlanner _strikePlanner;
  final PlayerWeaknessAnalyzer _weakness;

  ArmyStance _stance = ArmyStance.muster;
  StrikePlan? _plan;
  StrikeTarget? _airTarget;
  double _lastArmyPower = 0;
  double _lastEnemyPower = 0;

  ArmyCommander(
    this._game,
    this._profile, {
    this._assessor = const StrengthAssessor(),
    this._rallyFinder = const RallyPointFinder(),
    this._groundFinder = const OpenGroundFinder(),
  }) : _strikePlanner = StrikePlanner(_game),
       _weakness = PlayerWeaknessAnalyzer(_game);

  ArmyStance get stance => _stance;

  /// What the main force is currently hitting, or null when not attacking.
  StrikeTarget? get mainTarget =>
      _stance == ArmyStance.attack ? _plan?.main : null;

  /// The raiding squad's target, if one is out.
  StrikeTarget? get raidTarget =>
      _stance == ArmyStance.attack ? _plan?.raid : null;

  /// What the air wing is bombing, or null when there is no air strike.
  StrikeTarget? get airTarget => _airTarget;

  double get armyPower => _lastArmyPower;
  double get enemyPower => _lastEnemyPower;

  /// One command round. [aggression] (0..1, from the AI director) lowers the
  /// power edge required before attacking when high.
  void command(Team aiTeam, double aggression) {
    final ownBase = _game.world.aiHomeBase;
    final enemyBase = _game.baseTargetFor(aiTeam);
    if (ownBase == null || !ownBase.isMounted || enemyBase == null) return;

    final everyone = _combatArmy(aiTeam);
    final airWing = _airWing(aiTeam, everyone);
    final army = airWing.isEmpty
        ? everyone
        : everyone.where((u) => !airWing.contains(u)).toList();
    final threats = _threatsNear(aiTeam, ownBase.position);
    final armyPower = _assessor.ofUnits(everyone).power;
    final threatPower = _assessor.ofUnits(threats).power;
    final enemyPower = _enemyPower(aiTeam, enemyBase).power;
    _lastArmyPower = armyPower;
    _lastEnemyPower = enemyPower;

    _stance = _nextStance(
      armySize: everyone.length,
      armyPower: armyPower,
      threatPower: threatPower,
      enemyPower: enemyPower,
      aggression: aggression,
    );
    final rally = _rallyFinder.find(
      _game.terrainMap.grid,
      ownBase.position,
      enemyBase,
    );
    // The air wing only strikes on its own when the base is safe; under
    // attack it rejoins the army to help defend.
    final defending = _stance == ArmyStance.defend;
    _issueOrders(
      aiTeam: aiTeam,
      army: defending ? everyone : army,
      threats: threats,
      armyPower: armyPower,
      rally: rally,
    );
    _airTarget = null;
    if (!defending && airWing.isNotEmpty) {
      _airTarget = _strikeFromAir(aiTeam, airWing, rally);
    }
  }

  /// The armed aircraft to send out on their own because the opponent has
  /// nothing that can shoot them down; empty when that is not the case.
  List<MobileUnitComponent> _airWing(
    Team aiTeam,
    List<MobileUnitComponent> everyone,
  ) {
    if (!_profile.exploitsWeaknesses) return const [];
    if (!_weakness.analyze(aiTeam).lacksAntiAir) return const [];
    final aircraft = everyone
        .where(
          (u) =>
              u.blueprint.domain == UnitDomain.air &&
              u.blueprint.attackDamage > 0,
        )
        .toList();
    return aircraft.length >= _minAirWing ? aircraft : const [];
  }

  /// Sends the air wing at the best target only aircraft-capable defenses
  /// could stop; holds it at the rally point when nothing is worth hitting.
  StrikeTarget? _strikeFromAir(
    Team aiTeam,
    List<MobileUnitComponent> wing,
    Vector2 rally,
  ) {
    final target = _strikePlanner.planAirStrike(
      aiTeam: aiTeam,
      from: _centroidOf(wing),
      airPower: _assessor.ofUnits(wing).power,
    );
    if (target == null) {
      _sendAllTo(wing, rally, tolerance: 1);
      return null;
    }
    _sendGroupAt(wing, target);
    return target;
  }

  /// The units this commander controls: the AI's mobile assault units.
  /// Resource-node capturers keep their own errand.
  List<MobileUnitComponent> _combatArmy(Team aiTeam) => _game.world.activeUnits
      .where(
        (u) =>
            !u.destroyed &&
            u.team.id == aiTeam.id &&
            u.objective == UnitObjective.assaultBase,
      )
      .toList();

  List<MobileUnitComponent> _threatsNear(Team aiTeam, Vector2 ownBase) => _game
      .world
      .unitsHostileTo(aiTeam)
      .where((u) => u.position.distanceTo(ownBase) <= _threatRadius)
      .toList();

  /// Everything an assault on the enemy base would have to beat: their
  /// whole mobile army plus the armed towers around the base.
  ArmyStrength _enemyPower(Team aiTeam, Vector2 enemyBase) =>
      _assessor.ofUnits(_game.world.unitsHostileTo(aiTeam)) +
      _assessor.ofTowersNear(
        _game.world.towersHostileTo(aiTeam),
        enemyBase,
        _defenseRadius,
      );

  ArmyStance _nextStance({
    required int armySize,
    required double armyPower,
    required double threatPower,
    required double enemyPower,
    required double aggression,
  }) {
    // An army out on the attack only turns back for a serious threat; one
    // that is still at home reacts to any raider.
    final seriousEnough =
        _stance != ArmyStance.attack ||
        threatPower >= armyPower * _significantThreatShare;
    final baseUnderAttack =
        _profile.defendsWithArmy && threatPower > 0 && seriousEnough;
    if (baseUnderAttack) return ArmyStance.defend;

    if (_stance == ArmyStance.attack) {
      final losing = armyPower < enemyPower * _profile.retreatPowerRatio;
      return losing || armySize == 0 ? ArmyStance.muster : ArmyStance.attack;
    }

    final requiredRatio =
        _profile.attackPowerRatio * (1.5 - aggression.clamp(0.0, 1.0));
    final strongEnough = armyPower >= enemyPower * requiredRatio;
    final bigEnough = armySize >= _profile.minAttackers;
    final overwhelming = armySize >= _profile.forceAttackArmySize;
    return (bigEnough && strongEnough) || overwhelming
        ? ArmyStance.attack
        : ArmyStance.muster;
  }

  void _issueOrders({
    required Team aiTeam,
    required List<MobileUnitComponent> army,
    required List<MobileUnitComponent> threats,
    required double armyPower,
    required Vector2 rally,
  }) {
    switch (_stance) {
      case ArmyStance.attack:
        _strike(aiTeam, army, armyPower);
      case ArmyStance.muster:
        _sendAllTo(army, rally, tolerance: 1);
      case ArmyStance.defend:
        _sendAllTo(
          army,
          _centroidOf(threats),
          tolerance: _defenseRetargetDistance,
        );
    }
  }

  /// Splits off a fast raiding squad when the army is big enough, picks the
  /// main target and the raid target, and sends each group at its own.
  void _strike(Team aiTeam, List<MobileUnitComponent> army, double armyPower) {
    final raiders = _pickRaiders(army);
    final mainForce = army.where((u) => !raiders.contains(u)).toList();
    final plan = _strikePlanner.plan(
      aiTeam: aiTeam,
      armyCenter: _centroidOf(army),
      armyPower: armyPower,
      allowRaid: raiders.isNotEmpty,
      raidPower: _assessor.ofUnits(raiders).power,
    );
    _plan = plan;

    _sendGroupAt(mainForce, plan.main);
    final raid = plan.raid;
    if (raid == null) {
      _sendGroupAt(raiders, plan.main);
    } else {
      _sendGroupAt(raiders, raid);
    }
  }

  /// The fastest quarter of a large army (when the profile allows raiding).
  List<MobileUnitComponent> _pickRaiders(List<MobileUnitComponent> army) {
    final bigEnough = army.length >= _profile.minAttackers * 2;
    if (!_profile.raidsEconomy || !bigEnough) return const [];
    final bySpeed = [...army]
      ..sort((a, b) => b.blueprint.speed.compareTo(a.blueprint.speed));
    return bySpeed.take(max(2, army.length ~/ 4)).toList();
  }

  void _sendGroupAt(List<MobileUnitComponent> group, StrikeTarget target) {
    if (group.isEmpty) return;
    if (target.kind == StrikeTargetKind.base) {
      _releaseAll(group); // units march on and siege the base by themselves
      return;
    }
    _sendAllTo(
      group,
      _approachPoint(group, target),
      tolerance: _approachTolerance,
    );
  }

  /// A walkable point just short of [target], on the group's side of it, so
  /// the group stops inside weapon range instead of on top of the target.
  Vector2 _approachPoint(List<MobileUnitComponent> group, StrikeTarget target) {
    final shortestRange = group
        .map((u) => u.blueprint.attackRange)
        .where((r) => r > 0)
        .fold<double>(_defaultApproachDistance, min);
    final towardGroup = _centroidOf(group) - target.position;
    final direction = towardGroup.length2 == 0
        ? Vector2(1, 0)
        : towardGroup.normalized();
    final ideal = target.position + direction * (shortestRange * 0.8);
    return _groundFinder.nearestOpen(_game.terrainMap.grid, ideal) ?? ideal;
  }

  void _releaseAll(List<MobileUnitComponent> army) {
    for (final unit in army.where((u) => u.underManualControl)) {
      unit.releaseManualControl();
    }
  }

  void _sendAllTo(
    List<MobileUnitComponent> army,
    Vector2 point, {
    required double tolerance,
  }) {
    for (final unit in army) {
      final current = unit.moveOrderTarget;
      final alreadyOrdered =
          current != null && current.distanceTo(point) <= tolerance;
      // The order is cleared on arrival, so a unit already standing at the
      // destination must not be re-ordered (it would repath every round).
      final arrived = unit.position.distanceTo(point) <= _arrivedRadius;
      if (!alreadyOrdered && !arrived) unit.issueMoveOrder(point);
    }
  }

  Vector2 _centroidOf(List<MobileUnitComponent> units) {
    final sum = units.fold(Vector2.zero(), (acc, u) => acc + u.position);
    return sum / units.length.toDouble();
  }
}
