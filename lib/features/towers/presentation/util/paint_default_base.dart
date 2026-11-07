import 'dart:math';

import 'package:flutter/material.dart';

import 'tower_art.dart';

/// The armoured emplacement every combat tower stands on: an octagonal
/// concrete pad with bevel and rivets, an inner armour ring, a recessed
/// turret socket and four accent chevrons that carry the tower's colour.
void paintDefaultBase(Canvas canvas, Color accent) {
  const center = Offset(32, 32);
  final pad = regularPolygon(center, 29.5, 8, pi / 8);

  canvas.drawShadow(pad, const Color(0xFF000000), 4, false);
  canvas.drawPath(
    pad,
    metalPaint(
      Rect.fromCircle(center: center, radius: 30),
      light: const Color(0xFF909AA6),
      dark: const Color(0xFF353C45),
    ),
  );
  canvas.drawPath(pad, strokePaint(const Color(0xFF1B2026), 2));
  canvas.drawPath(
    regularPolygon(center, 26, 8, pi / 8),
    strokePaint(Colors.white, 1, alpha: 0.16),
  );

  paintBolts(canvas, [
    for (var i = 0; i < 8; i++)
      center +
          Offset(cos(pi / 8 + i * pi / 4), sin(pi / 8 + i * pi / 4)) * 24.5,
  ]);

  // Inner armour ring.
  final ring = Rect.fromCircle(center: center, radius: 19);
  canvas.drawCircle(
    center,
    19,
    metalPaint(
      ring,
      light: const Color(0xFF626D7A),
      dark: const Color(0xFF242A31),
    ),
  );
  canvas.drawCircle(center, 19, strokePaint(accent, 2, alpha: 0.9));
  canvas.drawCircle(center, 14.5, fillPaint(const Color(0xFF1B2026)));
  canvas.drawCircle(center, 14.5, strokePaint(Colors.black, 1, alpha: 0.6));

  // Turret socket.
  canvas.drawCircle(center, 10.5, fillPaint(const Color(0xFF0F1318)));
  canvas.drawCircle(center, 10.5, strokePaint(accent, 1.4));

  // Accent chevrons on the diagonals.
  for (var k = 0; k < 4; k++) {
    final a = pi / 4 + k * pi / 2;
    final tip = center + Offset(cos(a), sin(a)) * 25;
    final base1 = center + Offset(cos(a - 0.2), sin(a - 0.2)) * 21;
    final base2 = center + Offset(cos(a + 0.2), sin(a + 0.2)) * 21;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(base1.dx, base1.dy)
        ..lineTo(base2.dx, base2.dy)
        ..close(),
      fillPaint(accent, alpha: 0.85),
    );
  }
}
