import 'dart:math';
import 'dart:ui';

/// Paints one small bird seen from above, flying toward +x: a soft body, a
/// head and two wings that beat by [flap] (-1..1), plus a faint ground
/// shadow. [scale] and [opacity] vary per bird so a flock never looks cloned.
void paintBird(
  Canvas canvas, {
  required double flap,
  required double scale,
  required double opacity,
}) {
  canvas.save();
  canvas.scale(scale);

  // Shadow cast on the ground far below.
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(6, 16), width: 11, height: 4),
    Paint()..color = const Color(0xFF000000).withValues(alpha: 0.1 * opacity),
  );

  final body = Paint()
    ..color = const Color(0xFF2A2C30).withValues(alpha: opacity);
  final wing = Paint()
    ..color = const Color(0xFF3A3D43).withValues(alpha: opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round;

  // Wings sweep back from the shoulders; their angle follows the beat.
  final spread = 0.9 + flap * 0.65;
  for (final side in [-1.0, 1.0]) {
    final tip = Offset(-3 - cos(spread) * 2, side * sin(spread) * 8);
    canvas.drawLine(const Offset(0, 0), tip, wing);
    canvas.drawLine(tip, tip.translate(-2.5, side * 1.2), wing);
  }
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 8, height: 3.4),
    body,
  );
  canvas.drawCircle(const Offset(4.2, 0), 1.4, body);
  canvas.drawPath(
    Path()
      ..moveTo(5.4, -0.5)
      ..lineTo(7, 0)
      ..lineTo(5.4, 0.5)
      ..close(),
    Paint()..color = const Color(0xFFC98A3C).withValues(alpha: opacity),
  );
  canvas.restore();
}
