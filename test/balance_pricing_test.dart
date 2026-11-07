import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/impl/scaled_cost_tower_repository.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/machine_gun_tower_component.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/widgets.dart' show Color, Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => S.load(const Locale('en')));

  test('skirmish towers cost more; only the price changes', () {
    final base = TowerRepositoryImpl();
    final scaled = ScaledCostTowerRepository(base, 1.6);
    for (final type in TowerType.values) {
      final a = base.blueprintFor(type);
      final b = scaled.blueprintFor(type);
      expect(b.cost, (a.cost * 1.6).round(), reason: '$type');
      expect(b.damage, a.damage);
      expect(b.range, a.range);
      expect(b.maxHp, a.maxHp);
    }
    expect(scaled.all.length, base.all.length);
  });

  test('a unit can aim at a tower before it has finished loading', () {
    final tower = MachineGunTowerComponent(
      position: Vector2.zero(),
      cellSize: 64,
      blueprint: TowerRepositoryImpl().blueprintFor(TowerType.machineGun),
    );
    expect(() => tower.markTargeted(const Color(0xFFFF0000)), returnsNormally);
  });

  test('assault units reach far enough to trade with the towers they '
      'attack', () {
    final repo = MobileUnitRepositoryImpl();
    final towers = TowerRepositoryImpl();
    final tank = repo.blueprintFor(Team.defaultPlayer, UnitKind.tank);
    final soldier = repo.blueprintFor(Team.defaultPlayer, UnitKind.soldier);
    final artillery = repo.blueprintFor(
      Team.defaultPlayer,
      UnitKind.artilleryBarrage,
    );
    // Even basic infantry outrange the machine-gun tower...
    expect(
      soldier.attackRange,
      greaterThan(towers.blueprintFor(TowerType.machineGun).range),
    );
    // ...a tank is within a short walk of the cannon tower's reach...
    expect(
      tank.attackRange,
      greaterThan(towers.blueprintFor(TowerType.cannon).range * 0.8),
    );
    // ...and artillery outranges every tower but the Rocket Silo.
    for (final type in TowerType.values) {
      if (type == TowerType.rocketSilo || type == TowerType.sam) continue;
      expect(
        artillery.attackRange,
        greaterThan(towers.blueprintFor(type).range),
        reason: '$type',
      );
    }
  });
}
