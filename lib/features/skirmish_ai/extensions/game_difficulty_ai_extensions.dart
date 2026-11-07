import '../../game_core/domain/models/game_difficulty.dart';
import '../domain/models/skirmish_ai_profile.dart';

extension GameDifficultyAiExtensions on GameDifficulty {
  /// How the skirmish AI plays at this difficulty.
  ///
  /// All difficulties know the same things (see [SkirmishAiProfile]); they
  /// differ in execution:
  /// - **Easy**: slow, distracted, grows a smaller base, attacks only with a
  ///   big edge, earns less.
  /// - **Normal**: a competent opponent.
  /// - **Hard**: fast, never distracted, attacks as soon as it is merely
  ///   stronger, retreats from lost fights, upgrades and raids, grows the
  ///   largest base and earns a bonus on top of what the player does.
  SkirmishAiProfile get skirmishAiProfile => switch (this) {
    GameDifficulty.easy => const SkirmishAiProfile(
      decisionInterval: 5.0,
      mistakeChance: 0.3,
      attackPowerRatio: 1.8,
      retreatPowerRatio: 0.5,
      minAttackers: 5,
      forceAttackArmySize: 16,
      incomeMultiplier: 0.8,
      maxProductionBuildings: 2,
      baseDefenseTowers: 2,
      upgradesStructures: false,
      raidsEconomy: false,
      maxGoldMines: 2,
    ),
    GameDifficulty.normal => const SkirmishAiProfile(
      decisionInterval: 3.0,
      mistakeChance: 0.1,
      attackPowerRatio: 1.25,
      retreatPowerRatio: 0.6,
      minAttackers: 4,
      forceAttackArmySize: 14,
      incomeMultiplier: 1.0,
      maxProductionBuildings: 3,
      baseDefenseTowers: 3,
      upgradesStructures: false,
      raidsEconomy: false,
      maxGoldMines: 3,
    ),
    GameDifficulty.hard => const SkirmishAiProfile(
      decisionInterval: 1.5,
      mistakeChance: 0.0,
      attackPowerRatio: 1.0,
      retreatPowerRatio: 0.75,
      minAttackers: 3,
      forceAttackArmySize: 12,
      incomeMultiplier: 1.25,
      maxProductionBuildings: 4,
      baseDefenseTowers: 4,
      upgradesStructures: true,
      raidsEconomy: true,
      maxGoldMines: 4,
    ),
  };
}
