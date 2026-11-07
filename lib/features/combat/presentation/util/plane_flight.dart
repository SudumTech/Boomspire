import 'dart:math';

import 'package:flame/components.dart';

import 'heading_math.dart';

/// One frame of plane movement.
typedef PlaneFlightStep = ({Vector2 position, double facing, Vector2 heading});

/// Flight model for aircraft that must never hover (jets, bombers): they
/// bank toward their goal at a limited turn rate, and once they reach it
/// they keep flying a circle around it - the way C&C Generals aircraft
/// loop over a point instead of stopping in mid-air. With no goal at all
/// they keep circling where they are.
///
/// Facing follows the project convention: `facing = headingAngle + pi / 2`.
class PlaneFlight {
  /// The orbit starts once the plane is within this share of the radius.
  static const _captureFactor = 1.15;

  /// How far ahead (radians) on the circle the plane aims, which keeps it
  /// hugging the circle instead of spiralling.
  static const _orbitLeadRadians = 0.6;

  /// A new goal further than this from the current orbit centre ends the
  /// orbit and sends the plane toward the new point.
  static const _goalShiftTolerance = 30.0;

  final double minOrbitRadius;

  Vector2? _orbitCenter;
  bool _orbiting = false;
  double _orbitDirection = 1;

  PlaneFlight({required this.minOrbitRadius});

  bool get isOrbiting => _orbiting;

  /// Advances the plane by [dt]. [goal] is the point it is headed for (null
  /// = no goal: keep circling).
  PlaneFlightStep step({
    required Vector2 position,
    required double facing,
    required Vector2? goal,
    required double speed,
    required double turnRate,
    required double dt,
  }) {
    final radius = _radiusFor(speed, turnRate);
    final center = _resolveCenter(position, facing, goal, radius);
    _updateOrbitState(position, facing, center, radius, hasGoal: goal != null);

    final desired = _orbiting
        ? _pointOnCircle(position, center, radius)
        : center.clone();
    final newFacing = turnTowardAngle(
      facing,
      atan2(desired.y - position.y, desired.x - position.x) + pi / 2,
      turnRate * dt,
    );
    final headingAngle = newFacing - pi / 2;
    final heading = Vector2(cos(headingAngle), sin(headingAngle));
    return (
      position: position + heading * speed * dt,
      facing: newFacing,
      heading: heading,
    );
  }

  /// Wide enough that the plane's turn rate can actually fly the circle.
  double _radiusFor(double speed, double turnRate) =>
      max(minOrbitRadius, speed / turnRate * 1.4);

  Vector2 _resolveCenter(
    Vector2 position,
    double facing,
    Vector2? goal,
    double radius,
  ) {
    if (goal != null) return goal;
    final existing = _orbitCenter;
    if (existing != null) return existing;
    final headingAngle = facing - pi / 2;
    return position + Vector2(cos(headingAngle), sin(headingAngle)) * radius;
  }

  void _updateOrbitState(
    Vector2 position,
    double facing,
    Vector2 center,
    double radius, {
    required bool hasGoal,
  }) {
    final previous = _orbitCenter;
    final goalMoved =
        previous != null && center.distanceTo(previous) > _goalShiftTolerance;
    if (goalMoved) _orbiting = false;
    _orbitCenter = goalMoved || previous == null ? center.clone() : previous;

    final closeEnough = position.distanceTo(center) <= radius * _captureFactor;
    if (!_orbiting && (closeEnough || !hasGoal)) {
      _orbiting = true;
      _orbitDirection = _directionFor(position, center, facing);
    }
  }

  /// +1 or -1: which way round the circle keeps the plane's current heading.
  double _directionFor(Vector2 position, Vector2 center, double facing) {
    final offset = position - center;
    final headingAngle = facing - pi / 2;
    final cross = offset.x * sin(headingAngle) - offset.y * cos(headingAngle);
    return cross >= 0 ? 1 : -1;
  }

  Vector2 _pointOnCircle(Vector2 position, Vector2 center, double radius) {
    final offset = position - center;
    final angle = offset.length2 < 1e-6 ? 0.0 : atan2(offset.y, offset.x);
    final ahead = angle + _orbitDirection * _orbitLeadRadians;
    return center + Vector2(cos(ahead), sin(ahead)) * radius;
  }
}
