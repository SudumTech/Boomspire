import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFFFD54A);

/// A comms mast with crossbars, a radar dome and a blinking beacon.
void paintCommandPostTurret(Canvas canvas, Offset center) {
  canvas.drawLine(
    center.translate(0, 4),
    center.translate(0, -20),
    strokePaint(const Color(0xFF3A3D2C), 2.2),
  );
  for (final dy in [-8.0, -14.0]) {
    final half = dy == -8.0 ? 8.0 : 5.0;
    canvas.drawLine(
      center.translate(-half, dy),
      center.translate(half, dy),
      strokePaint(const Color(0xFF3A3D2C), 1.6),
    );
    canvas.drawCircle(center.translate(-half, dy), 1.3, fillPaint(_accent));
    canvas.drawCircle(center.translate(half, dy), 1.3, fillPaint(_accent));
  }
  canvas.drawCircle(
    center.translate(0, -21),
    3,
    fillPaint(const Color(0xFFE53935)),
  );
  canvas.drawCircle(
    center.translate(0, -21),
    5,
    fillPaint(const Color(0xFFE53935), alpha: 0.25),
  );
  paintDome(
    canvas,
    center.translate(0, 6),
    8,
    accent: _accent,
    light: const Color(0xFFB9B58C),
    dark: const Color(0xFF4A482B),
  );
}
