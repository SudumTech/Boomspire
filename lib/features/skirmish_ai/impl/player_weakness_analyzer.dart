import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../domain/models/player_weakness.dart';

/// Scouts the opponent's defenses for gaps (currently: no anti-air).
class PlayerWeaknessAnalyzer {
  final BoomspireGame _game;

  const PlayerWeaknessAnalyzer(this._game);

  PlayerWeakness analyze(Team aiTeam) {
    final armedTowers = _game.world
        .towersHostileTo(aiTeam)
        .where(
          (t) =>
              t.blueprint.damage > 0 &&
              t.blueprint.attackDomains.contains(UnitDomain.air),
        )
        .length;
    final armedUnits = _game.world
        .unitsHostileTo(aiTeam)
        .where(
          (u) =>
              u.blueprint.attackDamage > 0 &&
              u.blueprint.attackDomains.contains(UnitDomain.air),
        )
        .length;
    return PlayerWeakness(antiAirSources: armedTowers + armedUnits);
  }
}
