import 'package:flutter/material.dart';

import 'paint_viewhole.dart';
import 'tower_art.dart';

const _accent = Color(0xFF4FC3F7);

/// Twin-barrel machine gun on a domed mount with an ammo box.
void paintMachineGunTurret(Canvas canvas, Offset center) {
  // Ammo box on the left flank.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(-10, 3), width: 7, height: 11),
      const Radius.circular(1.5),
    ),
    fillPaint(const Color(0xFF4B5A3A)),
  );
  canvas.drawRect(
    Rect.fromCenter(center: center.translate(-10, 3), width: 7, height: 1.4),
    fillPaint(const Color(0xFF2E3924)),
  );
  for (final dx in [-2.6, 2.6]) {
    paintBarrel(
      canvas,
      from: center.translate(dx, -3),
      to: center.translate(dx, -22),
      width: 3,
      muzzleWidth: 4.8,
    );
  }
  paintDome(canvas, center, 9.5, accent: _accent);
  paintViewhole(canvas, center.translate(0, 3));
}
