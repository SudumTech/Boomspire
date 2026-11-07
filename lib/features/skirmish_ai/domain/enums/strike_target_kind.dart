/// What kind of thing the AI army is going after - drives both how valuable
/// the target is and how the HUD labels it.
enum StrikeTargetKind {
  /// Gold Mine - cutting the opponent's income.
  economy,

  /// Training Center / War Factory - stopping their unit production.
  production,

  /// A resource node held by the opponent.
  resourceNode,

  /// Tech buildings and combat towers.
  defense,

  /// The opponent's home base - ends the match.
  base,
}
