import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `HumanLimbsComponent`'s scissoring leg strokes plus (while
/// [fireFlash] is active) a brief muzzle flash at the weapon tip.
void paintHumanLimbs(
  Canvas canvas, {
  required Vector2 size,
  required Color accent,
  required double phase,
  required double fireFlash,
  required double fireFlashDuration,
}) {
  // Flame renders every component in a top-left-origin 0..size box
  // regardless of anchor, so "centered on the body" requires explicitly
  // offsetting by half the hull size here rather than drawing around
  // (0, 0) - otherwise the limbs render a half-hull-width/height away
  // from the actual torso.
  final cx = size.x / 2;
  final cy = size.y / 2;
  final legSwing = sin(phase) * size.y * 0.16;
  final legPaint = Paint()
    ..color = const Color(0xFF2A2D31)
    ..strokeWidth = size.x * 0.09
    ..strokeCap = StrokeCap.round;
  final hipY = cy + size.y * 0.28;
  canvas.drawLine(
    Offset(cx - size.x * 0.1, hipY),
    Offset(cx - size.x * 0.1 + legSwing * 0.3, hipY + size.y * 0.34),
    legPaint,
  );
  canvas.drawLine(
    Offset(cx + size.x * 0.1, hipY),
    Offset(cx + size.x * 0.1 - legSwing * 0.3, hipY + size.y * 0.34),
    legPaint,
  );

  if (fireFlash > 0) {
    // Muzzle flash at the tip of the weapon (the arms themselves are part of
    // the sprite).
    final fade = (fireFlash / fireFlashDuration).clamp(0.0, 1.0);
    final muzzle = Offset(cx + size.x * 0.05, cy - size.y * 0.5);
    canvas.drawCircle(
      muzzle,
      size.x * 0.1,
      Paint()
        ..color = accent.withValues(alpha: 0.55 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      muzzle,
      size.x * 0.045,
      Paint()..color = const Color(0xFFFFF3C4).withValues(alpha: fade),
    );
  }
}
