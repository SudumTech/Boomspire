import 'dart:math';

import '../../../core/combat/team.dart';
import '../../../core/combat/unit_objective.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../game_core/presentation/resource_node_component.dart';
import '../../towers/presentation/war_factory_component.dart';
import 'ai_base_queries.dart';

/// Sends one idle War Factory vehicle at a time to claim the resource node
/// nearest the AI's base that it does not already own and is not already
/// sending someone to.
class SkirmishNodePlanner {
  final BoomspireGame _game;
  final AiBaseQueries _queries;
  final Random _random;

  SkirmishNodePlanner(this._game, {Random? random})
    : _queries = AiBaseQueries(_game),
      _random = random ?? Random();

  void dispatchCapturer(Team aiTeam) {
    final base = _game.world.aiHomeBase;
    if (base == null || !base.isMounted) return;

    final targets = _unclaimedNodes(aiTeam)
      ..sort(
        (a, b) => a.position
            .distanceTo(base.position)
            .compareTo(b.position.distanceTo(base.position)),
      );
    for (final node in targets) {
      if (_alreadyBeingClaimed(aiTeam, node)) continue;
      if (_sendVehicleTo(aiTeam, node)) return;
    }
  }

  List<ResourceNodeComponent> _unclaimedNodes(Team aiTeam) => _game
      .world
      .activeResourceNodes
      .where((n) => n.owner?.id != aiTeam.id)
      .toList();

  bool _alreadyBeingClaimed(Team aiTeam, ResourceNodeComponent node) =>
      _game.world.activeUnits.any(
        (u) =>
            !u.destroyed &&
            u.team.id == aiTeam.id &&
            u.objective == UnitObjective.captureNode &&
            u.captureTarget == node.position,
      );

  bool _sendVehicleTo(Team aiTeam, ResourceNodeComponent node) {
    final vehicles = _game.unitRepository.kindsFor(aiTeam).where((kind) {
      final blueprint = _game.unitRepository.blueprintFor(aiTeam, kind);
      return blueprint.isVehicle && blueprint.cost <= _game.goldFor(aiTeam);
    }).toList();
    if (vehicles.isEmpty) return false;

    for (final factory in _queries.ownedStructures(aiTeam)) {
      if (factory is! WarFactoryComponent || !factory.canProduce) continue;
      final produced = factory.produceUnit(
        vehicles[_random.nextInt(vehicles.length)],
        objective: UnitObjective.captureNode,
        captureTarget: node.position.clone(),
      );
      if (produced) return true;
    }
    return false;
  }
}
