import 'dart:math';

import '../domain/models/ambient_catalog.dart';
import '../domain/models/ambient_environment.dart';
import '../domain/models/ambient_sound_type.dart';
import 'ambient_channel_runner.dart';
import 'ambient_clip_player.dart';
import 'ambient_mix_planner.dart';

/// The environmental sound engine: every frame it reads the live
/// [AmbientEnvironment], lets the [AmbientMixPlanner] decide how each channel
/// should sound, and drives one [AmbientChannelRunner] per channel to play
/// (and fade in/out) random parts of the recordings at the right level and
/// frequency. Heavy fighting turns everything down; calm lets it breathe.
class AmbientSoundEngine {
  /// The engine thinks at this rate (seconds) rather than every frame - fades
  /// are smooth either way, and it keeps the audio backend calls light.
  static const _tickSeconds = 0.05;

  final AmbientMixPlanner _planner;
  final Map<AmbientSoundType, AmbientChannelRunner> _runners;
  double _accumulated = 0;

  AmbientSoundEngine({
    required AmbientCatalog catalog,
    required AmbientClipPlayer player,
    Random? random,
  }) : _planner = AmbientMixPlanner(
         birdPartsPerMinuteAtFull: _birdRate(catalog),
       ),
       _runners = {
         for (final profile in catalog.profiles)
           profile.type: AmbientChannelRunner(
             profile,
             player,
             random ?? Random(),
           ),
       };

  /// Advances the engine by [dt] seconds against the current [environment].
  void update(AmbientEnvironment environment, double dt) {
    _accumulated += dt;
    if (_accumulated < _tickSeconds) return;
    final elapsed = _accumulated;
    _accumulated = 0;

    final targets = _planner.plan(environment);
    for (final entry in _runners.entries) {
      entry.value.update(targets[entry.key]!, elapsed);
    }
  }

  void stopAll() {
    for (final runner in _runners.values) {
      runner.stopAll();
    }
  }

  /// The runner for [type], if its recordings are present (diagnostics/tests).
  AmbientChannelRunner? runnerFor(AmbientSoundType type) => _runners[type];

  static double _birdRate(AmbientCatalog catalog) => catalog.profiles
      .where((p) => p.type == AmbientSoundType.birds)
      .map((p) => p.partsPerMinuteAtFull)
      .followedBy(const [7])
      .first;
}
