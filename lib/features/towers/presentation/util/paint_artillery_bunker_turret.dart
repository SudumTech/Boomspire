import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF8D6E63);

/// A long-barrelled howitzer behind an armoured gun shield.
void paintArtilleryBunkerTurret(Canvas canvas, Offset center) {
  paintBarrel(
    canvas,
    from: center.translate(0, 0),
    to: center.translate(0, -25),
    width: 5,
    body: const Color(0xFF3A3530),
    highlight: const Color(0xFF8A7F77),
    muzzleWidth: 7.4,
  );
  // Recoil cylinders.
  for (final dx in [-3.8, 3.8]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, -7),
          width: 2.6,
          height: 11,
        ),
        const Radius.circular(1.3),
      ),
      fillPaint(const Color(0xFF59514A)),
    );
  }
  // Gun shield.
  final shield = Path()
    ..moveTo(center.dx - 12, center.dy - 4)
    ..lineTo(center.dx + 12, center.dy - 4)
    ..lineTo(center.dx + 10, center.dy + 9)
    ..lineTo(center.dx - 10, center.dy + 9)
    ..close();
  canvas.drawPath(
    shield,
    metalPaint(
      Rect.fromCenter(center: center, width: 24, height: 14),
      light: const Color(0xFF8C8178),
      dark: const Color(0xFF3B3631),
    ),
  );
  canvas.drawPath(shield, strokePaint(const Color(0xFF14181C), 1.2));
  canvas.drawLine(
    center.translate(-9, 5),
    center.translate(9, 5),
    strokePaint(_accent, 1.2),
  );
  paintBolts(canvas, [
    center.translate(-8, -1),
    center.translate(8, -1),
  ], radius: 1.1);
}
