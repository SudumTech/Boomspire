import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFFF3D9A);

/// A prism emitter on charging coils, glowing at the lens.
void paintLaserTurret(Canvas canvas, Offset center) {
  // Focusing prongs.
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + side * 3, center.dy - 4)
        ..lineTo(center.dx + side * 7, center.dy - 18)
        ..lineTo(center.dx + side * 4.5, center.dy - 19)
        ..lineTo(center.dx + side * 1.6, center.dy - 5)
        ..close(),
      fillPaint(const Color(0xFF3B424C)),
    );
  }
  // Glowing lens at the tip.
  canvas.drawCircle(
    center.translate(0, -20),
    7,
    fillPaint(_accent, alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  canvas.drawCircle(
    center.translate(0, -19),
    3.2,
    fillPaint(const Color(0xFF2A1220)),
  );
  canvas.drawCircle(center.translate(0, -19), 2.1, fillPaint(_accent));
  paintGlint(canvas, center.translate(-0.7, -19.8), 0.7);
  // Energy beam core.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -9), width: 3, height: 13),
      const Radius.circular(1.5),
    ),
    fillPaint(_accent, alpha: 0.85),
  );
  paintDome(
    canvas,
    center,
    8.8,
    accent: _accent,
    light: const Color(0xFF6C6A7C),
    dark: const Color(0xFF29262F),
  );
  canvas.drawCircle(center, 3.2, fillPaint(_accent, alpha: 0.9));
}
