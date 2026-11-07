import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/allies/presentation/components/ally_sprite_factory/ally_sprite_factory.dart';
import 'package:boomspire/features/enemies/presentation/components/enemy_sprite_factory/enemy_sprite_factory.dart';
import 'package:boomspire/features/towers/presentation/training_center_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = MobileUnitRepositoryImpl();

  test('the skirmish roster includes the tower-defense tanks and barrages', () {
    for (final team in [Team.defaultPlayer, Team.aiOpponent]) {
      final kinds = repo.kindsFor(team);
      expect(
        kinds,
        containsAll([
          UnitKind.tank,
          UnitKind.rocketBarrage,
          UnitKind.artilleryBarrage,
          UnitKind.antiAirVehicle,
          UnitKind.helicopter,
          UnitKind.heavySoldier,
        ]),
        reason: team.label,
      );
    }
  });

  test('every buildable unit has a cost and some art for both sides', () {
    for (final kind in repo.kindsFor(Team.defaultPlayer)) {
      expect(repo.blueprintFor(Team.defaultPlayer, kind).cost, greaterThan(0));
      expect(
        AllySpriteFactory.supports(kind) || EnemySpriteFactory.supports(kind),
        isTrue,
        reason: '$kind has no sprite',
      );
    }
  });

  test('heavy infantry comes from the Training Center, vehicles from the '
      'War Factory', () {
    expect(
      TrainingCenterComponent.producibleKinds,
      contains(UnitKind.heavySoldier),
    );
    expect(
      TrainingCenterComponent.producibleKinds,
      isNot(contains(UnitKind.artilleryBarrage)),
    );
  });
}
