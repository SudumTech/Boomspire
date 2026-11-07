import '../domain/enums/game_mode.dart';

extension GameModeExtensions on GameMode {
  /// The most home bases a map in this mode may have - the single place this
  /// rule lives, shared by the map editor and anything else that needs it.
  ///
  /// Tower defense defends exactly one home. Skirmish is one-versus-one for
  /// now (you and the AI); raise this when multiplayer seats arrive.
  int get maxHomeSites => switch (this) {
    GameMode.waveDefense => 1,
    GameMode.skirmish => 2,
  };

  /// How many home bases a map must have before it can be played in this
  /// mode (a skirmish needs a seat for every side; tower defense falls back
  /// to a default home when none was placed).
  int get requiredHomeSites => switch (this) {
    GameMode.waveDefense => 0,
    GameMode.skirmish => 2,
  };
}
