import 'dart:io';
import 'dart:math';

import 'package:boomspire/features/map_editor/domain/models/environment_settings.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/audio/domain/models/ambient_catalog.dart';
import 'package:boomspire/features/audio/domain/models/ambient_environment.dart';
import 'package:boomspire/features/audio/domain/models/ambient_sound_type.dart';
import 'package:boomspire/features/audio/domain/models/ambient_target.dart';
import 'package:boomspire/features/audio/impl/ambient_clip_player.dart';
import 'package:boomspire/features/audio/impl/ambient_mix_planner.dart';
import 'package:boomspire/features/audio/impl/ambient_sound_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClip implements AmbientClip {
  final String file;
  final double startSeconds;
  double volume = 0;
  bool stopped = false;

  _FakeClip(this.file, this.startSeconds);

  @override
  void setVolume(double v) => volume = v;

  @override
  void stop() => stopped = true;
}

class _FakePlayer implements AmbientClipPlayer {
  final List<_FakeClip> started = [];

  List<_FakeClip> get playing => started.where((c) => !c.stopped).toList();

  @override
  AmbientClip start(String file, {required double startSeconds}) {
    final clip = _FakeClip(file, startSeconds);
    started.add(clip);
    return clip;
  }
}

/// Runs [seconds] of simulated time against a constant [env].
double _run(
  AmbientSoundEngine engine,
  AmbientEnvironment env,
  double seconds, {
  double step = 0.1,
}) {
  for (var t = 0.0; t < seconds; t += step) {
    engine.update(env, step);
  }
  return seconds;
}

AmbientSoundEngine _engine(_FakePlayer player, {int seed = 1}) =>
    AmbientSoundEngine(
      catalog: AmbientCatalog.standard,
      player: player,
      random: Random(seed),
    );

double _loudest(_FakePlayer player, String needle) => player.started
    .where((c) => c.file.contains(needle))
    .fold(0.0, (m, c) => max(m, c.volume));

void main() {
  group('mix planner (environment -> levels)', () {
    const planner = AmbientMixPlanner();

    test('calm and empty is silent', () {
      final targets = planner.plan(AmbientEnvironment.calm);
      expect(targets.values.every((t) => t.level == 0), isTrue);
    });

    test('each channel follows its own part of the environment', () {
      double level(AmbientEnvironment e, AmbientSoundType t) =>
          planner.plan(e)[t]!.level;
      expect(
        level(
          const AmbientEnvironment(rainIntensity: 0.5),
          AmbientSoundType.rain,
        ),
        greaterThan(0),
      );
      expect(
        level(
          const AmbientEnvironment(snowIntensity: 0.5),
          AmbientSoundType.snow,
        ),
        greaterThan(0),
      );
      expect(
        level(
          const AmbientEnvironment(dustIntensity: 0.5),
          AmbientSoundType.dust,
        ),
        greaterThan(0),
      );
      expect(
        level(
          const AmbientEnvironment(windStrength: 0.5),
          AmbientSoundType.wind,
        ),
        greaterThan(0),
      );
      expect(
        level(
          const AmbientEnvironment(waterShare: 0.1),
          AmbientSoundType.water,
        ),
        greaterThan(0),
      );
      expect(
        level(const AmbientEnvironment(seaShare: 0.2), AmbientSoundType.sea),
        greaterThan(0),
      );
      expect(
        level(const AmbientEnvironment(lavaShare: 0.1), AmbientSoundType.lava),
        greaterThan(0),
      );
    });

    test('leaves rustle only with wind AND trees in view', () {
      double leaves(double wind, double trees) => planner
          .plan(
            AmbientEnvironment(windStrength: wind, treeDensity: trees),
          )[AmbientSoundType.leaves]!
          .level;
      expect(leaves(1, 0), 0);
      expect(leaves(0, 1), 0);
      expect(leaves(1, 1), greaterThan(0));
    });

    test('combat turns the soundscape down, but not off', () {
      double wind(double combat) => planner
          .plan(
            AmbientEnvironment(windStrength: 1, combatIntensity: combat),
          )[AmbientSoundType.wind]!
          .level;
      expect(wind(0), 1);
      expect(wind(1), lessThan(wind(0)));
      expect(wind(1), greaterThan(0));
    });

    test(
      'birds are loudest and most frequent in calm, rarer in bad weather',
      () {
        AmbientTarget birds(AmbientEnvironment e) =>
            planner.plan(e)[AmbientSoundType.birds]!;
        final fair = birds(const AmbientEnvironment(birdActivity: 1));
        final rainy = birds(
          const AmbientEnvironment(birdActivity: 1, rainIntensity: 0.9),
        );
        expect(fair.level, greaterThan(rainy.level));
        expect(fair.partsPerMinute, greaterThan(rainy.partsPerMinute));
      },
    );

    test('birds fall silent when the fighting gets heavy', () {
      final t = planner.plan(
        const AmbientEnvironment(birdActivity: 1, combatIntensity: 0.8),
      )[AmbientSoundType.birds]!;
      expect(t.level, 0);
      expect(t.partsPerMinute, 0);
    });
  });

  group('sound engine (parts, fades, frequency)', () {
    test('nothing plays in a silent environment', () {
      final player = _FakePlayer();
      _run(_engine(player), AmbientEnvironment.calm, 30);
      expect(player.started, isEmpty);
    });

    test('rain plays parts of the rain recordings, faded in from silence', () {
      final player = _FakePlayer();
      final engine = _engine(player);
      _run(engine, const AmbientEnvironment(rainIntensity: 1), 0.3);
      expect(player.started, isNotEmpty);
      expect(player.started.every((c) => c.file.contains('rain')), isTrue);
      final early = _loudest(player, 'rain');

      _run(engine, const AmbientEnvironment(rainIntensity: 1), 12);
      final settled = _loudest(player, 'rain');
      expect(early, lessThan(settled), reason: 'fades in');
      expect(settled, lessThanOrEqualTo(0.3), reason: 'stays low');
    });

    test('parts are cut from inside the recording, within the part length', () {
      final player = _FakePlayer();
      _run(_engine(player), const AmbientEnvironment(windStrength: 0.4), 90);
      expect(player.started.length, greaterThan(3));
      final wind = AmbientCatalog.standard.profiles.firstWhere(
        (p) => p.type == AmbientSoundType.wind,
      );
      for (final clip in player.started) {
        final source = wind.sources.firstWhere((s) => s.file == clip.file);
        expect(clip.startSeconds, greaterThanOrEqualTo(0));
        expect(clip.startSeconds, lessThan(source.seconds));
      }
    });

    test('gentle wind uses the soft recording, a gale the harsh one', () {
      final soft = _FakePlayer();
      _run(_engine(soft), const AmbientEnvironment(windStrength: 0.2), 60);
      expect(soft.started.every((c) => c.file.contains('soft-wind')), isTrue);

      final gale = _FakePlayer();
      _run(_engine(gale), const AmbientEnvironment(windStrength: 1), 200);
      expect(gale.started.any((c) => c.file.contains('harsh-wind')), isTrue);
    });

    test('heavy combat makes the same weather play quieter', () {
      final calm = _FakePlayer();
      _run(_engine(calm), const AmbientEnvironment(rainIntensity: 1), 25);
      final busy = _FakePlayer();
      _run(
        _engine(busy),
        const AmbientEnvironment(rainIntensity: 1, combatIntensity: 1),
        25,
      );
      expect(_loudest(busy, 'rain'), lessThan(_loudest(calm, 'rain') * 0.5));
    });

    test('when the weather clears everything fades out and stops', () {
      final player = _FakePlayer();
      final engine = _engine(player);
      _run(engine, const AmbientEnvironment(rainIntensity: 1), 20);
      expect(player.playing, isNotEmpty);

      _run(engine, AmbientEnvironment.calm, 40);
      expect(player.playing, isEmpty);
    });

    test('birds call more often when the sky is calmer', () {
      int calls(double rain) {
        final player = _FakePlayer();
        _run(
          _engine(player, seed: 7),
          AmbientEnvironment(birdActivity: 1, rainIntensity: rain),
          300,
        );
        return player.started.where((c) => c.file.contains('bird')).length;
      }

      expect(calls(0), greaterThan(calls(0.8)));
      expect(calls(0), greaterThan(5));
    });

    test('a channel with no recordings bundled stays silent', () {
      final player = _FakePlayer();
      final engine = AmbientSoundEngine(
        catalog: AmbientCatalog.standard.availableIn({}),
        player: player,
      );
      _run(
        engine,
        const AmbientEnvironment(rainIntensity: 1, windStrength: 1),
        30,
      );
      expect(player.started, isEmpty);
    });

    test('every recording the catalog names is really in assets/audio', () {
      for (final file in AmbientCatalog.standard.allFiles) {
        expect(File('assets/audio/$file').existsSync(), isTrue, reason: file);
      }
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
