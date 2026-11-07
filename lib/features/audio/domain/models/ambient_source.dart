/// One recording the ambient engine may take parts from.
class AmbientSource {
  /// Asset path under `assets/audio/`, e.g. `effects/soft-wind.mp3`.
  final String file;

  /// Length of the recording in seconds - parts are cut from inside it.
  final double seconds;

  /// This recording suits the channel's level only between these bounds
  /// (e.g. a soft breeze for gentle wind, a harsh gale for strong wind).
  final double minLevel;
  final double maxLevel;

  const AmbientSource(
    this.file,
    this.seconds, {
    this.minLevel = 0,
    this.maxLevel = 1,
  });

  bool suits(double level) => level >= minLevel && level <= maxLevel;
}
