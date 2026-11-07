import 'dart:math';
import 'dart:ui';

import 'package:boomspire/features/combat/presentation/util/plane_flight.dart';
import 'package:boomspire/features/game_core/presentation/util/paint_capture_radar.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaneFlight', () {
    const speed = 150.0;
    const turnRate = 3.0;
    const dt = 1 / 60;

    ({Vector2 position, double facing}) fly(
      PlaneFlight flight,
      Vector2 position,
      double facing,
      Vector2? goal,
      int frames,
      void Function(Vector2 position, double moved)? onFrame,
    ) {
      var pos = position;
      var face = facing;
      for (var i = 0; i < frames; i++) {
        final step = flight.step(
          position: pos,
          facing: face,
          goal: goal,
          speed: speed,
          turnRate: turnRate,
          dt: dt,
        );
        onFrame?.call(step.position, step.position.distanceTo(pos));
        pos = step.position;
        face = step.facing;
      }
      return (position: pos, facing: face);
    }

    test(
      'never stops: it moves at full speed every frame, even at the goal',
      () {
        final flight = PlaneFlight(minOrbitRadius: 80);
        final goal = Vector2(500, 500);
        var minMoved = double.infinity;
        fly(flight, Vector2.zero(), 0, goal, 3000, (_, moved) {
          minMoved = min(minMoved, moved);
        });
        expect(minMoved, closeTo(speed * dt, 1e-3));
      },
    );

    test('circles the goal instead of hovering or flying away', () {
      final flight = PlaneFlight(minOrbitRadius: 80);
      final goal = Vector2(500, 500);
      final radiusLimit = max(80, speed / turnRate * 1.4) * 1.6;
      var farthestLate = 0.0;
      var angleSwept = 0.0;
      Vector2? previous;
      var frame = 0;
      fly(flight, Vector2.zero(), 0, goal, 4000, (position, _) {
        frame++;
        if (frame > 1500) {
          farthestLate = max(farthestLate, position.distanceTo(goal));
          final current = position - goal;
          if (previous != null) {
            var delta =
                atan2(current.y, current.x) - atan2(previous!.y, previous!.x);
            if (delta > pi) delta -= 2 * pi;
            if (delta < -pi) delta += 2 * pi;
            angleSwept += delta;
          }
          previous = current;
        }
      });
      expect(flight.isOrbiting, isTrue);
      expect(farthestLate, lessThan(radiusLimit));
      // Several full laps in the same direction.
      expect(angleSwept.abs(), greaterThan(4 * pi));
    });

    test('with no goal it keeps circling in place', () {
      final flight = PlaneFlight(minOrbitRadius: 80);
      final start = Vector2(300, 300);
      var farthest = 0.0;
      var minMoved = double.infinity;
      fly(flight, start, 0, null, 2000, (position, moved) {
        farthest = max(farthest, position.distanceTo(start));
        minMoved = min(minMoved, moved);
      });
      expect(minMoved, closeTo(speed * dt, 1e-3));
      expect(farthest, lessThan(400));
    });

    test('heads for a new goal once the old orbit is abandoned', () {
      final flight = PlaneFlight(minOrbitRadius: 80);
      var state = fly(flight, Vector2.zero(), 0, Vector2(300, 300), 1500, null);
      final newGoal = Vector2(1500, 300);
      var closest = double.infinity;
      state = fly(flight, state.position, state.facing, newGoal, 1500, (p, _) {
        closest = min(closest, p.distanceTo(newGoal));
      });
      expect(closest, lessThan(200));
    });
  });

  test('capture radar paints at every progress level without throwing', () {
    for (final progress in [0.0, 0.3, 1.0]) {
      final recorder = PictureRecorder();
      paintCaptureRadar(
        Canvas(recorder),
        size: Vector2.all(96),
        color: const Color(0xFF00BCD4),
        progress: progress,
        sweepAngle: 1.2,
        intensity: 1,
        sweeping: true,
        contested: progress > 0.5,
      );
      expect(recorder.endRecording(), isNotNull);
    }
  });
}
