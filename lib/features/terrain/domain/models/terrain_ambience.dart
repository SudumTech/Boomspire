/// What the terrain in view contributes to the soundscape - each 0..1.
class TerrainAmbience {
  static const none = TerrainAmbience(
    treeDensity: 0,
    waterShare: 0,
    seaShare: 0,
    lavaShare: 0,
  );

  /// How wooded the view is (leaves rustle in the wind where this is high).
  final double treeDensity;

  /// Share of the view covered by river/lake water.
  final double waterShare;

  /// Share of the view covered by sea.
  final double seaShare;

  /// Share of the view covered by lava.
  final double lavaShare;

  const TerrainAmbience({
    required this.treeDensity,
    required this.waterShare,
    required this.seaShare,
    required this.lavaShare,
  });
}
