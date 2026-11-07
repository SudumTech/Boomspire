import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../audio/domain/models/ambient_environment.dart';

part 'ambience_settings.freezed.dart';
part 'ambience_settings.g.dart';

/// How a map sounds: its own mix of the environment sound layers on top of
/// what the weather and terrain already drive. Every layer is a multiplier
/// (1 = as the world dictates, 0 = muted, up to 2 = twice as present), so a
/// frozen map can howl with wind and have no birds while a jungle map is
/// loud with birds and leaves - and all of it stays authored data (map
/// JSON), not code.
@freezed
abstract class AmbienceSettings with _$AmbienceSettings {
  const factory AmbienceSettings({
    /// Master switch for this map's environment sound.
    @Default(true) bool enabled,

    /// Scales every layer together.
    @Default(1.0) double volume,
    @Default(1.0) double wind,
    @Default(1.0) double rain,
    @Default(1.0) double snow,
    @Default(1.0) double dust,
    @Default(1.0) double birds,

    /// Rustling leaves - follows how many trees are in view.
    @Default(1.0) double leaves,

    /// Rivers and lakes.
    @Default(1.0) double water,
    @Default(1.0) double sea,
    @Default(1.0) double lava,
  }) = _AmbienceSettings;

  factory AmbienceSettings.fromJson(Map<String, dynamic> json) =>
      _$AmbienceSettingsFromJson(json);

  const AmbienceSettings._();

  /// What the sound engine should hear: [world] with each layer scaled by
  /// this map's mix (clamped to 0..1); silence when [enabled] is false.
  /// Combat intensity is never scaled - the fighting itself ducks the mix.
  AmbientEnvironment applyTo(AmbientEnvironment world) {
    if (!enabled) return AmbientEnvironment.calm;
    double mix(double value, double layer) =>
        (value * layer * volume).clamp(0.0, 1.0);
    return AmbientEnvironment(
      windStrength: mix(world.windStrength, wind),
      rainIntensity: mix(world.rainIntensity, rain),
      snowIntensity: mix(world.snowIntensity, snow),
      dustIntensity: mix(world.dustIntensity, dust),
      birdActivity: mix(world.birdActivity, birds),
      treeDensity: mix(world.treeDensity, leaves),
      waterShare: mix(world.waterShare, water),
      seaShare: mix(world.seaShare, sea),
      lavaShare: mix(world.lavaShare, lava),
      combatIntensity: world.combatIntensity,
    );
  }
}
