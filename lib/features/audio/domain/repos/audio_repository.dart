import '../models/ambient_environment.dart';
import '../models/sfx_type.dart';

/// Abstraction over sound effect playback so presentation code never talks
/// to a concrete audio engine directly.
abstract class AudioRepository {
  void play(SfxType type, {double volume = 1});
  Future<void> preload();

  /// Feeds the environmental sound engine the current state of the world
  /// (weather, terrain in view, combat). Call it every frame: the engine
  /// decides which parts of which recordings to play, how loud, and how
  /// often, fading them in and out as the environment changes.
  void updateAmbience(AmbientEnvironment environment, double dt);
}
