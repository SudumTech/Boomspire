import 'dart:math';

/// Shortest signed angle (radians, -pi..pi) from [from] to [to].
double shortestAngleDiff(double from, double to) {
  var diff = (to - from) % (2 * pi);
  if (diff > pi) diff -= 2 * pi;
  if (diff < -pi) diff += 2 * pi;
  return diff;
}

/// [current] rotated toward [desired] by at most [maxStep] radians.
double turnTowardAngle(double current, double desired, double maxStep) {
  final diff = shortestAngleDiff(current, desired);
  return current + diff.clamp(-maxStep, maxStep);
}
