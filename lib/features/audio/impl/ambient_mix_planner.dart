import 'dart:math';

import '../../game_core/domain/models/game_config.dart';
import '../domain/models/ambient_environment.dart';
import '../domain/models/ambient_sound_type.dart';
import '../domain/models/ambient_target.dart';

/// The rules that link the environment to the soundscape - pure, so the
/// whole relationship can be read (and tested) in one place:
///
/// - Each weather channel follows its own intensity.
/// - Water, sea and lava follow how much of them is in view; leaves rustle
///   where there are trees and wind.
/// - Birds are the opposite of a storm: loudest and most frequent in calm
///   weather, quieter and rarer as rain/wind/snow/dust rise.
/// - Fighting pushes everything down, and silences birds outright once it
///   gets heavy; with little or no fighting nothing is ducked.
class AmbientMixPlanner {
  /// Birds' rate of calls per minute at the quietest (just audible).
  static const _minBirdPartsPerMinute = 1.5;

  /// How quickly a small share of water/lava/sea in view becomes audible:
  /// a river across a tenth of the screen is already clearly heard.
  static const _waterGain = 5.0;
  static const _seaGain = 3.0;
  static const _lavaGain = 5.0;

  /// Birds fall silent entirely once combat is at this intensity.
  static const _birdsScaredAt = 0.65;

  /// How many parts per minute birds make at full activity (from the
  /// catalog's profile); planner only scales it.
  final double birdPartsPerMinuteAtFull;

  const AmbientMixPlanner({this.birdPartsPerMinuteAtFull = 7});

  Map<AmbientSoundType, AmbientTarget> plan(AmbientEnvironment env) {
    final duck = 1 - env.combatIntensity * GameConfig.combatAmbientDuckStrength;
    AmbientTarget bed(double level) =>
        AmbientTarget(level: (level * duck).clamp(0.0, 1.0));

    return {
      AmbientSoundType.wind: bed(env.windStrength),
      AmbientSoundType.rain: bed(env.rainIntensity),
      AmbientSoundType.snow: bed(env.snowIntensity),
      AmbientSoundType.dust: bed(env.dustIntensity),
      AmbientSoundType.leaves: bed(env.windStrength * env.treeDensity),
      AmbientSoundType.water: bed(
        env.waterShare * _waterGain * (1 - env.rainIntensity * 0.3),
      ),
      AmbientSoundType.sea: bed(env.seaShare * _seaGain),
      AmbientSoundType.lava: bed(env.lavaShare * _lavaGain),
      AmbientSoundType.birds: _birds(env),
    };
  }

  AmbientTarget _birds(AmbientEnvironment env) {
    final calm =
        (1 - env.rainIntensity * 0.9) *
        (1 - env.windStrength * 0.6) *
        (1 - env.snowIntensity * 0.7) *
        (1 - env.dustIntensity * 0.7);
    final scared = (1 - env.combatIntensity / _birdsScaredAt).clamp(0.0, 1.0);
    final level = (env.birdActivity * calm * scared).clamp(0.0, 1.0);
    if (level <= 0) return AmbientTarget.silent;
    final rate =
        _minBirdPartsPerMinute +
        (birdPartsPerMinuteAtFull - _minBirdPartsPerMinute) * level;
    return AmbientTarget(level: level, partsPerMinute: max(0, rate));
  }
}
