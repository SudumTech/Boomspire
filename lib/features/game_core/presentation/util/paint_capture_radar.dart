import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Warning colour of the zone ring while two teams contest a node.
const _contestedColor = Color(0xFFFFB300);

const _sweepTrailSegments = 16;
const _sweepTrailSegmentRadians = 0.07;

/// Paints a radar-style capture indicator centred in [size]: the capture
/// zone ring with range rings and cross-hairs, a loading sector that fills
/// clockwise from the top as [progress] (0..1) grows, and - while [sweeping]
/// - a rotating scan line with a fading trail at [sweepAngle]. [intensity]
/// (0..1) fades the whole thing in and out.
void paintCaptureRadar(
  Canvas canvas, {
  required Vector2 size,
  required Color color,
  required double progress,
  required double sweepAngle,
  required double intensity,
  required bool sweeping,
  required bool contested,
}) {
  if (intensity <= 0) return;
  final center = Offset(size.x / 2, size.y / 2);
  final radius = size.x / 2 - 2;
  final rect = Rect.fromCircle(center: center, radius: radius);
  final tone = contested ? _contestedColor : color;

  canvas.drawCircle(
    center,
    radius,
    Paint()..color = tone.withValues(alpha: 0.08 * intensity),
  );
  _paintGrid(canvas, center, radius, tone, intensity);

  if (progress > 0) {
    canvas.drawArc(
      rect,
      -pi / 2,
      progress * 2 * pi,
      true,
      Paint()..color = color.withValues(alpha: 0.22 * intensity),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      progress * 2 * pi,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.95 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  if (sweeping) {
    _paintSweep(canvas, center, rect, radius, color, sweepAngle, intensity);
  }
}

void _paintGrid(
  Canvas canvas,
  Offset center,
  double radius,
  Color tone,
  double intensity,
) {
  final line = Paint()
    ..color = tone.withValues(alpha: 0.4 * intensity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  canvas.drawCircle(center, radius, line);
  canvas.drawCircle(center, radius * 0.5, line..strokeWidth = 1);
  for (var i = 0; i < 4; i++) {
    final a = i * pi / 2;
    canvas.drawLine(
      center + Offset(cos(a), sin(a)) * (radius * 0.2),
      center + Offset(cos(a), sin(a)) * radius,
      line,
    );
  }
}

void _paintSweep(
  Canvas canvas,
  Offset center,
  Rect rect,
  double radius,
  Color color,
  double sweepAngle,
  double intensity,
) {
  for (var k = 0; k < _sweepTrailSegments; k++) {
    final fade = 1 - k / _sweepTrailSegments;
    canvas.drawArc(
      rect,
      sweepAngle - (k + 1) * _sweepTrailSegmentRadians,
      _sweepTrailSegmentRadians,
      true,
      Paint()..color = color.withValues(alpha: 0.4 * fade * intensity),
    );
  }
  canvas.drawLine(
    center,
    center + Offset(cos(sweepAngle), sin(sweepAngle)) * radius,
    Paint()
      ..color = color.withValues(alpha: 0.95 * intensity)
      ..strokeWidth = 2,
  );
}
