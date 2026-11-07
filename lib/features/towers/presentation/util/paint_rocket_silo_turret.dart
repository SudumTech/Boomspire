import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFFF8A00);

/// Open silo hatches with a missile nose rising out of the middle.
void paintRocketSiloTurret(Canvas canvas, Offset center) {
  // Hatch doors folded back.
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + side * 3, center.dy - 3)
        ..lineTo(center.dx + side * 12, center.dy - 10)
        ..lineTo(center.dx + side * 12, center.dy + 6)
        ..lineTo(center.dx + side * 3, center.dy + 8)
        ..close(),
      metalPaint(
        Rect.fromCenter(center: center, width: 24, height: 20),
        light: const Color(0xFF7B8794),
        dark: const Color(0xFF2D343C),
      ),
    );
  }
  canvas.drawCircle(center, 9, fillPaint(const Color(0xFF0F1318)));
  canvas.drawCircle(center, 9, strokePaint(_accent, 1.4));
  // Missile.
  final body = Rect.fromCenter(
    center: center.translate(0, -2),
    width: 8,
    height: 20,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(body, const Radius.circular(3)),
    metalPaint(
      body,
      light: const Color(0xFFE6EAEE),
      dark: const Color(0xFF8C97A3),
    ),
  );
  canvas.drawPath(
    Path()
      ..moveTo(center.dx, center.dy - 18)
      ..lineTo(center.dx + 4, center.dy - 10)
      ..lineTo(center.dx - 4, center.dy - 10)
      ..close(),
    fillPaint(_accent),
  );
  canvas.drawRect(
    Rect.fromCenter(center: center.translate(0, 1), width: 8, height: 2.4),
    fillPaint(_accent, alpha: 0.9),
  );
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + side * 4, center.dy + 3)
        ..lineTo(center.dx + side * 8, center.dy + 8)
        ..lineTo(center.dx + side * 4, center.dy + 7)
        ..close(),
      fillPaint(const Color(0xFF3B424C)),
    );
  }
}
