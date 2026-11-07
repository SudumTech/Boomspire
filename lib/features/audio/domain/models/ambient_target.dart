/// What one channel should currently sound like, as decided by the
/// `AmbientMixPlanner` from the environment.
class AmbientTarget {
  static const silent = AmbientTarget(level: 0);

  /// 0..1 loudness relative to the channel's own maximum volume.
  final double level;

  /// For sporadic channels (birds): how many parts per minute to play.
  final double partsPerMinute;

  const AmbientTarget({required this.level, this.partsPerMinute = 0});
}
