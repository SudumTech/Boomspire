/// Gaps in the opponent's defenses the AI can exploit.
class PlayerWeakness {
  /// Number of the opponent's towers/units that can shoot aircraft.
  final int antiAirSources;

  const PlayerWeakness({required this.antiAirSources});

  /// Nothing the opponent owns can hit aircraft: an air force is free to
  /// strike anywhere.
  bool get lacksAntiAir => antiAirSources == 0;
}
