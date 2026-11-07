import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_capture_radar.dart';

/// The radar-style capture indicator drawn around a `ResourceNodeComponent`:
/// a ring marking the capture zone that fades in while a vehicle is in it,
/// a scan line sweeping round while a capture is under way, and a loading
/// arc in the capturing team's colour showing how close the capture is.
class CaptureRadarComponent extends PositionComponent {
  static const _sweepRadiansPerSecond = 3.2;
  static const _fadeSpeed = 4.0;

  /// Colour of the team currently capturing (or last capturing).
  Color color = const Color(0xFFFFFFFF);

  /// Capture progress, 0..1.
  double progress = 0;

  /// Whether a capture is actively progressing right now.
  bool sweeping = false;

  /// Whether rival teams are both inside the zone (no one progresses).
  bool contested = false;

  /// Whether anything should be drawn at all (a vehicle is in the zone, or
  /// a capture is partly done).
  bool shown = false;

  double _intensity = 0;
  double _sweepAngle = 0;

  CaptureRadarComponent({required double radius, required Vector2 center})
    : super(
        size: Vector2.all(radius * 2),
        position: center,
        anchor: Anchor.center,
        priority: 5,
      );

  @override
  void update(double dt) {
    super.update(dt);
    final target = shown ? (sweeping || contested ? 1.0 : 0.55) : 0.0;
    final step = _fadeSpeed * dt;
    _intensity += (target - _intensity).clamp(-step, step);
    if (sweeping) {
      _sweepAngle = (_sweepAngle + _sweepRadiansPerSecond * dt) % (2 * pi);
    }
  }

  @override
  void render(Canvas canvas) => paintCaptureRadar(
    canvas,
    size: size,
    color: color,
    progress: progress,
    sweepAngle: _sweepAngle,
    intensity: _intensity,
    sweeping: sweeping,
    contested: contested,
  );
}
