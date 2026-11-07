/// What the AI opponent's field army is doing right now - see
/// `ArmyCommander`.
enum ArmyStance {
  /// Gathering at the rally point until the army is strong enough to win.
  muster,

  /// Marching on the human player's base.
  attack,

  /// Intercepting hostile units that are threatening the AI's own base.
  defend,
}
