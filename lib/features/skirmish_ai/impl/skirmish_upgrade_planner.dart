import '../../../core/combat/team.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/unit_type.dart';
import '../../towers/presentation/tower_component.dart';
import 'ai_base_queries.dart';

/// Spends *spare* gold on upgrading structures, production buildings first
/// (they make every future unit stronger), then the Gold Mine, then the
/// combat towers.
class SkirmishUpgradePlanner {
  /// Upgrades only happen while gold stays above this many cheapest-unit
  /// costs afterward, so upgrading never starves unit production.
  static const _unitReserveFactor = 3;

  static const List<UnitType> _upgradePriority = [
    BuildingType.trainingCenter,
    BuildingType.warFactory,
    BuildingType.goldMine,
  ];

  final BoomspireGame _game;
  final AiBaseQueries _queries;

  SkirmishUpgradePlanner(this._game) : _queries = AiBaseQueries(_game);

  /// Buys at most one upgrade; returns whether it did.
  bool tryUpgrade(Team aiTeam) {
    if (!_queries.hasProduction(aiTeam)) return false;
    final reserve = _queries.cheapestUnitCost(aiTeam) * _unitReserveFactor;
    final candidate = _nextUpgradeable(aiTeam);
    if (candidate == null) return false;
    final cost = candidate.upgradeCost;
    if (_game.goldFor(aiTeam) - cost < reserve) return false;
    if (!_game.spendGoldFor(aiTeam, cost)) return false;
    candidate.upgrade();
    return true;
  }

  TowerComponent? _nextUpgradeable(Team aiTeam) {
    final upgradeable = _queries
        .ownedStructures(aiTeam)
        .where((t) => t.isMounted && !t.destroyed && t.canUpgrade)
        .toList();
    int rank(TowerComponent t) {
      final index = _upgradePriority.indexOf(t.blueprint.type);
      return index == -1 ? _upgradePriority.length : index;
    }

    upgradeable.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.upgradeLevel.compareTo(b.upgradeLevel);
    });
    return upgradeable.isEmpty ? null : upgradeable.first;
  }
}
