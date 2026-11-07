import 'dart:math';

import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF7C4DFF);

/// Twin flak barrels splayed in a V on an elevated mount with a radar bar.
void paintAntiAirTurret(Canvas canvas, Offset center) {
  for (final side in [-1.0, 1.0]) {
    paintBarrel(
      canvas,
      from: center.translate(side * 3.5, -1),
      to: center.translate(side * 11, -21),
      width: 3.4,
      muzzleWidth: 5.2,
    );
    canvas.drawCircle(
      center.translate(side * 11, -21),
      1.4,
      fillPaint(_accent),
    );
  }
  // Radar bar behind the mount.
  canvas.save();
  canvas.translate(center.dx, center.dy + 9);
  canvas.rotate(-pi / 14);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 17, height: 3.4),
      const Radius.circular(1.5),
    ),
    fillPaint(const Color(0xFF3A424C)),
  );
  canvas.drawRect(
    Rect.fromCenter(center: Offset.zero, width: 15, height: 0.9),
    fillPaint(_accent, alpha: 0.9),
  );
  canvas.restore();
  paintDome(canvas, center, 8.8, accent: _accent);
}
