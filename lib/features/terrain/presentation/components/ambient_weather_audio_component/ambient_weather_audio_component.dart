import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../audio/domain/models/ambient_environment.dart';
import '../../../../game_core/presentation/boomspire_game.dart';
import '../../../domain/models/terrain_ambience.dart';
import '../../../impl/terrain_ambience_sampler.dart';

/// Reads the live state of the world every frame and hands it to the
/// environmental sound engine (see `AudioRepository.updateAmbience`):
///
/// - the weather blend (`BoomspireGame.weatherFocus`) - wind, rain, snow,
///   dust, bird activity;
/// - the terrain the camera currently sees - water, sea, lava, trees;
/// - how intense the fighting is (`BoomspireGame.combatIntensity`), which
///   turns the whole soundscape down.
///
/// The terrain is re-measured a couple of times a second rather than every
/// frame; scrolling the camera is slow compared to that.
class AmbientWeatherAudioComponent extends Component
    with HasGameReference<BoomspireGame> {
  static const _terrainSampleInterval = 0.5;

  final TerrainAmbienceSampler _sampler;
  TerrainAmbience _terrain = TerrainAmbience.none;
  double _untilTerrainSample = 0;

  AmbientWeatherAudioComponent([
    this._sampler = const TerrainAmbienceSampler(),
  ]);

  @override
  void update(double dt) {
    super.update(dt);
    _refreshTerrain(dt);
    final weather = game.scene.environment.sampleBlend(
      game.weatherFocus.weights,
    );
    game.audioRepository.updateAmbience(
      // The map's own sound mix (muted birds, louder wind...) shapes what
      // the weather and terrain ask for.
      game.scene.environment.ambience.applyTo(
        AmbientEnvironment(
          windStrength: weather.windStrength,
          rainIntensity: weather.rainIntensity,
          snowIntensity: weather.snowIntensity,
          dustIntensity: weather.dustIntensity,
          birdActivity: weather.birdActivity,
          treeDensity: _terrain.treeDensity,
          waterShare: _terrain.waterShare,
          seaShare: _terrain.seaShare,
          lavaShare: _terrain.lavaShare,
          combatIntensity: game.combatIntensity,
        ),
      ),
      dt,
    );
  }

  void _refreshTerrain(double dt) {
    _untilTerrainSample -= dt;
    if (_untilTerrainSample > 0) return;
    _untilTerrainSample = _terrainSampleInterval;
    _terrain = _sampler.sample(game.terrainMap, _visibleArea());
  }

  Rect _visibleArea() {
    final map = game.terrainMap;
    final everything = Rect.fromLTWH(0, 0, map.arenaWidth, map.arenaHeight);
    try {
      return game.camera.visibleWorldRect.intersect(everything);
    } on Object {
      return everything; // camera not laid out yet
    }
  }
}
