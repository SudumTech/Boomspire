// Automated gameplay smoke tests: exercise the exact tap -> build pipeline
// that's otherwise only reachable via manual play, so regressions in tower
// placement/economy/pathfinding are caught by `flutter test` instead of
// needing a human (or flaky browser automation) to click through the game.
//
// These load the game directly (onGameResize/load/mount/update) instead of
// pumping a full widget tree, since that's much faster and all we need is
// the component tree mounted so tap handling and pathfinding work.
import 'dart:math';

import 'package:boomspire/core/combat/enums/unit_domain.dart';
import 'package:boomspire/features/combat/presentation/bullet_component.dart';
import 'package:boomspire/features/combat/presentation/rocket_component.dart';
import 'package:boomspire/features/game_core/domain/models/unit_card_info.dart';
import 'package:boomspire/core/combat/mobile_unit_blueprint.dart';
import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/core/combat/unit_objective.dart';
import 'package:boomspire/core/combat/weapon_type.dart';
import 'package:boomspire/features/ai_director/domain/models/skirmish_directive.dart';
import 'package:boomspire/features/skirmish_ai/impl/player_weakness_analyzer.dart';
import 'package:boomspire/features/skirmish_ai/impl/skirmish_build_planner.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/ambient_environment.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/combat/presentation/mobile_unit_component.dart';
import 'package:boomspire/features/game_core/domain/models/game_config.dart';
import 'package:boomspire/features/game_core/domain/models/game_difficulty.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/map_editor/domain/models/environment_settings.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/impl/map_draft_scene_factory.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/terrain/presentation/components/bird_flock_component/bird_flock_component.dart';
import 'package:boomspire/features/skirmish_ai/domain/enums/army_stance.dart';
import 'package:boomspire/features/skirmish_ai/domain/models/army_strength.dart';
import 'package:boomspire/features/skirmish_ai/extensions/game_difficulty_ai_extensions.dart';
import 'package:boomspire/features/skirmish_ai/domain/enums/strike_target_kind.dart';
import 'package:boomspire/features/skirmish_ai/impl/ai_base_queries.dart';
import 'package:boomspire/features/skirmish_ai/impl/army_commander.dart';
import 'package:boomspire/features/skirmish_ai/impl/strike_planner.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/domain/models/inspected_info.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/game_core/presentation/resource_node_component.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/domain/models/unit_blueprint.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/machine_gun_tower_component.dart';
import 'package:boomspire/features/towers/presentation/rocket_silo_tower_component.dart';
import 'package:boomspire/features/towers/presentation/training_center_component.dart';
import 'package:boomspire/features/towers/presentation/war_factory_component.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:boomspire/core/rendering/impl/procedural_unit_render_repository_impl.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('build pipeline', () {
    for (final scene in GameScenes.all) {
      test(
        'selecting + tapping an open cell places a tower (${scene.id})',
        () async {
          final game = await _bootGame(scene);
          final openCell = _findOpenCell(game);
          final startingGold = game.gameState.gold;

          game.selectTowerType(TowerType.machineGun);
          final cellCenter = game.terrainMap.grid.cellCenter(openCell);
          // First tap only previews the range/footprint; the same cell must
          // be tapped again to actually commit the build (see
          // BoomspireGame.pendingPlacement).
          game.handleArenaTap(cellCenter);
          expect(game.pendingPlacement.value, openCell);
          game.handleArenaTap(cellCenter);

          expect(
            game.gameState.gold,
            lessThan(startingGold),
            reason: 'gold should be spent after a successful build',
          );
          expect(game.world.activeTowers, hasLength(1));
        },
      );
    }

    test(
      'tapping a blocked (mountain/river) cell does not spend gold',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        Point<int>? blockedCell;
        outer:
        for (var row = 0; row < grid.rows; row++) {
          for (var col = 0; col < grid.cols; col++) {
            if (grid.isBlocked(col, row)) {
              blockedCell = Point(col, row);
              break outer;
            }
          }
        }
        expect(blockedCell, isNotNull);

        final startingGold = game.gameState.gold;
        game.selectTowerType(TowerType.machineGun);
        game.handleArenaTap(grid.cellCenter(blockedCell!));

        expect(game.gameState.gold, startingGold);
        expect(game.world.activeTowers, isEmpty);
      },
    );

    test('single-use Tech Lab locks once built', () async {
      final game = await _bootGame(GameScenes.all.first);
      final grid = game.terrainMap.grid;
      game.gameState.addGold(1000);

      // Tech Lab requires a Power Plant first (see `boomspire_game.dart`'s
      // `buildBlockReason`).
      final powerPlantCell = _findOpenCell(game);
      game.selectTowerType(BuildingType.powerPlant);
      game.handleArenaTap(grid.cellCenter(powerPlantCell));
      game.handleArenaTap(grid.cellCenter(powerPlantCell));
      expect(game.buildBlockReason(BuildingType.techLab), isNull);

      final cell = _findOpenCell(game);
      game.selectTowerType(BuildingType.techLab);
      game.handleArenaTap(grid.cellCenter(cell));
      game.handleArenaTap(grid.cellCenter(cell));

      expect(game.towerCountFor(BuildingType.techLab), 1);
      expect(
        game.buildBlockReason(BuildingType.techLab),
        'Max 1 built',
        reason:
            'Tech Lab should report a lock reason once its 1-build cap '
            'is hit',
      );
    });

    test('Command Post is single-use, but Training Center and War Factory have '
        'no build cap - more than one of those can be built', () async {
      final commandPostGame = await _bootGame(GameScenes.all.first);
      final commandPostGrid = commandPostGame.terrainMap.grid;
      commandPostGame.gameState.addGold(2000);

      // Command Post requires a War Factory or Training Center first.
      final warFactoryCell = _findOpenCell(commandPostGame);
      commandPostGame.selectTowerType(BuildingType.warFactory);
      commandPostGame.handleArenaTap(
        commandPostGrid.cellCenter(warFactoryCell),
      );
      commandPostGame.handleArenaTap(
        commandPostGrid.cellCenter(warFactoryCell),
      );

      final firstCell = _findOpenCell(commandPostGame);
      commandPostGame.selectTowerType(BuildingType.commandPost);
      commandPostGame.handleArenaTap(commandPostGrid.cellCenter(firstCell));
      commandPostGame.handleArenaTap(commandPostGrid.cellCenter(firstCell));
      final secondCell = _findOpenCell(commandPostGame);
      commandPostGame.selectTowerType(BuildingType.commandPost);
      commandPostGame.handleArenaTap(commandPostGrid.cellCenter(secondCell));

      expect(commandPostGame.towerCountFor(BuildingType.commandPost), 1);
      expect(
        commandPostGame.buildBlockReason(BuildingType.commandPost),
        'Max 1 built',
        reason:
            'Command Post should report a lock reason once its 1-build '
            'cap is hit',
      );

      for (final type in [
        BuildingType.trainingCenter,
        BuildingType.warFactory,
      ]) {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(5000);

        for (var i = 0; i < 3; i++) {
          expect(game.buildBlockReason(type), isNull);
          final cell = _findOpenCell(game);
          game.selectTowerType(type);
          game.handleArenaTap(grid.cellCenter(cell));
          game.handleArenaTap(grid.cellCenter(cell));
        }

        expect(game.towerCountFor(type), 3);
        expect(
          game.buildBlockReason(type),
          isNull,
          reason: '$type should never report a build-limit lock',
        );
      }
    });

    test(
      'Training Center builds an Ally Soldier on demand from its menu',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(1000);

        final cell = _findOpenCell(game);
        game.selectTowerType(BuildingType.trainingCenter);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        expect(game.towerCountFor(BuildingType.trainingCenter), 1);
        expect(game.world.unitsAlliedWith(game.playerTeam), isEmpty);

        final trainingCenter = game.world.activeTowers
            .whereType<TrainingCenterComponent>()
            .first;
        final startingGold = game.gameState.gold;
        expect(trainingCenter.canProduce, isTrue);
        expect(trainingCenter.produceSoldier(), isTrue);
        // Yield once so the ally's async sprite-load finishes mounting it.
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.unitsAlliedWith(game.playerTeam), isNotEmpty);
        expect(game.gameState.gold, startingGold - trainingCenter.soldierCost);
        // A fresh production request is refused until the cooldown elapses.
        expect(trainingCenter.canProduce, isFalse);
        expect(trainingCenter.produceSoldier(), isFalse);
      },
    );

    test(
      'War Factory builds an Ally vehicle/aircraft on demand from its menu',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(1000);

        final cell = _findOpenCell(game);
        game.selectTowerType(BuildingType.warFactory);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        expect(game.towerCountFor(BuildingType.warFactory), 1);
        expect(game.world.unitsAlliedWith(game.playerTeam), isEmpty);

        final warFactory = game.world.activeTowers
            .whereType<WarFactoryComponent>()
            .first;
        final startingGold = game.gameState.gold;
        expect(warFactory.produceUnit(UnitKind.tank), isTrue);
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.unitsAlliedWith(game.playerTeam), isNotEmpty);
        expect(
          game.gameState.gold,
          startingGold - warFactory.costFor(UnitKind.tank),
        );
        // Busy producing - a second request is refused until it cools down.
        expect(warFactory.produceUnit(UnitKind.aircraft), isFalse);
      },
    );

    test('Rocket Silo ignores enemies inside its minimum range', () async {
      final scene = GameScenes.all.first;
      final game = await _bootGame(scene);
      game.gameState.addGold(3000);
      final grid = game.terrainMap.grid;

      // Rocket Silo requires both Tech Lab and Command Post to be built
      // first (see `boomspire_game.dart`'s `buildBlockReason`) - which in
      // turn each require their own prerequisite (Power Plant, and War
      // Factory/Training Center respectively).
      for (final prereq in [
        BuildingType.powerPlant,
        BuildingType.warFactory,
        BuildingType.techLab,
        BuildingType.commandPost,
      ]) {
        final prereqCell = _findOpenCell(game);
        game.selectTowerType(prereq);
        game.handleArenaTap(grid.cellCenter(prereqCell));
        game.handleArenaTap(grid.cellCenter(prereqCell));
      }

      final cell = _findOpenCell(game);
      game.selectTowerType(TowerType.rocketSilo);
      game.handleArenaTap(grid.cellCenter(cell));
      game.handleArenaTap(grid.cellCenter(cell));
      final silo = game.world.activeTowers
          .whereType<RocketSiloTowerComponent>()
          .first;
      await Future<void>.delayed(Duration.zero);
      game.update(0);

      final blueprint = TowerRepositoryImpl().blueprintFor(
        TowerType.rocketSilo,
      );
      expect(blueprint.minRange, greaterThan(0));

      // Stationary (speed 0) so it can't just wander out of the tower's
      // reach before the tower has a chance to (not) engage it.
      const stationarySoldier = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Soldier',
        maxHealth: 1000,
        speed: 0,
        bounty: 0,
        size: 34,
      );

      // Enemy well inside the dead zone: should never take damage.
      // Position is set only after mounting, since
      // MobileUnitComponent.onLoad overwrites `position` to a random spawn
      // point (for `UnitObjective.rushBase` units).
      final closeEnemy = MobileUnitComponent(
        blueprint: stationarySoldier,
        team: Team.invaders,
        objective: UnitObjective.rushBase,
      );
      game.world.spawnUnit(closeEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      closeEnemy.position = silo.position + Vector2(blueprint.minRange / 2, 0);
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }
      expect(closeEnemy.health, closeEnemy.blueprint.maxHealth);

      // Enemy just outside the dead zone but still in range: gets hit.
      final farEnemy = MobileUnitComponent(
        blueprint: stationarySoldier,
        team: Team.invaders,
        objective: UnitObjective.rushBase,
      );
      game.world.spawnUnit(farEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      farEnemy.position = silo.position + Vector2(blueprint.minRange + 20, 0);
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }
      expect(farEnemy.health, lessThan(farEnemy.blueprint.maxHealth));
    });
  });

  group('click-to-inspect', () {
    test(
      'tapping the player\'s own tower selects it, not the inspect card',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        final cell = _findOpenCell(game);
        game.selectTowerType(TowerType.machineGun);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        final tower = game.world.activeTowers.first;
        game.handleArenaTap(tower.position);

        expect(game.selectedTower.value, tower);
        expect(game.inspected.value, isNull);
      },
    );

    test(
      'tapping an enemy tower shows its info instead of doing nothing',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        final base = game.world.aiHomeBase!;
        final grid = game.terrainMap.grid;
        final baseCell = grid.worldToCell(base.position);
        final built = game.buildStructure(
          aiTeam,
          TowerType.machineGun,
          grid.cellCenter(Point(baseCell.x + 2, baseCell.y)),
        );
        expect(built, isNotNull);

        game.handleArenaTap(built!.position);

        expect(game.selectedTower.value, isNull);
        expect(game.inspected.value, isNotNull);
        expect(game.inspected.value!.kind, InspectedKind.tower);
        expect(game.inspected.value!.owner, aiTeam);
        expect(game.inspected.value!.name, built.blueprint.name);
      },
    );

    test('tapping any unit shows its info', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Soldier',
        maxHealth: 10,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final unit = MobileUnitComponent(
        blueprint: blueprint,
        team: game.aiTeam!,
        objective: UnitObjective.huntHostiles,
        position: Vector2(200, 200),
      );
      game.world.spawnUnit(unit);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      unit.position = Vector2(200, 200);

      game.handleArenaTap(unit.position);

      expect(game.inspected.value, isNotNull);
      expect(game.inspected.value!.kind, InspectedKind.unit);
      expect(game.inspected.value!.owner, game.aiTeam);
      expect(game.inspected.value!.name, blueprint.name);
    });

    test('tapping a resource node shows its info with a description', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final node = ResourceNodeComponent(position: Vector2(400, 300));
      game.world.activeResourceNodes.add(node);
      await game.world.add(node);

      game.handleArenaTap(node.position);

      expect(game.inspected.value, isNotNull);
      expect(game.inspected.value!.kind, InspectedKind.resourceNode);
      expect(game.inspected.value!.owner, isNull);
      expect(game.inspected.value!.description, isNotNull);
    });
  });

  group('skirmish AI parity', () {
    test(
      'both sides start a skirmish with the scene-scoped starting gold',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        expect(game.gameState.gold, GameScenes.skirmishes.first.startingGold);
        expect(game.aiEconomy!.gold, GameScenes.skirmishes.first.startingGold);
      },
    );

    test('score-gated structures (Training Center, War Factory) are '
        'unlockable by both sides at zero score in skirmish - the score gate '
        'only applies to wave-defense', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      expect(
        game.gameState.currentScore,
        lessThan(GameConfig.trainingCenterUnlockScore),
      );
      expect(
        game.gameState.currentScore,
        lessThan(GameConfig.warFactoryUnlockScore),
      );

      expect(
        game.canBuildTower(BuildingType.trainingCenter, owner: aiTeam),
        isTrue,
      );
      expect(
        game.canBuildTower(BuildingType.warFactory, owner: aiTeam),
        isTrue,
      );

      // Skirmish has no wave progression to gate on, so the human player
      // isn't score-gated there either, unlike in wave-defense (see the
      // dedicated wave-defense assertion below).
      expect(
        game.canBuildTower(BuildingType.trainingCenter, owner: game.playerTeam),
        isTrue,
      );
      expect(
        game.canBuildTower(BuildingType.warFactory, owner: game.playerTeam),
        isTrue,
      );

      final waveDefenseGame = await _bootGame(GameScenes.all.first);
      expect(
        waveDefenseGame.gameState.currentScore,
        lessThan(GameConfig.trainingCenterUnlockScore),
      );
      expect(
        waveDefenseGame.canBuildTower(BuildingType.trainingCenter),
        isFalse,
      );
    });

    test(
      'the AI is bound by the same per-type build limit and Tech Lab '
      'prerequisite as the player, independently of the player\'s own state',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        final base = game.world.aiHomeBase!;

        // Laser Lance is locked for the AI until its own Tech Lab is up -
        // the player never builds one in this test, proving the gate is
        // tracked per-team rather than shared/global.
        expect(game.canBuildTower(TowerType.laser, owner: aiTeam), isFalse);

        Point<int>? cellFor(Vector2 origin, int ring) {
          final grid = game.terrainMap.grid;
          final baseCell = grid.worldToCell(origin);
          for (var dx = -ring; dx <= ring; dx++) {
            for (var dy = -ring; dy <= ring; dy++) {
              final cell = Point(baseCell.x + dx, baseCell.y + dy);
              if (!grid.inBounds(cell.x, cell.y)) continue;
              if (grid.isBlocked(cell.x, cell.y)) continue;
              return cell;
            }
          }
          return null;
        }

        final firstCell = cellFor(base.position, 2)!;
        // Tech Lab itself now requires a Power Plant first.
        final powerPlantCell = cellFor(base.position, 1)!;
        final powerPlantBuilt = game.buildStructure(
          aiTeam,
          BuildingType.powerPlant,
          game.terrainMap.grid.cellCenter(powerPlantCell),
        );
        expect(powerPlantBuilt, isNotNull);

        final built = game.buildStructure(
          aiTeam,
          BuildingType.techLab,
          game.terrainMap.grid.cellCenter(firstCell),
        );
        expect(built, isNotNull);
        expect(game.towerCountFor(BuildingType.techLab, owner: aiTeam), 1);
        expect(game.canBuildTower(TowerType.laser, owner: aiTeam), isTrue);

        // A second Tech Lab is refused - same "max 1 built" cap the player
        // is bound by.
        final secondCell = cellFor(base.position, 3)!;
        final secondBuild = game.buildStructure(
          aiTeam,
          BuildingType.techLab,
          game.terrainMap.grid.cellCenter(secondCell),
        );
        expect(secondBuild, isNull);
        expect(game.towerCountFor(BuildingType.techLab, owner: aiTeam), 1);

        // The player's own prerequisite state is unaffected by the AI's.
        expect(
          game.canBuildTower(TowerType.laser, owner: game.playerTeam),
          isFalse,
        );
      },
    );

    test('buildStructure spends from the given owner\'s own wallet', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final base = game.world.aiHomeBase!;
      final playerGoldBefore = game.gameState.gold;
      final aiGoldBefore = game.aiEconomy!.gold;
      final grid = game.terrainMap.grid;
      final baseCell = grid.worldToCell(base.position);
      final cell = Point(baseCell.x + 2, baseCell.y);

      final built = game.buildStructure(
        aiTeam,
        TowerType.machineGun,
        grid.cellCenter(cell),
      );

      expect(built, isNotNull);
      expect(game.aiEconomy!.gold, lessThan(aiGoldBefore));
      expect(game.gameState.gold, playerGoldBefore);
    });

    test(
      'killing a player-built skirmish unit pays the AI, and vice versa',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Soldier',
          maxHealth: 10,
          speed: 0,
          bounty: 25,
          size: 34,
        );

        final aiGoldBefore = game.aiEconomy!.gold;
        final playerUnit = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.assaultBase,
        );
        game.world.spawnUnit(playerUnit);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        playerUnit.takeDamage(blueprint.maxHealth.toDouble());
        expect(game.aiEconomy!.gold, aiGoldBefore + blueprint.bounty);

        final playerGoldBefore = game.gameState.gold;
        final aiUnit = MobileUnitComponent(
          blueprint: blueprint,
          team: aiTeam,
          objective: UnitObjective.assaultBase,
        );
        game.world.spawnUnit(aiUnit);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        aiUnit.takeDamage(blueprint.maxHealth.toDouble());
        expect(game.gameState.gold, greaterThan(playerGoldBefore));
      },
    );

    test('every buildable-roster unit kind pays a non-zero kill bounty '
        '(regression: skirmish kills used to pay 0 gold either way)', () {
      final repository = MobileUnitRepositoryImpl();
      for (final kind in [
        UnitKind.soldier,
        UnitKind.tank,
        UnitKind.lightVehicle,
        UnitKind.aircraft,
        UnitKind.rocketBarrage,
      ]) {
        final blueprint = repository.blueprintFor(Team.defaultPlayer, kind);
        expect(
          blueprint.bounty,
          greaterThan(0),
          reason: '$kind must pay a kill bounty in skirmish',
        );
      }
    });

    test(
      'the AI actually mans its production buildings instead of endlessly '
      'rebuilding more of them (regression: Training Center/War Factory '
      'have no game-wide build cap, so the AI used to always pick "build '
      'another one" and never reach the code path that produces units)',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        game.aiEconomy!.addGold(20000);

        // Long enough for the AI to work through its whole infrastructure
        // build order (Gold Mine, 2x Training Center, 2x War Factory, Tech
        // Lab, Command Post) *and* fill its baseline defense-tower
        // garrison before it ever stops building and starts producing -
        // crosses the ~14s directive-refresh tick, but that's a harmless
        // fire-and-forget network attempt (connection refused locally
        // falls back instantly) rather than something this test needs to
        // avoid.
        for (var i = 0; i < 800; i++) {
          game.update(0.1);
        }

        final trainingCenters = game.world.activeTowers
            .whereType<TrainingCenterComponent>()
            .where((t) => t.owner.id == aiTeam.id);
        final warFactories = game.world.activeTowers
            .whereType<WarFactoryComponent>()
            .where((t) => t.owner.id == aiTeam.id);
        final productionCap =
            GameDifficulty.normal.skirmishAiProfile.maxProductionBuildings;
        expect(
          trainingCenters.length,
          lessThanOrEqualTo(productionCap),
          reason:
              'the AI should stop at its production-building target '
              'instead of endlessly re-building Training Centers',
        );
        expect(
          warFactories.length,
          lessThanOrEqualTo(productionCap),
          reason:
              'the AI should stop at its production-building target '
              'instead of endlessly re-building War Factories',
        );

        final aiUnits = game.world.activeUnits.where(
          (u) => u.team.id == aiTeam.id,
        );
        expect(
          aiUnits,
          isNotEmpty,
          reason:
              'with ample gold and enough decision ticks, a healthy AI must '
              'actually roll units out of its production buildings, not '
              'just keep building more of them',
        );
      },
    );

    test('the AI produces its first unit within a reasonable number of '
        'decision ticks using only its default starting gold, instead of '
        'spending everything on buildings first (regression: the AI used to '
        'burn through its whole wallet on infrastructure/towers before it '
        'could ever afford to produce anything)', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;

      for (var i = 0; i < 300; i++) {
        game.update(0.1);
      }

      final hasProduction = game.world.activeTowers.any(
        (t) =>
            t.owner.id == aiTeam.id &&
            (t is TrainingCenterComponent || t is WarFactoryComponent),
      );
      expect(
        hasProduction,
        isTrue,
        reason:
            'the AI should have built its first production building '
            'within default starting gold and this many decision ticks',
      );
      expect(
        game.world.activeUnits.where((u) => u.team.id == aiTeam.id),
        isNotEmpty,
        reason:
            'the AI should have actually produced a unit by now instead '
            'of pouring every coin into more buildings',
      );
    });
  });

  group('combat damage fixes', () {
    test(
      'enemy vehicle splash damage also hits nearby ally units, not just '
      'towers/base (regression: cannon/rocket hits used to skip mobile '
      'units entirely whenever the firer was hostile to the player)',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const stationaryAlly = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 1000,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: stationaryAlly,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(400, 300);

        const stationaryTank = MobileUnitBlueprint(
          kind: UnitKind.tank,
          name: 'Test Enemy Tank',
          maxHealth: 500,
          speed: 0,
          bounty: 0,
          size: 50,
          attackDamage: 40,
          attackRange: 300,
          attackInterval: 0.3,
          isVehicle: true,
          weaponType: WeaponType.cannon,
        );
        final enemyTank = MobileUnitComponent(
          blueprint: stationaryTank,
          team: Team.invaders,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(enemyTank);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        enemyTank.position = Vector2(420, 300);

        for (var i = 0; i < 30; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }

        expect(ally.health, lessThan(ally.blueprint.maxHealth));
      },
    );
  });

  group('manual unit control', () {
    test(
      'tapping the player\'s own unit selects it for direct orders',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);
        expect(game.inspected.value, isNull);

        // Tapping it again deselects instead of re-selecting.
        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, isNull);
      },
    );

    test('selecting a tower type to build deselects the previously-selected '
        'unit', () async {
      final game = await _bootGame(GameScenes.all.first);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Ally',
        maxHealth: 40,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final ally = MobileUnitComponent(
        blueprint: blueprint,
        team: game.playerTeam,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(ally);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      ally.position = Vector2(300, 300);

      game.handleArenaTap(ally.position);
      expect(game.selectedUnit.value, ally);

      game.selectTowerType(TowerType.machineGun);
      expect(game.selectedUnit.value, isNull);
      expect(game.selectedTowerType.value, TowerType.machineGun);
    });

    test(
      'deselectAll clears unit/tower/build selections and inspect state',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);

        game.deselectAll();
        expect(game.selectedUnit.value, isNull);
        expect(game.selectedTower.value, isNull);
        expect(game.selectedTowerType.value, isNull);
        expect(game.inspected.value, isNull);
        expect(game.pendingPlacement.value, isNull);
      },
    );

    test('tapping open ground while a unit is selected issues a move order '
        'it walks to and then holds at', () async {
      final game = await _bootGame(GameScenes.all.first);
      final grid = game.terrainMap.grid;
      final cell = _findOpenCell(game);
      final cellCenter = grid.cellCenter(cell);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Ally',
        maxHealth: 40,
        speed: 80,
        bounty: 0,
        size: 34,
      );
      final ally = MobileUnitComponent(
        blueprint: blueprint,
        team: game.playerTeam,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(ally);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      ally.position = cellCenter.clone();

      game.handleArenaTap(ally.position);
      expect(game.selectedUnit.value, ally);

      // Offset just far enough to not land back on the unit itself, but
      // still well inside the same open cell.
      final orderPoint = cellCenter + Vector2(18, 0);
      game.handleArenaTap(orderPoint);
      expect(ally.underManualControl, isTrue);
      expect(ally.moveOrderTarget, isNotNull);

      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.1);
      }

      // Arrived and holding - not reverted to auto-hunting anywhere else.
      expect(ally.moveOrderTarget, isNull);
    });

    test(
      'after arriving at a move order, a fresh move order actually moves the '
      'unit again (regression: the stale exhausted path from the first '
      'order used to silently cancel the very next order before it could '
      'compute a new path, leaving the unit stuck forever)',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        final cell = _findOpenCell(game);
        final cellCenter = grid.cellCenter(cell);
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 80,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = cellCenter.clone();

        game.handleArenaTap(ally.position);
        final firstOrder = cellCenter + Vector2(18, 0);
        game.handleArenaTap(firstOrder);
        for (var i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.1);
        }
        expect(ally.moveOrderTarget, isNull); // arrived and holding

        final restingSpot = ally.position.clone();
        final secondOrder = cellCenter + Vector2(-18, 0);
        game.handleArenaTap(secondOrder);
        expect(ally.moveOrderTarget, isNotNull);

        for (var i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.1);
        }

        // Must have actually left where it was resting and reached the new
        // order point - not frozen in place.
        expect(ally.position.distanceTo(restingSpot), greaterThan(5));
        expect(ally.position.distanceTo(secondOrder), lessThan(5));
        expect(ally.moveOrderTarget, isNull);
      },
    );

    test('after destroying an attack-ordered target, the unit automatically '
        'presses on to the next hostile within its radius instead of '
        'freezing in place once it arrives', () async {
      final game = await _bootGame(GameScenes.all.first);
      const allyBlueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Ally',
        maxHealth: 40,
        speed: 80,
        bounty: 0,
        size: 34,
        attackDamage: 200,
        attackRange: 150,
        attackInterval: 0.1,
        weaponType: WeaponType.laser,
      );
      final ally = MobileUnitComponent(
        blueprint: allyBlueprint,
        team: game.playerTeam,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(ally);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      ally.position = Vector2(300, 300);

      const nearEnemyBlueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Enemy Near',
        maxHealth: 10,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final nearEnemy = MobileUnitComponent(
        blueprint: nearEnemyBlueprint,
        team: Team.invaders,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(nearEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      nearEnemy.position = Vector2(340, 300);

      const farEnemyBlueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Enemy Far',
        maxHealth: 200,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final farEnemy = MobileUnitComponent(
        blueprint: farEnemyBlueprint,
        team: Team.invaders,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(farEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      // Outside attack range (150) but well inside the auto-continue
      // radius (attackRange * 3 = 450), so the unit must walk toward it.
      // Kept far enough away (400) that, even after nearEnemy dies and
      // the ally spends the first assertion loop (10 * 0.2s = 2s)
      // closing the gap at its 80 units/s speed, it still can't have
      // covered enough ground to already be in range and one-shot it
      // before the first checkpoint below - it must still be alive and
      // merely "being hunted" at that point.
      farEnemy.position = Vector2(700, 300);

      game.handleArenaTap(ally.position);
      game.handleArenaTap(nearEnemy.position);
      expect(ally.forcedTarget, nearEnemy);

      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }

      expect(nearEnemy.destroyed, isTrue);
      expect(ally.forcedTarget, farEnemy);

      for (var i = 0; i < 30; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }

      expect(farEnemy.health, lessThan(farEnemy.blueprint.maxHealth));
    });

    test(
      'tapping an enemy while a unit is selected issues an attack order',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const allyBlueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
          attackDamage: 10,
          attackRange: 150,
          attackInterval: 0.2,
        );
        final ally = MobileUnitComponent(
          blueprint: allyBlueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        const enemyBlueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Enemy',
          maxHealth: 200,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final enemy = MobileUnitComponent(
          blueprint: enemyBlueprint,
          team: Team.invaders,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(enemy);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        enemy.position = Vector2(340, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);

        game.handleArenaTap(enemy.position);
        expect(ally.forcedTarget, enemy);

        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }

        expect(enemy.health, lessThan(enemy.blueprint.maxHealth));
      },
    );
  });

  group('tower targeting', () {
    const mgBlueprint = UnitBlueprint(
      type: TowerType.machineGun,
      name: 'Test MG',
      cost: 50,
      range: 300,
      damage: 10,
      fireRate: 0.2,
      maxHp: 100,
    );

    const enemyBlueprint = MobileUnitBlueprint(
      kind: UnitKind.soldier,
      name: 'Test Enemy',
      maxHealth: 200,
      speed: 0,
      bounty: 0,
      size: 34,
    );

    Future<MachineGunTowerComponent> spawnTower(
      BoomspireGame game,
      Vector2 position,
    ) async {
      final tower = MachineGunTowerComponent(
        position: position,
        cellSize: 40,
        blueprint: mgBlueprint,
      );
      game.world.spawnTower(tower);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      return tower;
    }

    Future<MobileUnitComponent> spawnEnemy(
      BoomspireGame game,
      Vector2 position, {
      double? maxHealth,
    }) async {
      final enemy = MobileUnitComponent(
        blueprint: maxHealth == null
            ? enemyBlueprint
            : MobileUnitBlueprint(
                kind: UnitKind.soldier,
                name: 'Test Enemy',
                maxHealth: maxHealth,
                speed: 0,
                bounty: 0,
                size: 34,
              ),
        team: Team.invaders,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(enemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      enemy.position = position;
      return enemy;
    }

    test('selecting a tower and tapping an enemy force-targets it even over '
        'a closer enemy', () async {
      final game = await _bootGame(GameScenes.all.first);
      final tower = await spawnTower(game, Vector2(200, 200));
      final nearEnemy = await spawnEnemy(game, Vector2(220, 200));
      final farEnemy = await spawnEnemy(game, Vector2(450, 200));

      game.handleArenaTap(tower.position);
      expect(game.selectedTower.value, tower);

      game.handleArenaTap(farEnemy.position);
      expect(tower.forcedTarget, farEnemy);

      game.update(0);
      expect(tower.currentTarget, farEnemy);
      expect(tower.currentTarget, isNot(nearEnemy));
    });

    test('no more than 3 towers focus-fire the same healthy enemy while a '
        'less-contested one is also in range', () async {
      final game = await _bootGame(GameScenes.all.first);
      final enemyA = await spawnEnemy(game, Vector2(450, 300));
      final enemyB = await spawnEnemy(game, Vector2(430, 300));

      // Towers are brought in one at a time (not all in the same frame)
      // so each one's join decision reflects an up-to-date targeter
      // count instead of every tower deciding off the same stale zero.
      final towers = <MachineGunTowerComponent>[];
      for (var i = 0; i < 4; i++) {
        final tower = await spawnTower(game, Vector2(200.0 + i * 5, 300));
        game.update(0.05);
        towers.add(tower);
      }

      final onEnemyA = towers.where((t) => t.currentTarget == enemyA);
      final onEnemyB = towers.where((t) => t.currentTarget == enemyB);
      expect(onEnemyA.length, lessThanOrEqualTo(3));
      // The 4th tower had nowhere less-contested to go on enemyA, so it
      // picked the other enemy instead of piling on regardless.
      expect(onEnemyB, isNotEmpty);
    });

    test('a near-dead target already being finished off by a fast tower is '
        'left alone by a much slower one, which retargets instead', () async {
      final game = await _bootGame(GameScenes.all.first);
      final fastKiller = MachineGunTowerComponent(
        position: Vector2(200, 300),
        cellSize: 40,
        blueprint: const UnitBlueprint(
          type: TowerType.machineGun,
          name: 'Fast Killer',
          cost: 50,
          range: 300,
          damage: 200,
          fireRate: 0.2,
          maxHp: 100,
        ),
      );
      game.world.spawnTower(fastKiller);
      final slowPoker = MachineGunTowerComponent(
        position: Vector2(220, 300),
        cellSize: 40,
        blueprint: const UnitBlueprint(
          type: TowerType.machineGun,
          name: 'Slow Poker',
          cost: 50,
          range: 300,
          damage: 1,
          fireRate: 0.2,
          maxHp: 100,
        ),
      );
      game.world.spawnTower(slowPoker);
      await Future<void>.delayed(Duration.zero);
      game.update(0);

      final nearDeathEnemy = await spawnEnemy(
        game,
        Vector2(450, 300),
        maxHealth: 1000,
      );
      final healthyEnemy = await spawnEnemy(game, Vector2(450, 330));

      // Both towers commit to the same (currently healthy) target first.
      game.update(0.05);
      fastKiller.currentTarget = nearDeathEnemy;
      slowPoker.currentTarget = nearDeathEnemy;

      // It then takes heavy damage and drops well under the near-death
      // threshold - `fastKiller` can one-shot what's left, `slowPoker`
      // very much can't.
      nearDeathEnemy.health = 10;
      game.update(0.05);

      expect(fastKiller.currentTarget, nearDeathEnemy);
      expect(slowPoker.currentTarget, healthyEnemy);
    });

    test('towers can target and damage an enemy tower/building, not just '
        'mobile units', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;

      final playerTower = await spawnTower(game, Vector2(200, 200));
      final enemyTower = MachineGunTowerComponent(
        position: Vector2(220, 200),
        cellSize: 40,
        blueprint: mgBlueprint,
      )..owner = aiTeam;
      game.world.spawnTower(enemyTower);
      await Future<void>.delayed(Duration.zero);
      game.update(0);

      // Force-target the enemy tower directly, same as tapping it while
      // the player's own tower is selected (see `handleArenaTap`).
      playerTower.issueAttackOrder(enemyTower);
      final startingHealth = enemyTower.health;

      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.25);
      }

      expect(playerTower.currentTarget, enemyTower);
      expect(enemyTower.health, lessThan(startingHealth));
    });
  });

  group('skirmish AI', () {
    MobileUnitComponent spawnSoldier(
      BoomspireGame game,
      Team team,
      Vector2 at,
    ) {
      final blueprint = game.unitRepository.blueprintFor(
        team,
        UnitKind.soldier,
      );
      final unit = MobileUnitComponent(
        blueprint: blueprint,
        team: team,
        objective: UnitObjective.assaultBase,
        position: at,
      );
      game.world.spawnUnit(unit);
      return unit;
    }

    MobileUnitComponent spawnPlane(BoomspireGame game, Team team, Vector2 at) {
      final unit = MobileUnitComponent(
        blueprint: game.unitRepository.blueprintFor(team, UnitKind.aircraft),
        team: team,
        objective: UnitObjective.assaultBase,
        position: at,
      );
      game.world.spawnUnit(unit);
      return unit;
    }

    Future<void> settle(BoomspireGame game) async {
      await Future<void>.delayed(Duration.zero);
      game.update(0);
    }

    test('difficulty scales reaction speed, income and aggression', () {
      final easy = GameDifficulty.easy.skirmishAiProfile;
      final normal = GameDifficulty.normal.skirmishAiProfile;
      final hard = GameDifficulty.hard.skirmishAiProfile;
      expect(hard.decisionInterval, lessThan(normal.decisionInterval));
      expect(normal.decisionInterval, lessThan(easy.decisionInterval));
      expect(hard.incomeMultiplier, greaterThan(normal.incomeMultiplier));
      expect(easy.incomeMultiplier, lessThan(normal.incomeMultiplier));
      expect(hard.attackPowerRatio, lessThan(easy.attackPowerRatio));
      expect(hard.mistakeChance, lessThan(easy.mistakeChance));
    });

    test('army power grows with headcount, and an empty army has none', () {
      const one = ArmyStrength(health: 100, dps: 10);
      expect(ArmyStrength.zero.power, 0);
      expect((one + one).power, closeTo(one.power * 2, 1e-9));
    });

    test('AI income follows the difficulty multiplier', () async {
      final hard = await _bootGame(
        GameScenes.skirmishes.first,
        difficulty: GameDifficulty.hard,
      );
      final before = hard.aiEconomy!.gold;
      hard.aiEconomy!.addGold(100);
      expect(hard.aiEconomy!.gold - before, 125);
    });

    test('the strike planner hits a lightly guarded gold mine, not the '
        'fortified base', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final grid = game.terrainMap.grid;
      final base = Vector2(
        game.terrainMap.basePoint.x,
        game.terrainMap.basePoint.y,
      );
      final baseCell = grid.worldToCell(base);
      var towers = 0;
      for (var dx = -3; dx <= 3 && towers < 5; dx++) {
        final cell = Point(baseCell.x + dx, baseCell.y - 3);
        if (grid.isBlocked(cell.x, cell.y)) continue;
        if (game.buildStructure(
              game.playerTeam,
              TowerType.machineGun,
              grid.cellCenter(cell),
            ) !=
            null) {
          towers++;
        }
      }
      expect(towers, greaterThan(0));
      final aiBase = game.world.aiHomeBase!.position;
      final mineCell = grid.worldToCell(aiBase + (base - aiBase) * 0.5);
      final mine = game.buildStructure(
        game.playerTeam,
        BuildingType.goldMine,
        grid.cellCenter(mineCell),
      );
      expect(mine, isNotNull);
      await settle(game);

      final plan = StrikePlanner(game).plan(
        aiTeam: aiTeam,
        armyCenter: aiBase,
        armyPower: 60,
        allowRaid: false,
        raidPower: 0,
      );
      expect(plan.main.kind, StrikeTargetKind.economy);
    });

    test(
      'the AI builds several War Factories once it can afford them',
      () async {
        final game = await _bootGame(
          GameScenes.skirmishes.first,
          difficulty: GameDifficulty.hard,
        );
        final aiTeam = game.aiTeam!;
        game.aiEconomy!.addGold(20000);
        final planner = SkirmishBuildPlanner(
          game,
          GameDifficulty.hard.skirmishAiProfile,
        );
        const directive = SkirmishDirective(aggression: 0.5, buildBias: 0.5);
        for (var i = 0; i < 40; i++) {
          planner.tryBuild(aiTeam, directive);
          await settle(game);
        }
        final factories = game.world.activeTowers
            .where(
              (t) =>
                  t.owner.id == aiTeam.id &&
                  t.blueprint.type == BuildingType.warFactory,
            )
            .length;
        expect(factories, greaterThan(1));
      },
    );

    test('the AI spots a missing anti-air defense and reacts to one being '
        'built', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final analyzer = PlayerWeaknessAnalyzer(game);
      expect(analyzer.analyze(aiTeam).lacksAntiAir, isTrue);

      final grid = game.terrainMap.grid;
      final cell = _findOpenCell(game);
      final tower = game.buildStructure(
        game.playerTeam,
        TowerType.antiAir,
        grid.cellCenter(cell),
      );
      expect(tower, isNotNull);
      await settle(game);
      expect(analyzer.analyze(aiTeam).lacksAntiAir, isFalse);
    });

    test('the AI only banks gold for a building for a limited time', () async {
      final game = await _bootGame(
        GameScenes.skirmishes.first,
        difficulty: GameDifficulty.hard,
      );
      final aiTeam = game.aiTeam!;
      game.aiEconomy!.addGold(20000);
      final planner = SkirmishBuildPlanner(
        game,
        GameDifficulty.hard.skirmishAiProfile,
      );
      const directive = SkirmishDirective(aggression: 0.5, buildBias: 0.5);
      // Reach the state where it has production but still wants more.
      for (var i = 0; i < 6; i++) {
        planner.tryBuild(aiTeam, directive);
        await settle(game);
      }
      game.aiEconomy!.gold = 100;

      expect(planner.savingsTarget(aiTeam, 0), greaterThan(0));
      expect(planner.savingsTarget(aiTeam, 25), 0, reason: 'time-boxed');
      expect(planner.savingsTarget(aiTeam, 45), greaterThan(0));
    });

    test(
      'even on Easy the AI answers enemy aircraft with anti-air towers',
      () async {
        final game = await _bootGame(
          GameScenes.skirmishes.first,
          difficulty: GameDifficulty.easy,
        );
        final aiTeam = game.aiTeam!;
        for (var i = 0; i < 3; i++) {
          spawnPlane(game, game.playerTeam, Vector2(900 + i * 20, 100));
        }
        await settle(game);
        game.aiEconomy!.addGold(20000);

        final planner = SkirmishBuildPlanner(
          game,
          GameDifficulty.easy.skirmishAiProfile,
        );
        const directive = SkirmishDirective(aggression: 0.5, buildBias: 0.5);
        for (var i = 0; i < 30; i++) {
          planner.tryBuild(aiTeam, directive);
          await settle(game);
        }

        expect(
          AiBaseQueries(game).ownedAntiAirTowerCount(aiTeam),
          greaterThan(0),
        );
        expect(AiBaseQueries(game).desiredAntiAirTowers(aiTeam), 2);
      },
    );

    test('ground anti-air units stay home as guards while the opponent has '
        'aircraft instead of marching off with the assault', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final base = game.world.aiHomeBase!.position;
      final aaBlueprint = game.unitRepository.blueprintFor(
        aiTeam,
        UnitKind.antiAirSoldier,
      );
      final guard = MobileUnitComponent(
        blueprint: aaBlueprint,
        team: aiTeam,
        objective: UnitObjective.assaultBase,
        position: base.clone(),
      );
      game.world.spawnUnit(guard);
      final others = [
        for (var i = 0; i < 8; i++) spawnSoldier(game, aiTeam, base.clone()),
      ];
      // A player aircraft out near the player's own base: seen, but no threat
      // to the AI base itself.
      spawnPlane(
        game,
        game.playerTeam,
        Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
      );
      await settle(game);

      final commander = ArmyCommander(
        game,
        GameDifficulty.normal.skirmishAiProfile,
      );
      commander.command(aiTeam, 0.5);

      expect(commander.stance, ArmyStance.attack);
      expect(others.every((u) => !u.underManualControl), isTrue);
      expect(guard.underManualControl, isTrue, reason: 'guard held back');
    });

    test(
      'the AI works through the whole prerequisite chain to build a SAM '
      'Site against aircraft (Power Plant, Tech Lab, Command Post, SAM)',
      () async {
        final game = await _bootGame(
          GameScenes.skirmishes.first,
          difficulty: GameDifficulty.normal,
        );
        final aiTeam = game.aiTeam!;
        for (var i = 0; i < 3; i++) {
          spawnPlane(game, game.playerTeam, Vector2(900 + i * 20, 100));
        }
        await settle(game);
        game.aiEconomy!.addGold(40000);

        final planner = SkirmishBuildPlanner(
          game,
          GameDifficulty.normal.skirmishAiProfile,
        );
        const directive = SkirmishDirective(aggression: 0.5, buildBias: 0.5);
        for (var i = 0; i < 80; i++) {
          planner.tryBuild(aiTeam, directive);
          await settle(game);
        }

        final queries = AiBaseQueries(game);
        for (final building in [
          BuildingType.powerPlant,
          BuildingType.techLab,
          BuildingType.commandPost,
        ]) {
          expect(
            queries.ownedCountOf(aiTeam, building),
            1,
            reason: '$building',
          );
        }
        expect(queries.ownedCountOf(aiTeam, TowerType.sam), greaterThan(0));
      },
    );

    test(
      'a small AI army musters at the rally point instead of rushing',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        final base = game.world.aiHomeBase!.position;
        final units = [
          for (var i = 0; i < 2; i++) spawnSoldier(game, aiTeam, base.clone()),
        ];
        await settle(game);

        final commander = ArmyCommander(
          game,
          GameDifficulty.normal.skirmishAiProfile,
        );
        commander.command(aiTeam, 0.5);

        expect(commander.stance, ArmyStance.muster);
        expect(units.every((u) => u.underManualControl), isTrue);
        expect(units.every((u) => u.moveOrderTarget != null), isTrue);
      },
    );

    test('a large AI army is released to attack together', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final base = game.world.aiHomeBase!.position;
      final units = [
        for (var i = 0; i < 8; i++) spawnSoldier(game, aiTeam, base.clone()),
      ];
      await settle(game);

      final commander = ArmyCommander(
        game,
        GameDifficulty.normal.skirmishAiProfile,
      );
      commander.command(aiTeam, 0.5); // no enemy forces: strong enough
      expect(commander.stance, ArmyStance.attack);
      expect(units.every((u) => !u.underManualControl), isTrue);
    });

    test('units attacking the AI base pull the army back to defend', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final base = game.world.aiHomeBase!.position;
      final defenders = [
        for (var i = 0; i < 4; i++) spawnSoldier(game, aiTeam, base.clone()),
      ];
      final raider = spawnSoldier(
        game,
        game.playerTeam,
        base + Vector2(120, 0),
      );
      await settle(game);

      final commander = ArmyCommander(
        game,
        GameDifficulty.normal.skirmishAiProfile,
      );
      commander.command(aiTeam, 0.5);

      expect(commander.stance, ArmyStance.defend);
      for (final defender in defenders) {
        expect(
          defender.moveOrderTarget!.distanceTo(raider.position),
          lessThan(1),
        );
      }
    });

    test(
      'the AI opponent builds an economy and fields units on its own',
      () async {
        final game = await _bootGame(
          GameScenes.skirmishes.first,
          difficulty: GameDifficulty.hard,
        );
        final aiTeam = game.aiTeam!;
        for (var i = 0; i < 400; i++) {
          game.update(0.5);
          await Future<void>.delayed(Duration.zero);
        }
        final structures = game.world.activeTowers
            .where((t) => t.owner.id == aiTeam.id)
            .toList();
        final units = game.world.activeUnits.where(
          (u) => u.team.id == aiTeam.id,
        );
        expect(
          structures.any((t) => t.blueprint.type == BuildingType.goldMine),
          isTrue,
        );
        expect(
          structures.any(
            (t) => t is TrainingCenterComponent || t is WarFactoryComponent,
          ),
          isTrue,
        );
        expect(units, isNotEmpty);
      },
    );
  });

  group('aircraft', () {
    test(
      'an attack plane ordered onto a ground unit flies passes over it and '
      'loops back instead of hovering/jittering on top of it (regression)',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final target = MobileUnitComponent(
          blueprint: const MobileUnitBlueprint(
            kind: UnitKind.soldier,
            name: 'Dummy',
            maxHealth: 100000,
            speed: 0,
            size: 30,
          ),
          team: game.aiTeam!,
          objective: UnitObjective.assaultBase,
          position: Vector2(600, 400),
        );
        game.world.spawnUnit(target);
        final plane = MobileUnitComponent(
          blueprint: game.unitRepository.blueprintFor(
            game.playerTeam,
            UnitKind.aircraft,
          ),
          team: game.playerTeam,
          objective: UnitObjective.assaultBase,
          position: Vector2(300, 400),
        );
        game.world.spawnUnit(plane);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        plane.issueMoveOrder(target.position.clone());

        var farthest = 0.0;
        var closeFrames = 0;
        const frames = 900;
        for (var i = 0; i < frames; i++) {
          game.update(1 / 30);
          final d = plane.position.distanceTo(target.position);
          if (i > 90) {
            if (d > farthest) farthest = d;
            if (d < 15) closeFrames++;
          }
        }

        expect(
          farthest,
          greaterThan(150),
          reason: 'the plane must loop out between attack passes',
        );
        expect(
          closeFrames,
          lessThan(frames ~/ 4),
          reason: 'the plane must not sit on top of its target',
        );
        expect(target.health, lessThan(100000));
      },
    );
  });

  group('birds', () {
    GameScene birdyScene(double rain) => GameScene(
      id: 'birdy',
      name: 'Birdy',
      briefing: '',
      biome: GameScenes.all.first.biome,
      waveCount: 3,
      environment: EnvironmentSettings(
        timeline: [
          WeatherKeyframe(atProgress: 0, birdActivity: 1, rainIntensity: rain),
        ],
      ),
    );

    Future<int> flocksAfter(GameScene scene) async {
      final game = await _bootGame(scene);
      final birds = game.world.children.whereType<BirdFlockComponent>().single;
      var peak = 0;
      for (var i = 0; i < 1200; i++) {
        game.update(0.1);
        if (birds.flockCount > peak) peak = birds.flockCount;
      }
      return peak;
    }

    test('a bird-friendly sky sends flocks across the map', () async {
      expect(await flocksAfter(birdyScene(0)), greaterThan(0));
    });

    test('no flocks in heavy rain', () async {
      expect(await flocksAfter(birdyScene(1)), 0);
    });
  });

  group('helicopter', () {
    const dummyHealth = 1e7;

    Future<void> settle(BoomspireGame game) async {
      await Future<void>.delayed(Duration.zero);
      game.update(0);
    }

    MobileUnitComponent spawnDummy(
      BoomspireGame game,
      Vector2 at, {
      required UnitDomain domain,
    }) {
      final unit = MobileUnitComponent(
        blueprint: MobileUnitBlueprint(
          kind: domain == UnitDomain.air
              ? UnitKind.helicopter
              : UnitKind.soldier,
          name: 'Dummy',
          maxHealth: dummyHealth,
          speed: 0,
          size: 30,
          domain: domain,
        ),
        team: game.aiTeam!,
        objective: UnitObjective.assaultBase,
        position: at,
      );
      game.world.spawnUnit(unit);
      return unit;
    }

    Future<MobileUnitComponent> spawnHeli(
      BoomspireGame game,
      Vector2 at,
    ) async {
      final heli = MobileUnitComponent(
        blueprint: game.unitRepository.blueprintFor(
          game.playerTeam,
          UnitKind.helicopter,
        ),
        team: game.playerTeam,
        objective: UnitObjective.assaultBase,
        position: at,
      );
      game.world.spawnUnit(heli);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      heli.issueMoveOrder(at.clone()); // hold here
      return heli;
    }

    /// Runs [seconds] and reports whether a gun bullet / a rocket was ever in
    /// flight.
    Future<({bool bullets, bool rockets})> fireFor(
      BoomspireGame game,
      double seconds,
    ) async {
      var bullets = false;
      var rockets = false;
      for (var t = 0.0; t < seconds; t += 0.05) {
        game.update(0.05);
        // Let freshly spawned projectiles finish mounting.
        await Future<void>.delayed(Duration.zero);
        final children = game.world.children;
        bullets |= children.whereType<BulletComponent>().isNotEmpty;
        rockets |= children.whereType<RocketComponent>().isNotEmpty;
      }
      return (bullets: bullets, rockets: rockets);
    }

    test('fires its gun AND its rockets at a ground target', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      await spawnHeli(game, Vector2(600, 400));
      spawnDummy(game, Vector2(600, 260), domain: UnitDomain.ground);
      await settle(game);

      final fired = await fireFor(game, 8);
      expect(fired.bullets, isTrue, reason: 'primary gun');
      expect(fired.rockets, isTrue, reason: 'secondary rockets');
    });

    test('its ground-only rockets stay holstered against an aircraft; the '
        'gun still fires', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      await spawnHeli(game, Vector2(600, 400));
      spawnDummy(game, Vector2(600, 260), domain: UnitDomain.air);
      await settle(game);

      final fired = await fireFor(game, 8);
      expect(fired.bullets, isTrue);
      expect(fired.rockets, isFalse);
    });

    test(
      'it has to turn its nose toward a target behind it before firing',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        await spawnHeli(game, Vector2(600, 300));
        // Directly south; the helicopter starts nose-up (north).
        spawnDummy(game, Vector2(600, 450), domain: UnitDomain.ground);
        await settle(game);

        final early = await fireFor(game, 0.3);
        expect(
          early.bullets || early.rockets,
          isFalse,
          reason: 'still turning',
        );
        final later = await fireFor(game, 6);
        expect(later.bullets, isTrue, reason: 'fires once facing the target');
      },
    );

    test('the unit card counts both weapons in its power', () {
      final blueprint = MobileUnitRepositoryImpl().blueprintFor(
        Team.defaultPlayer,
        UnitKind.helicopter,
      );
      final primary = blueprint.attackDamage / blueprint.attackInterval;
      expect(blueprint.secondary, isNotNull);
      expect(UnitCardInfo.fromBlueprint(blueprint).power, greaterThan(primary));
    });
  });

  group('map draft to match', () {
    test('the draft\'s starting gold goes to the player AND the AI, and its '
        'weather comes along', () async {
      const environment = EnvironmentSettings(
        timeline: [
          WeatherKeyframe(atProgress: 0, rainIntensity: 0.8),
          WeatherKeyframe(atProgress: 1, snowIntensity: 0.6),
        ],
      );
      final draft = MapDraft(
        id: 'gold',
        name: 'Gold',
        mode: GameMode.skirmish,
        startingGold: 421,
        environment: environment,
      );
      final scene = const MapDraftSceneFactory().sceneFor(
        draft,
        mode: GameMode.skirmish,
        briefing: 'test',
      );
      expect(scene.environment, environment);
      expect(scene.startingGold, 421);

      final game = await _bootGame(scene);
      expect(game.gameState.gold, 421, reason: 'the human player');
      expect(game.aiEconomy!.gold, 421, reason: 'the AI opponent');
      expect(game.scene.environment.timeline, hasLength(2));
    });

    test('tower defense drafts use the same factory and gold', () {
      final draft = MapDraft(id: 'td', name: 'TD', startingGold: 650);
      final scene = const MapDraftSceneFactory().sceneFor(
        draft,
        mode: GameMode.waveDefense,
        briefing: 'test',
      );
      expect(scene.startingGold, 650);
      expect(scene.waveCount, draft.waveCount);
    });

    test('picking a different home keeps the built-in map\'s weather and '
        'gold', () {
      final base = GameScenes.skirmishes.first;
      final swapped = base.withHomeSites(base.homeSites.reversed.toList());
      expect(swapped.environment, base.environment);
      expect(swapped.startingGold, base.startingGold);
      expect(swapped.resourceNodeSites, base.resourceNodeSites);
    });
  });

  test('every scene generates a terrain where every spawn can reach base', () {
    for (final scene in GameScenes.all) {
      final terrain = TerrainRepositoryImpl().loadTerrain(scene: scene);
      final grid = terrain.grid;
      final baseCell = grid.worldToCell(
        Vector2(terrain.basePoint.x, terrain.basePoint.y),
      );
      for (final spawnPoint in terrain.spawnPoints) {
        final spawnCell = grid.worldToCell(Vector2(spawnPoint.x, spawnPoint.y));
        expect(
          grid.isReachable(spawnCell, baseCell),
          isTrue,
          reason:
              '${scene.id} terrain must not fully wall off a spawn from base',
        );
      }
    }
  });
}

/// Boots a game without pumping a full Flutter widget tree (much faster).
Future<BoomspireGame> _bootGame(
  GameScene scene, {
  GameDifficulty difficulty = GameDifficulty.normal,
}) async {
  final game = _newGame(scene, difficulty: difficulty);
  game.onGameResize(Vector2(1280, 720));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Finds an open, buildable cell (not blocked, not spawn/base) so tests
/// don't depend on any particular random terrain layout.
Point<int> _findOpenCell(BoomspireGame game) {
  final grid = game.terrainMap.grid;
  final spawnCells = game.terrainMap.spawnPoints
      .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
      .toSet();
  final baseCell = grid.worldToCell(
    Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
  );
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      final cell = Point(col, row);
      if (!grid.isBlocked(col, row) &&
          !spawnCells.contains(cell) &&
          cell != baseCell) {
        return cell;
      }
    }
  }
  throw StateError('no open cell found');
}

BoomspireGame _newGame(
  GameScene scene, {
  GameDifficulty difficulty = GameDifficulty.normal,
}) => BoomspireGame(
  difficulty: difficulty,
  terrainRepository: TerrainRepositoryImpl(),
  towerRepository: TowerRepositoryImpl(),
  buildingRepository: BuildingRepositoryImpl(),
  unitRepository: MobileUnitRepositoryImpl(),
  waveRepository: WaveRepositoryImpl(
    totalWaves: scene.waveCount,
    biome: scene.biome,
  ),
  audioRepository: _FakeAudioRepository(),
  gameState: GameStateRepositoryImpl(),
  aiDirector: AiDirectorRepositoryImpl(),
  unitRenderRepository: ProceduralUnitRenderRepositoryImpl(),
  scene: scene,
);

/// No-op audio - the real impl needs real audio plugins that aren't
/// available under `flutter test`.
class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1}) {}

  @override
  Future<void> preload() async {}

  @override
  void updateAmbience(AmbientEnvironment environment, double dt) {}
}
