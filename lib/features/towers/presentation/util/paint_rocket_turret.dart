import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFFF6B35);

/// A boxy 2x2 rocket pod: four tubes with warheads showing.
void paintRocketTurret(Canvas canvas, Offset center) {
  final pod = Rect.fromCenter(
    center: center.translate(0, -5),
    width: 21,
    height: 26,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      pod.shift(const Offset(0.8, 1.2)),
      const Radius.circular(3),
    ),
    fillPaint(Colors.black, alpha: 0.3),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(pod, const Radius.circular(3)),
    metalPaint(
      pod,
      light: const Color(0xFF7A8794),
      dark: const Color(0xFF2B3138),
    ),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(pod, const Radius.circular(3)),
    strokePaint(const Color(0xFF14181C), 1.2),
  );
  for (final dx in [-4.8, 4.8]) {
    for (final dy in [-11.0, -2.0]) {
      final c = center.translate(dx, dy);
      canvas.drawCircle(c, 3.6, fillPaint(const Color(0xFF0F1318)));
      canvas.drawCircle(c, 3.6, strokePaint(_accent, 1));
      canvas.drawCircle(c, 1.7, fillPaint(_accent, alpha: 0.95));
      paintGlint(canvas, c.translate(-0.8, -0.8), 0.6);
    }
  }
  paintDome(canvas, center.translate(0, 6), 7.5, accent: _accent);
}
