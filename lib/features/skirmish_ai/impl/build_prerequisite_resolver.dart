import '../../../core/combat/team.dart';
import '../../game_content/domain/models/build_requirement.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/unit_type.dart';

/// Works out which building the AI must construct next to unlock something
/// it wants, by following the target's [BuildRequirement]s (and theirs, in
/// turn) - e.g. a SAM Site needs a Tech Lab, which needs a Power Plant, and
/// a Command Post. Driven by the same requirement data the build rules use,
/// so a retuned/synced requirement list is followed automatically.
class BuildPrerequisiteResolver {
  static const _idPrefix = 'building.';

  final BoomspireGame _game;

  const BuildPrerequisiteResolver(this._game);

  /// The building to build next so that [target] becomes buildable, or null
  /// when nothing is missing (the target itself can be built now).
  BuildingType? nextMissing(Team team, UnitType target) {
    for (final requirement in _game.requirementsOf(target)) {
      final missing = switch (requirement) {
        BuildingExistsRequirement(:final buildingId) => _missingBuilding(
          team,
          buildingId,
        ),
        AnyBuildingExistsRequirement(:final buildingIds) => _missingOneOf(
          team,
          buildingIds,
        ),
        _ => null,
      };
      if (missing != null) return missing;
    }
    return null;
  }

  /// [buildingId] if it is missing - or, if it has its own unmet
  /// prerequisites, the first of those instead.
  BuildingType? _missingBuilding(Team team, String buildingId) {
    if (_game.hasBuilt(buildingId, team)) return null;
    final type = _typeOf(buildingId);
    return nextMissing(team, type) ?? type;
  }

  BuildingType? _missingOneOf(Team team, List<String> buildingIds) {
    if (buildingIds.any((id) => _game.hasBuilt(id, team))) return null;
    return _missingBuilding(team, buildingIds.first);
  }

  BuildingType _typeOf(String buildingId) =>
      BuildingType.values.byName(buildingId.substring(_idPrefix.length));
}
