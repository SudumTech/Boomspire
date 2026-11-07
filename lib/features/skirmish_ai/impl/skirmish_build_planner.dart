import 'package:flame/components.dart';

import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../ai_director/domain/models/skirmish_directive.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../game_core/presentation/resource_node_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/models/unit_type.dart';
import '../domain/models/skirmish_ai_profile.dart';
import 'ai_base_queries.dart';
import 'build_site_finder.dart';
import 'player_weakness_analyzer.dart';

/// Decides what the AI constructs next, through the exact same
/// [BoomspireGame.canBuildTower]/[BoomspireGame.buildStructure] gate the
/// human's build menu uses.
///
/// Priorities, highest first:
/// 1. A counter tower when units are attacking the base and defense is thin.
/// 2. Core economy/production: Gold Mine, Training Center, War Factory.
/// 3. The peacetime defense garrison.
/// 4. Expansion (more production, tech) - only from *spare* gold, so the AI
///    always keeps enough to actually field units.
/// 5. Extra towers, sized by the director's `buildBias`.
class SkirmishBuildPlanner {
  /// Soft cap on total structures - a performance valve, not a nerf.
  static const maxOwnStructures = 24;

  static const _coreBuildOrder = [
    BuildingType.goldMine,
    BuildingType.trainingCenter,
    BuildingType.warFactory,
  ];

  /// Core order when the opponent has no anti-air: the War Factory (the only
  /// source of aircraft) comes before the Training Center.
  static const _airFirstCoreOrder = [
    BuildingType.goldMine,
    BuildingType.warFactory,
    BuildingType.trainingCenter,
  ];
  static const _techBuildOrder = [
    BuildingType.techLab,
    BuildingType.commandPost,
  ];
  static const _expandable = [
    BuildingType.goldMine,
    BuildingType.trainingCenter,
    BuildingType.warFactory,
  ];
  static const _airFirstExpandable = [
    BuildingType.warFactory,
    BuildingType.goldMine,
    BuildingType.trainingCenter,
  ];

  /// How far in front of / behind the base (world px) sites are preferred.
  static const _siteOffset = 150.0;

  /// A node with no friendly tower within this distance counts as unguarded.
  static const _nodeGuardRadius = 240.0;
  static const _sitesTriedPerBuild = 24;

  /// Spare gold means this many cheapest-unit costs beyond the reserve.
  static const _spareGoldReserveFactor = 2;

  /// How long the AI banks gold for a building before spending normally.
  static const _maxSavingSeconds = 20.0;
  static const _spendingSeconds = 15.0;

  final BoomspireGame _game;
  final SkirmishAiProfile _profile;
  final AiBaseQueries _queries;
  final BuildSiteFinder _siteFinder;
  final PlayerWeaknessAnalyzer _weakness;

  BuildingType? _savingFor;
  bool _saving = true;
  double _phaseStart = 0;

  SkirmishBuildPlanner(
    this._game,
    this._profile, {
    this._siteFinder = const BuildSiteFinder(),
  }) : _queries = AiBaseQueries(_game),
       _weakness = PlayerWeaknessAnalyzer(_game);

  /// Attempts one build; returns the type placed, or null if none.
  UnitType? tryBuild(Team aiTeam, SkirmishDirective directive) {
    final base = _game.world.aiHomeBase;
    final enemyBase = _game.baseTargetFor(aiTeam);
    if (base == null || !base.isMounted || enemyBase == null) return null;
    if (_queries.ownedStructures(aiTeam).length >= maxOwnStructures) {
      return null;
    }

    final threats = _queries.threatsNear(aiTeam, base.position);
    final order = _chooseOrder(
      aiTeam,
      directive,
      threats,
      _BaseContext(base.position, enemyBase),
    );
    if (order == null) return null;
    return _place(aiTeam, order) ? order.type : null;
  }

  _BuildOrder? _chooseOrder(
    Team aiTeam,
    SkirmishDirective directive,
    List<MobileUnitComponent> threats,
    _BaseContext context,
  ) {
    final reserve = _queries.hasProduction(aiTeam)
        ? _queries.cheapestUnitCost(aiTeam)
        : 0;
    final spareReserve = reserve * _spareGoldReserveFactor;
    final garrison = _queries.ownedCombatTowerCount(aiTeam);
    final threatDomain = _expectedThreatDomain(aiTeam);

    final underAttack = threats.isNotEmpty;
    if (underAttack && garrison < _profile.baseDefenseTowers + 2) {
      return context.order(
        _pickCombatTower(aiTeam, 0, _queries.counterDomainFor(threats)),
        _SiteSide.front,
      );
    }

    final core = _firstAffordable(aiTeam, _coreOrder(aiTeam), reserve);
    if (core != null) return context.order(core, _SiteSide.back);

    // Aircraft need a Command Post (which needs a Tech Lab): going for an
    // air force against an opponent without anti-air starts that chain early.
    if (_exploitsAirWeakness(aiTeam)) {
      final tech = _firstAffordable(aiTeam, _techBuildOrder, reserve);
      if (tech != null) return context.order(tech, _SiteSide.back);
    }

    if (garrison < _profile.baseDefenseTowers) {
      return context.order(
        _pickCombatTower(aiTeam, reserve, threatDomain),
        _SiteSide.front,
      );
    }

    final fortify = _nodeNeedingGuard(aiTeam);
    if (fortify != null) {
      final tower = _pickCombatTower(aiTeam, reserve, threatDomain);
      if (tower != null) {
        return _BuildOrder(
          tower,
          fortify.position,
          _siteFinder.pointToward(
            fortify.position,
            context.enemyBase,
            _siteOffset / 2,
          ),
        );
      }
    }

    final expansion = _nextExpansion(aiTeam, spareReserve);
    if (expansion != null) return context.order(expansion, _SiteSide.back);

    final extraTowers = (directive.buildBias * 3).round();
    if (garrison < _profile.baseDefenseTowers + extraTowers) {
      return context.order(
        _pickCombatTower(aiTeam, spareReserve, threatDomain),
        _SiteSide.front,
      );
    }
    return null;
  }

  /// An owned resource node with no friendly combat tower close by.
  ResourceNodeComponent? _nodeNeedingGuard(Team aiTeam) {
    if (!_profile.fortifiesNodes) return null;
    final towers = _queries
        .ownedStructures(aiTeam)
        .where((t) => AiBaseQueries.combatTowerTypes.contains(t.blueprint.type))
        .toList();
    for (final node in _game.world.activeResourceNodes) {
      if (node.owner?.id != aiTeam.id) continue;
      final guarded = towers.any(
        (t) => t.position.distanceTo(node.position) <= _nodeGuardRadius,
      );
      if (!guarded) return node;
    }
    return null;
  }

  /// The first building in [order] it still lacks (below any production
  /// cap), may build, and can afford while keeping [reserve].
  BuildingType? _firstAffordable(
    Team aiTeam,
    List<BuildingType> order,
    int reserve,
  ) {
    for (final candidate in order) {
      if (_queries.ownedCountOf(aiTeam, candidate) > 0) continue;
      if (_canAfford(aiTeam, candidate, reserve)) return candidate;
    }
    return null;
  }

  UnitType? _nextExpansion(Team aiTeam, int spareReserve) {
    for (final candidate in _expandableOrder(aiTeam)) {
      final owned = _queries.ownedCountOf(aiTeam, candidate);
      if (owned >= _capFor(candidate)) continue;
      if (_canAfford(aiTeam, candidate, spareReserve)) return candidate;
    }
    return _firstAffordable(aiTeam, _techBuildOrder, spareReserve);
  }

  /// Gold the AI should bank before spending on units: what it takes to
  /// afford its next economy/production building (plus the usual spare
  /// reserve). Zero when it has no pending building, or has no production
  /// yet (the opening spends freely). Without this, units would swallow
  /// every coin the instant a factory is idle and a second War Factory
  /// could never be afforded.
  ///
  /// Saving is time-boxed: after [_maxSavingSeconds] without getting there
  /// the AI spends normally for [_spendingSeconds] (so its army never stalls
  /// behind a slow income), then tries again. [now] is the AI's clock.
  int savingsTarget(Team aiTeam, double now) {
    final wanted = _queries.hasProduction(aiTeam)
        ? _nextWantedBuilding(aiTeam)
        : null;
    if (wanted == null) {
      _savingFor = null;
      return 0;
    }
    if (wanted != _savingFor) {
      _savingFor = wanted;
      _saving = true;
      _phaseStart = now;
    }
    _advanceSavingPhase(now);
    if (!_saving) return 0;
    final spare = _queries.cheapestUnitCost(aiTeam) * _spareGoldReserveFactor;
    return _game.blueprintFor(wanted).cost + spare;
  }

  void _advanceSavingPhase(double now) {
    final limit = _saving ? _maxSavingSeconds : _spendingSeconds;
    if (now - _phaseStart < limit) return;
    _saving = !_saving;
    _phaseStart = now;
  }

  BuildingType? _nextWantedBuilding(Team aiTeam) {
    final candidates = [
      ..._coreOrder(aiTeam),
      if (_exploitsAirWeakness(aiTeam)) ..._techBuildOrder,
      ..._expandableOrder(aiTeam),
    ];
    for (final candidate in candidates) {
      final owned = _queries.ownedCountOf(aiTeam, candidate);
      if (owned >= _capFor(candidate)) continue;
      if (_game.canBuildTower(candidate, owner: aiTeam)) return candidate;
    }
    return null;
  }

  bool _exploitsAirWeakness(Team aiTeam) =>
      _profile.exploitsWeaknesses && _weakness.analyze(aiTeam).lacksAntiAir;

  List<BuildingType> _coreOrder(Team aiTeam) =>
      _exploitsAirWeakness(aiTeam) ? _airFirstCoreOrder : _coreBuildOrder;

  List<BuildingType> _expandableOrder(Team aiTeam) =>
      _exploitsAirWeakness(aiTeam) ? _airFirstExpandable : _expandable;

  int _capFor(BuildingType type) => type == BuildingType.goldMine
      ? _profile.maxGoldMines
      : _profile.maxProductionBuildings;

  bool _canAfford(Team aiTeam, UnitType type, int reserve) =>
      _game.canBuildTower(type, owner: aiTeam) &&
      _game.goldFor(aiTeam) - _game.blueprintFor(type).cost >= reserve;

  /// The combat tower best suited to [domain] that is buildable and leaves
  /// [reserve] gold: prefers the type it owns the fewest of (variety), then
  /// the most damage per gold.
  TowerType? _pickCombatTower(Team aiTeam, int reserve, UnitDomain domain) {
    final options = AiBaseQueries.combatTowerTypes
        .where((t) => _canAfford(aiTeam, t, reserve))
        .toList();
    if (options.isEmpty) return null;

    final countering = options
        .where((t) => _game.blueprintFor(t).attackDomains.contains(domain))
        .toList();
    final pool = countering.isEmpty ? options : countering;
    pool.sort((a, b) {
      final byCount = _queries
          .ownedCountOf(aiTeam, a)
          .compareTo(_queries.ownedCountOf(aiTeam, b));
      return byCount != 0
          ? byCount
          : _damagePerGold(b).compareTo(_damagePerGold(a));
    });
    return pool.first;
  }

  double _damagePerGold(TowerType type) {
    final blueprint = _game.blueprintFor(type);
    final dps = blueprint.damage * blueprint.clipSize / blueprint.fireRate;
    return dps / blueprint.cost;
  }

  /// With no attackers in sight, guard against air if the player fields
  /// aircraft and the base has no anti-air yet; otherwise ground.
  UnitDomain _expectedThreatDomain(Team aiTeam) {
    final enemy = _queries.enemyComposition(aiTeam);
    final hasAntiAir = AiBaseQueries.combatTowerTypes
        .where(
          (t) => _game.blueprintFor(t).attackDomains.contains(UnitDomain.air),
        )
        .any((t) => _queries.ownedCountOf(aiTeam, t) > 0);
    return enemy.air > 0 && !hasAntiAir ? UnitDomain.air : UnitDomain.ground;
  }

  bool _place(Team aiTeam, _BuildOrder order) {
    final grid = _game.terrainMap.grid;
    final cells = _siteFinder.candidates(grid, order.center, order.preferred);
    for (final cell in cells.take(_sitesTriedPerBuild)) {
      final point = grid.cellCenter(cell);
      if (_game.buildStructure(aiTeam, order.type, point) != null) return true;
    }
    return false;
  }
}

enum _SiteSide { front, back }

/// What to build and the area to build it in.
class _BuildOrder {
  final UnitType type;
  final Vector2 center;
  final Vector2 preferred;

  const _BuildOrder(this.type, this.center, this.preferred);
}

/// The AI base and the enemy base, used to put defenses on the enemy-facing
/// side of the base and economy on the safe side.
class _BaseContext {
  static const _offset = SkirmishBuildPlanner._siteOffset;

  final Vector2 base;
  final Vector2 enemyBase;

  const _BaseContext(this.base, this.enemyBase);

  _BuildOrder? order(UnitType? type, _SiteSide side) {
    if (type == null) return null;
    final direction = side == _SiteSide.front ? _offset : -_offset;
    final toward = enemyBase - base;
    final preferred = toward.length2 == 0
        ? base.clone()
        : base + toward.normalized() * direction;
    return _BuildOrder(type, base, preferred);
  }
}
