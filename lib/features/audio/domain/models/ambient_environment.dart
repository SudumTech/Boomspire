/// Everything the ambient sound engine reads about the world, every frame.
/// All values are 0..1.
class AmbientEnvironment {
  /// Silence: clear, empty, quiet.
  static const calm = AmbientEnvironment();

  // --- weather (from the live weather blend) -------------------------------
  final double windStrength;
  final double rainIntensity;
  final double snowIntensity;
  final double dustIntensity;
  final double birdActivity;

  // --- terrain currently in view ---------------------------------------------
  /// How much trees there are in view (leaves rustle where there are trees).
  final double treeDensity;

  /// How much river/lake water is in view.
  final double waterShare;

  /// How much sea is in view.
  final double seaShare;

  /// How much lava is in view.
  final double lavaShare;

  // --- the battle ----------------------------------------------------------------
  /// How intense the fighting is right now; ambience ducks under it.
  final double combatIntensity;

  const AmbientEnvironment({
    this.windStrength = 0,
    this.rainIntensity = 0,
    this.snowIntensity = 0,
    this.dustIntensity = 0,
    this.birdActivity = 0,
    this.treeDensity = 0,
    this.waterShare = 0,
    this.seaShare = 0,
    this.lavaShare = 0,
    this.combatIntensity = 0,
  });
}
