import 'ambient_sound_type.dart';
import 'ambient_source.dart';

/// How a channel's sound is delivered.
enum AmbientStyle {
  /// A continuous bed: parts follow each other, crossfading, for as long as
  /// the channel is audible.
  bed,

  /// Occasional events (birdcalls): a part now and then, at a rate that
  /// follows the environment.
  sporadic,
}

/// How one [AmbientSoundType] sounds: which recordings it draws parts from,
/// how long and how loud those parts are, and how it fades.
class AmbientProfile {
  final AmbientSoundType type;
  final List<AmbientSource> sources;
  final AmbientStyle style;

  /// Length range (seconds) of each part cut from a recording.
  final double minPart;
  final double maxPart;

  /// Fade-in/out of each part, and the time constant of the channel's own
  /// level changes - the "feed in and out".
  final double fadeSeconds;

  /// The loudest this channel ever gets (0..1) - kept low so the
  /// environment stays in the background.
  final double maxVolume;

  /// For [AmbientStyle.sporadic]: parts per minute at full level.
  final double partsPerMinuteAtFull;

  const AmbientProfile({
    required this.type,
    required this.sources,
    required this.minPart,
    required this.maxPart,
    required this.fadeSeconds,
    required this.maxVolume,
    this.style = AmbientStyle.bed,
    this.partsPerMinuteAtFull = 0,
  });

  /// The recordings that suit [level], or all of them if none does.
  List<AmbientSource> sourcesFor(double level) {
    final suited = sources.where((s) => s.suits(level)).toList();
    return suited.isEmpty ? sources : suited;
  }

  /// This profile limited to recordings whose file is in [available].
  AmbientProfile onlyAvailable(Set<String> available) => AmbientProfile(
    type: type,
    sources: sources.where((s) => available.contains(s.file)).toList(),
    minPart: minPart,
    maxPart: maxPart,
    fadeSeconds: fadeSeconds,
    maxVolume: maxVolume,
    style: style,
    partsPerMinuteAtFull: partsPerMinuteAtFull,
  );
}
