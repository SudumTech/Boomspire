import 'dart:ui' as ui;

import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/terrain/domain/models/style_crossfade.dart';
import 'package:boomspire/features/terrain/presentation/components/terrain_component/util/paint_rain.dart';
import 'package:boomspire/features/terrain/presentation/components/terrain_component/util/paint_snow.dart';
import 'package:boomspire/features/terrain/presentation/components/terrain_component/util/paint_wind_streaks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Total ink (sum of alpha) a painter lays down on a small canvas.
Future<double> _ink(void Function(ui.Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(ui.Canvas(recorder));
  final image = await recorder.endRecording().toImage(400, 300);
  final data = await image.toByteData();
  var sum = 0.0;
  for (var i = 3; i < data!.lengthInBytes; i += 4) {
    sum += data.getUint8(i);
  }
  return sum;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StyleCrossfade', () {
    test('keeps showing the old style until it has faded out, then swaps', () {
      final fade = StyleCrossfade<String>('leaves', fadeSeconds: 2);
      fade.update('leaves', 1);
      expect(fade.opacity, 1);

      fade.update('snow', 0.5); // starts fading out
      expect(fade.style, 'leaves');
      expect(fade.opacity, closeTo(0.75, 1e-9));

      fade.update('snow', 1.5); // fully out -> swap while invisible
      expect(fade.style, 'snow');
      expect(fade.opacity, 0);

      fade.update('snow', 1); // fading the new style in
      expect(fade.opacity, closeTo(0.5, 1e-9));
      fade.update('snow', 5);
      expect(fade.opacity, 1);
    });

    test('changing its mind mid-fade just fades back in (no swap)', () {
      final fade = StyleCrossfade<String>('leaves', fadeSeconds: 2);
      fade.update('snow', 1);
      expect(fade.opacity, closeTo(0.5, 1e-9));
      fade.update('leaves', 1);
      expect(fade.style, 'leaves');
      expect(fade.opacity, closeTo(1, 1e-9));
    });

    test('opacity changes by at most dt/fadeSeconds per update (smooth)', () {
      final fade = StyleCrossfade<int>(0, fadeSeconds: 3);
      var previous = fade.opacity;
      for (var i = 0; i < 400; i++) {
        fade.update(i < 150 ? 1 : 0, 0.05);
        expect(
          (fade.opacity - previous).abs(),
          lessThanOrEqualTo(0.05 / 3 + 1e-9),
        );
        previous = fade.opacity;
      }
    });
  });

  group('weather particles appear gradually, not in pops', () {
    // Intensities chosen either side of a rounding boundary (x.5 particles),
    // where the old rounded count added a whole particle at once.
    const low = 80.45 / 160;
    const high = 80.55 / 160;

    Future<double> rain(double intensity) => _ink(
      (c) => paintRain(
        c,
        WeatherKeyframe(atProgress: 0, rainIntensity: intensity),
        width: 400,
        height: 300,
        weatherPhase: 3,
      ),
    );

    test('rain', () async {
      final a = await rain(low);
      final b = await rain(high);
      // 0.1 of a drop's worth of change, not a whole drop (~1/80 of the ink).
      expect((b - a).abs() / a, lessThan(0.004));
    });

    test('snow', () async {
      Future<double> snow(double intensity) => _ink(
        (c) => paintSnow(
          c,
          WeatherKeyframe(atProgress: 0, snowIntensity: intensity),
          width: 400,
          height: 300,
          weatherPhase: 3,
        ),
      );
      final a = await snow(60.45 / 110);
      final b = await snow(60.55 / 110);
      expect((b - a).abs() / a, lessThan(0.006));
    });

    test('wind streaks', () async {
      Future<double> streaks(double wind) => _ink(
        (c) => paintWindStreaks(
          c,
          WeatherKeyframe(atProgress: 0, windStrength: wind),
          WindType.dust,
          width: 400,
          height: 300,
          weatherPhase: 3,
        ),
      );
      final a = await streaks(20.45 / 40);
      final b = await streaks(20.55 / 40);
      expect((b - a).abs() / a, lessThan(0.025)); // a whole streak would be ~5%
    });

    test('a style crossfade scales the whole wind effect', () async {
      Future<double> streaks(double scale) => _ink(
        (c) => paintWindStreaks(
          c,
          const WeatherKeyframe(atProgress: 0, windStrength: 0.8),
          WindType.dust,
          width: 400,
          height: 300,
          weatherPhase: 3,
          opacityScale: scale,
        ),
      );
      expect(await streaks(0), 0);
      expect(await streaks(0.5), lessThan(await streaks(1)));
    });
  });
}
