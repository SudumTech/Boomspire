import '../enums/army_stance.dart';

/// A read-only snapshot of what the skirmish AI is currently doing - shown
/// in the debug HUD so a tester can watch its reasoning during a match.
class AiIntel {
  final ArmyStance stance;
  final String targetLabel;
  final String raidLabel;
  final int armySize;
  final double armyPower;
  final double enemyPower;
  final int structures;
  final int gold;
  final int ownedNodes;

  /// Label of the air wing's target, or '-' when no air strike is out.
  final String airTargetLabel;

  /// Whether the AI has spotted that the opponent has no anti-air.
  final bool spotsNoAntiAir;

  const AiIntel({
    required this.stance,
    required this.targetLabel,
    required this.raidLabel,
    required this.armySize,
    required this.armyPower,
    required this.enemyPower,
    required this.structures,
    required this.gold,
    required this.ownedNodes,
    required this.airTargetLabel,
    required this.spotsNoAntiAir,
  });
}
