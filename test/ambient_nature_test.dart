import 'package:boomspire/features/map_editor/domain/models/environment_settings.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/terrain/presentation/components/ambient_weather_audio_component/util/ambient_weather_volumes.dart';
import 'package:flutter_test/flutter_test.dart';

AmbientWeatherVolumes _volumes({
  double wind = 0,
  double rain = 0,
  double snow = 0,
  double dust = 0,
  double birds = 0,
  double trees = 0,
  double combat = 0,
}) => ambientWeatherVolumes(
  windStrength: wind,
  rainIntensity: rain,
  snowIntensity: snow,
  dustIntensity: dust,
  birdActivity: birds,
  treeDensity: trees,
  combatIntensity: combat,
);

void main() {
  group('ambient volumes', () {
    test('a clear day with birds is audible, everything else silent', () {
      final v = _volumes(birds: 1);
      expect(v.birds, greaterThan(0.3));
      expect(v.wind + v.rain + v.snow + v.dust + v.leaves, 0);
    });

    test('birds fall silent in heavy rain and during combat', () {
      expect(_volumes(birds: 1, rain: 1).birds, lessThan(0.06));
      expect(_volumes(birds: 1, combat: 1).birds, 0);
    });

    test('each weather channel follows its own intensity', () {
      expect(_volumes(rain: 0.5).rain, greaterThan(0));
      expect(_volumes(snow: 0.5).snow, greaterThan(0));
      expect(_volumes(dust: 0.5).dust, greaterThan(0));
      expect(_volumes(wind: 0.5).wind, greaterThan(0));
    });

    test('leaves rustle only with wind AND trees', () {
      expect(_volumes(wind: 1, trees: 0).leaves, 0);
      expect(_volumes(wind: 0, trees: 1).leaves, 0);
      expect(_volumes(wind: 1, trees: 1).leaves, greaterThan(0));
    });

    test('combat ducks the ambience without silencing wind entirely', () {
      final calm = _volumes(wind: 1).wind;
      final busy = _volumes(wind: 1, combat: 1).wind;
      expect(busy, lessThan(calm));
      expect(busy, greaterThan(0));
    });
  });

  group('environment dust and birds', () {
    const quiet = WeatherKeyframe(atProgress: 0);
    const lively = WeatherKeyframe(
      atProgress: 1,
      dustIntensity: 1,
      birdActivity: 0.8,
    );
    const settings = EnvironmentSettings(timeline: [quiet, lively]);

    test('sample interpolates them by match progress', () {
      final mid = settings.sample(0.5);
      expect(mid.dustIntensity, closeTo(0.5, 1e-9));
      expect(mid.birdActivity, closeTo(0.4, 1e-9));
    });

    test('sampleBlend mixes them by keyframe weight', () {
      final blended = settings.sampleBlend([0.25, 0.75]);
      expect(blended.dustIntensity, closeTo(0.75, 1e-9));
      expect(blended.birdActivity, closeTo(0.6, 1e-9));
    });

    test('old saved maps without the new fields still load (as zero)', () {
      final legacy = WeatherKeyframe.fromJson({
        'atProgress': 0.2,
        'windStrength': 0.4,
      });
      expect(legacy.dustIntensity, 0);
      expect(legacy.birdActivity, 0);
    });

    test('the new fields survive a JSON round trip', () {
      final round = WeatherKeyframe.fromJson(lively.toJson());
      expect(round, lively);
    });
  });
}
