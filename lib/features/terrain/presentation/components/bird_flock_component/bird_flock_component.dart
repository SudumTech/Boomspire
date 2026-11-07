import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../game_core/presentation/boomspire_game.dart';
import 'util/paint_bird.dart';

/// Small flocks of birds crossing the sky now and then - a calm, natural
/// touch that follows the live weather's `birdActivity`: more flocks when
/// it is high, none in rain or while a battle rages (the birdsong ambience
/// follows the same rules, see `AmbientWeatherAudioComponent`). Purely
/// decorative; birds fly in a loose V and drift gently up and down.
class BirdFlockComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  /// Seconds between flocks at the lowest and highest bird activity.
  static const _quietInterval = 50.0;
  static const _busyInterval = 10.0;

  /// No new flocks while it is raining harder than this or combat is
  /// busier than this.
  static const _maxRain = 0.5;
  static const _maxCombat = 0.4;

  static const _margin = 60.0;

  final Vector2 _arenaSize;
  final Random _random;
  final List<_Flock> _flocks = [];
  double _spawnTimer;

  BirdFlockComponent({required Vector2 arenaSize, Random? random})
    : _arenaSize = arenaSize,
      _random = random ?? Random(),
      _spawnTimer = 6,
      super(position: Vector2.zero(), size: arenaSize, priority: 155);

  /// Live flocks, for tests.
  int get flockCount => _flocks.length;

  @override
  void update(double dt) {
    super.update(dt);
    _advanceFlocks(dt);
    _maybeSpawn(dt);
  }

  @override
  void render(Canvas canvas) {
    for (final flock in _flocks) {
      for (final bird in flock.birds) {
        canvas.save();
        canvas.translate(bird.position.x, bird.position.y);
        canvas.rotate(flock.heading);
        paintBird(
          canvas,
          flap: sin(bird.flapPhase),
          scale: bird.scale,
          opacity: 0.78,
        );
        canvas.restore();
      }
    }
  }

  void _advanceFlocks(double dt) {
    for (final flock in _flocks) {
      flock.elapsed += dt;
      for (final bird in flock.birds) {
        bird.flapPhase += dt * bird.flapRate;
        bird.position
          ..x += flock.velocity.x * dt
          ..y +=
              flock.velocity.y * dt +
              sin(flock.elapsed * 0.8 + bird.driftPhase) * 6 * dt;
      }
    }
    _flocks.removeWhere(_isOffArena);
  }

  bool _isOffArena(_Flock flock) => flock.birds.every(
    (b) =>
        b.position.x < -_margin ||
        b.position.x > _arenaSize.x + _margin ||
        b.position.y < -_margin ||
        b.position.y > _arenaSize.y + _margin,
  );

  void _maybeSpawn(double dt) {
    final weather = game.scene.environment.sampleBlend(
      game.weatherFocus.weights,
    );
    if (weather.birdActivity <= 0.05) return;
    if (weather.rainIntensity > _maxRain) return;
    if (game.combatIntensity > _maxCombat) return;

    _spawnTimer -= dt;
    if (_spawnTimer > 0) return;
    final base =
        _quietInterval -
        (_quietInterval - _busyInterval) * weather.birdActivity;
    _spawnTimer = base * (0.7 + _random.nextDouble() * 0.6);
    _flocks.add(_newFlock());
  }

  _Flock _newFlock() {
    final leftToRight = _random.nextBool();
    final heading = leftToRight ? 0.0 : pi;
    final speed = 55 + _random.nextDouble() * 30;
    final tilt = (_random.nextDouble() - 0.5) * 0.5;
    final velocity = Vector2(cos(heading + tilt), sin(heading + tilt)) * speed;
    final startX = leftToRight ? -_margin / 2 : _arenaSize.x + _margin / 2;
    final startY = _arenaSize.y * (0.12 + _random.nextDouble() * 0.7);
    final count = 3 + _random.nextInt(4);

    final back = Vector2(-cos(heading), -sin(heading));
    final side = Vector2(-back.y, back.x);
    return _Flock(
      heading: heading + tilt,
      velocity: velocity,
      birds: [
        for (var i = 0; i < count; i++)
          _Bird(
            position:
                Vector2(startX, startY) +
                back * ((i + 1) ~/ 2 * 15.0) +
                side * ((i.isEven ? 1 : -1) * ((i + 1) ~/ 2) * 11.0),
            flapPhase: _random.nextDouble() * 2 * pi,
            flapRate: 9 + _random.nextDouble() * 4,
            driftPhase: _random.nextDouble() * 2 * pi,
            scale: 0.85 + _random.nextDouble() * 0.35,
          ),
      ],
    );
  }
}

class _Flock {
  final double heading;
  final Vector2 velocity;
  final List<_Bird> birds;
  double elapsed = 0;

  _Flock({required this.heading, required this.velocity, required this.birds});
}

class _Bird {
  final Vector2 position;
  double flapPhase;
  final double flapRate;
  final double driftPhase;
  final double scale;

  _Bird({
    required this.position,
    required this.flapPhase,
    required this.flapRate,
    required this.driftPhase,
    required this.scale,
  });
}
