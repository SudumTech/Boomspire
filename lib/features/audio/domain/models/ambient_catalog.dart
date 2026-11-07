import 'ambient_profile.dart';
import 'ambient_sound_type.dart';
import 'ambient_source.dart';

/// Which recordings feed which channel, and how each channel behaves. The
/// recordings live in `assets/audio/effects/`; a channel whose recordings
/// are missing is simply silent.
class AmbientCatalog {
  final List<AmbientProfile> profiles;

  const AmbientCatalog(this.profiles);

  /// Every recording path this catalog may use.
  Set<String> get allFiles => {
    for (final p in profiles) ...p.sources.map((s) => s.file),
  };

  /// Only what is actually present in [available]; channels with nothing
  /// left are dropped.
  AmbientCatalog availableIn(Set<String> available) => AmbientCatalog([
    for (final p in profiles)
      if (p.onlyAvailable(available).sources.isNotEmpty)
        p.onlyAvailable(available),
  ]);

  /// The game's soundscape. Volumes are deliberately low (0.1 - 0.3).
  static const standard = AmbientCatalog([
    AmbientProfile(
      type: AmbientSoundType.wind,
      sources: [
        AmbientSource(
          'effects/storegraphic-soft-wind-477404.mp3',
          8,
          maxLevel: 0.6,
        ),
        AmbientSource(
          'effects/dragon-studio-winter-wind-402331.mp3',
          19,
          minLevel: 0.3,
          maxLevel: 0.85,
        ),
        AmbientSource(
          'effects/dragon-studio-harsh-wind-515272.mp3',
          13,
          minLevel: 0.65,
        ),
      ],
      minPart: 5,
      maxPart: 9,
      fadeSeconds: 2.5,
      maxVolume: 0.22,
    ),
    AmbientProfile(
      type: AmbientSoundType.rain,
      sources: [
        AmbientSource(
          'effects/feedthestraycats-real-rain-sound-379215.mp3',
          21,
          maxLevel: 0.7,
        ),
        AmbientSource(
          'effects/loswin23-raining-537715.mp3',
          60,
          minLevel: 0.35,
        ),
      ],
      minPart: 8,
      maxPart: 14,
      fadeSeconds: 3,
      maxVolume: 0.25,
    ),
    AmbientProfile(
      type: AmbientSoundType.snow,
      sources: [
        AmbientSource(
          'effects/freesound_community-snowing-in-dresden-heide-57670.mp3',
          108,
          maxLevel: 0.75,
        ),
        AmbientSource(
          'effects/freesound_community-wind-during-snow-storm-2-17562.mp3',
          105,
          minLevel: 0.6,
        ),
      ],
      minPart: 8,
      maxPart: 14,
      fadeSeconds: 3,
      maxVolume: 0.2,
    ),
    AmbientProfile(
      type: AmbientSoundType.dust,
      sources: [
        AmbientSource('effects/danevaer-vinyl-dust-noise-2-434728.mp3', 300),
      ],
      minPart: 6,
      maxPart: 12,
      fadeSeconds: 2.5,
      maxVolume: 0.1,
    ),
    AmbientProfile(
      type: AmbientSoundType.birds,
      sources: [
        AmbientSource(
          'effects/oxidvideos-chirping-birds-ambience-217410.mp3',
          98,
        ),
        AmbientSource(
          'effects/freesound_community-birds-chirping-75156.mp3',
          22,
        ),
      ],
      style: AmbientStyle.sporadic,
      minPart: 3,
      maxPart: 6,
      fadeSeconds: 1,
      maxVolume: 0.28,
      partsPerMinuteAtFull: 7,
    ),
    AmbientProfile(
      type: AmbientSoundType.leaves,
      sources: [
        AmbientSource('effects/soundsforyou-wind-in-trees-117477.mp3', 148),
        AmbientSource(
          'effects/dragon-studio-dry-leaves-rustling-482874.mp3',
          10.7,
          minLevel: 0.5,
        ),
      ],
      minPart: 5,
      maxPart: 10,
      fadeSeconds: 2.5,
      maxVolume: 0.2,
    ),
    AmbientProfile(
      type: AmbientSoundType.water,
      sources: [
        AmbientSource(
          'effects/dragon-studio-soothing-river-flow-372456.mp3',
          22,
        ),
      ],
      minPart: 8,
      maxPart: 14,
      fadeSeconds: 3,
      maxVolume: 0.18,
    ),
    AmbientProfile(
      type: AmbientSoundType.sea,
      sources: [AmbientSource('effects/kokoreli777-sea-waves-169411.mp3', 79)],
      minPart: 8,
      maxPart: 14,
      fadeSeconds: 3,
      maxVolume: 0.2,
    ),
    AmbientProfile(
      type: AmbientSoundType.lava,
      sources: [
        AmbientSource('effects/freesound_community-lava-loop-2-67306.mp3', 20),
      ],
      minPart: 6,
      maxPart: 12,
      fadeSeconds: 2.5,
      maxVolume: 0.15,
    ),
  ]);
}
