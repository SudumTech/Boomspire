import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';

import '../../ai_director/domain/models/skirmish_directive.dart';
import '../../skirmish_ai/domain/models/ai_intel.dart';
import '../../skirmish_ai/domain/models/skirmish_ai_profile.dart';
import '../../skirmish_ai/extensions/game_difficulty_ai_extensions.dart';
import '../../skirmish_ai/impl/army_commander.dart';
import '../../skirmish_ai/impl/player_weakness_analyzer.dart';
import '../../skirmish_ai/impl/skirmish_build_planner.dart';
import '../../skirmish_ai/impl/skirmish_node_planner.dart';
import '../../skirmish_ai/impl/skirmish_production_planner.dart';
import '../../skirmish_ai/impl/skirmish_upgrade_planner.dart';
import '../../../core/combat/team.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/unit_type.dart';
import '../domain/models/game_status.dart';
import 'boomspire_game.dart';

/// The AI opponent's "brain" in a [GameMode.skirmish] match. It only
/// schedules - every actual decision lives in a focused planner under
/// `features/skirmish_ai/impl/`:
///
/// - [SkirmishBuildPlanner]: economy, production, defense and tech.
/// - [SkirmishProductionPlanner]: which units to roll out (countering the
///   player's army).
/// - [SkirmishNodePlanner]: claiming resource nodes.
/// - [SkirmishUpgradePlanner]: spending spare gold on upgrades.
/// - [ArmyCommander]: mustering, attacking, retreating and defending as one
///   force.
///
/// How well it plays is set by the match's `GameDifficulty` via
/// [SkirmishAiProfile] (reaction speed, mistakes, aggression thresholds,
/// income). Every purchase goes through the same rules and costs the
/// human player is bound by. The Gemini-backed director (or its local
/// fallback) supplies a periodic [SkirmishDirective] that nudges the
/// planners' aggression and tower appetite.
class AiSkirmishControllerComponent extends Component
    with HasGameReference<BoomspireGame> {
  static const _directiveInterval = 14.0;

  late final SkirmishAiProfile _profile;
  late final SkirmishBuildPlanner _buildPlanner;
  late final SkirmishProductionPlanner _productionPlanner;
  late final SkirmishNodePlanner _nodePlanner;
  late final SkirmishUpgradePlanner _upgradePlanner;
  late final ArmyCommander _commander;
  late final PlayerWeaknessAnalyzer _weakness;
  final Random _random = Random();

  double _clock = 0;
  double _directiveTimer = _directiveInterval * 0.2;
  late double _decisionTimer;
  bool _fetchingDirective = false;
  SkirmishDirective _directive = const SkirmishDirective(
    aggression: 0.5,
    buildBias: 0.5,
  );

  @override
  Future<void> onLoad() async {
    _profile = game.difficulty.skirmishAiProfile;
    _buildPlanner = SkirmishBuildPlanner(game, _profile);
    _productionPlanner = SkirmishProductionPlanner(game, _profile);
    _nodePlanner = SkirmishNodePlanner(game);
    _upgradePlanner = SkirmishUpgradePlanner(game);
    _commander = ArmyCommander(game, _profile);
    _weakness = PlayerWeaknessAnalyzer(game);
    _decisionTimer = _profile.decisionInterval * 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final economy = game.aiEconomy;
    final aiTeam = game.aiTeam;
    if (economy == null || aiTeam == null || economy.isDefeated) return;
    if (game.gameState.status != GameStatus.playing) return;

    _directiveTimer += dt;
    if (_directiveTimer >= _directiveInterval && !_fetchingDirective) {
      _directiveTimer = 0;
      unawaited(_refreshDirective());
    }

    _clock += dt;
    _decisionTimer += dt;
    if (_decisionTimer < _profile.decisionInterval) return;
    _decisionTimer = 0;
    if (_random.nextDouble() < _profile.mistakeChance) return;
    _decide();
  }

  /// One decision round, in priority order.
  void _decide() {
    final aiTeam = game.aiTeam!;
    final built = _buildPlanner.tryBuild(aiTeam, _directive);
    // A production building built this very round has not mounted yet, so
    // it must not also produce in the same round (a unit would appear
    // before its own factory did).
    final builtProduction =
        built == BuildingType.trainingCenter ||
        built == BuildingType.warFactory;
    if (!builtProduction) {
      if (_profile.capturesNodes) _nodePlanner.dispatchCapturer(aiTeam);
      _productionPlanner.produce(
        aiTeam,
        savingsTarget: _buildPlanner.savingsTarget(aiTeam, _clock),
      );
    }
    if (_profile.upgradesStructures) _upgradePlanner.tryUpgrade(aiTeam);
    _commander.command(aiTeam, _directive.aggression);
    _publishIntel(aiTeam, built);
  }

  /// Pushes the AI's current thinking to [BoomspireGame.aiIntel] (shown in
  /// the debug HUD) and logs notable changes.
  void _publishIntel(Team aiTeam, UnitType? built) {
    final economy = game.aiEconomy!;
    final intel = AiIntel(
      stance: _commander.stance,
      targetLabel: _commander.mainTarget?.label ?? '-',
      raidLabel: _commander.raidTarget?.label ?? '-',
      armySize: game.world.activeUnits
          .where((u) => !u.destroyed && u.team.id == aiTeam.id)
          .length,
      armyPower: _commander.armyPower,
      enemyPower: _commander.enemyPower,
      structures: game.world.activeTowers
          .where((t) => t.owner.id == aiTeam.id)
          .length,
      gold: economy.gold,
      ownedNodes: game.world.activeResourceNodes
          .where((n) => n.owner?.id == aiTeam.id)
          .length,
      airTargetLabel: _commander.airTarget?.label ?? '-',
      spotsNoAntiAir:
          _profile.exploitsWeaknesses && _weakness.analyze(aiTeam).lacksAntiAir,
    );
    final previous = game.aiIntel.value;
    game.aiIntel.value = intel;
    if (kDebugMode) _logChanges(previous, intel, built);
  }

  void _logChanges(AiIntel? before, AiIntel now, UnitType? built) {
    if (built != null) debugPrint('[AI] built ${built.name}');
    if (before?.stance != now.stance) {
      debugPrint(
        '[AI] stance ${before?.stance.name} -> ${now.stance.name} '
        '(army ${now.armyPower.toStringAsFixed(0)} vs '
        'enemy ${now.enemyPower.toStringAsFixed(0)})',
      );
    }
    if (before?.targetLabel != now.targetLabel && now.targetLabel != '-') {
      debugPrint('[AI] main target: ${now.targetLabel}');
    }
    if (before?.spotsNoAntiAir != now.spotsNoAntiAir) {
      debugPrint(
        now.spotsNoAntiAir
            ? '[AI] spotted: opponent has NO anti-air -> building an air force'
            : '[AI] opponent now has anti-air',
      );
    }
    if (before?.airTargetLabel != now.airTargetLabel &&
        now.airTargetLabel != '-') {
      debugPrint('[AI] air strike: ${now.airTargetLabel}');
    }
    if (before?.raidLabel != now.raidLabel && now.raidLabel != '-') {
      debugPrint('[AI] raiding: ${now.raidLabel}');
    }
  }

  SkirmishSnapshot _buildSnapshot() {
    final economy = game.aiEconomy!;
    final aiTeam = game.aiTeam!;
    return SkirmishSnapshot(
      aiGold: economy.gold,
      aiHealth: economy.health,
      playerGold: game.gameState.gold,
      playerHealth: game.gameState.health,
      aiTowerCount: game.world.activeTowers
          .where((t) => t.owner == aiTeam)
          .length,
      playerTowerCount: game.world.activeTowers
          .where((t) => t.owner == game.playerTeam)
          .length,
      aiUnitCount: game.world.activeUnits
          .where((u) => !u.destroyed && u.team.id == aiTeam.id)
          .length,
      playerUnitCount: game.world.activeUnits
          .where((u) => !u.destroyed && u.team.id == game.playerTeam.id)
          .length,
    );
  }

  Future<void> _refreshDirective() async {
    _fetchingDirective = true;
    try {
      _directive = await game.aiDirector.planSkirmish(_buildSnapshot());
    } finally {
      _fetchingDirective = false;
    }
  }
}
