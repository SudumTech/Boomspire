/// Every knob that makes the skirmish AI easier or harder - one immutable
/// bundle per `GameDifficulty` (see `GameDifficultyAiExtensions`), so no
/// planner ever branches on the difficulty enum itself.
class SkirmishAiProfile {
  /// Seconds between two AI decision rounds (build/produce/command) - a
  /// slower brain reacts later to everything.
  final double decisionInterval;

  /// Chance (0..1) that a decision round is wasted on a "distracted" skip.
  final double mistakeChance;

  /// The army launches an attack once its power is at least this multiple
  /// of everything it would have to fight (units + defense towers).
  final double attackPowerRatio;

  /// An attack in progress falls back to the rally point once the army's
  /// power drops under this multiple of what it is fighting.
  final double retreatPowerRatio;

  /// Fewest units that may launch an attack.
  final int minAttackers;

  /// Army size that triggers an attack regardless of the power comparison,
  /// so a turtling player cannot stall the match forever.
  final int forceAttackArmySize;

  /// Multiplier on every gold payout the AI receives (kill bounties, node
  /// income). 1.0 is exactly what the human player earns.
  final double incomeMultiplier;

  /// How many Training Centers / War Factories (each) it will build.
  final int maxProductionBuildings;

  /// Combat towers kept around its own base even in peacetime.
  final int baseDefenseTowers;

  /// Whether it recalls the army to repel units attacking its base.
  final bool defendsWithArmy;

  /// Whether it picks units that counter the player's current army.
  final bool countersPlayerArmy;

  /// Whether it spends spare gold upgrading its structures.
  final bool upgradesStructures;

  /// Whether it sends vehicles to claim resource nodes.
  final bool capturesNodes;

  /// Whether it fortifies its resource nodes with defense towers.
  final bool fortifiesNodes;

  /// Whether a big army splits off a fast squad to raid weakly guarded
  /// economy/production targets while the main force pushes.
  final bool raidsEconomy;

  /// Whether it spots gaps in the opponent's defenses (e.g. no anti-air)
  /// and builds/strikes to exploit them.
  final bool exploitsWeaknesses;

  /// How many Gold Mines it will build.
  final int maxGoldMines;

  const SkirmishAiProfile({
    required this.decisionInterval,
    required this.mistakeChance,
    required this.attackPowerRatio,
    required this.retreatPowerRatio,
    required this.minAttackers,
    required this.forceAttackArmySize,
    required this.incomeMultiplier,
    required this.maxProductionBuildings,
    required this.baseDefenseTowers,
    required this.defendsWithArmy,
    required this.countersPlayerArmy,
    required this.upgradesStructures,
    required this.capturesNodes,
    required this.fortifiesNodes,
    required this.raidsEconomy,
    required this.maxGoldMines,
    required this.exploitsWeaknesses,
  });
}
