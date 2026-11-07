import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFB0BEC5);

/// A vehicle hangar from above: sawtooth skylight roof, a smokestack and a
/// big roll-up bay door under hazard stripes.
void paintWarFactoryBase(Canvas canvas) {
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(4, 8, 56, 50),
    const Radius.circular(3),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    metalPaint(
      body.outerRect,
      light: const Color(0xFF7C8A95),
      dark: const Color(0xFF2B333A),
    ),
  );
  canvas.drawRRect(body, strokePaint(const Color(0xFF161B20), 2));

  // Sawtooth roof ridges.
  for (var i = 0; i < 4; i++) {
    final y = 11.0 + i * 8;
    canvas.drawRect(
      Rect.fromLTWH(7, y, 50, 5),
      fillPaint(const Color(0xFF9AA8B3)),
    );
    canvas.drawRect(
      Rect.fromLTWH(7, y + 5, 50, 2.6),
      fillPaint(const Color(0xFF3A444D)),
    );
    canvas.drawRect(
      Rect.fromLTWH(7, y, 50, 1.2),
      fillPaint(Colors.white, alpha: 0.4),
    );
  }
  // Smokestack.
  canvas.drawCircle(
    const Offset(52, 16),
    4.4,
    fillPaint(const Color(0xFF1F2429)),
  );
  canvas.drawCircle(const Offset(52, 16), 4.4, strokePaint(_accent, 1.2));
  canvas.drawCircle(
    const Offset(52, 16),
    2,
    fillPaint(const Color(0xFF0C0F12)),
  );

  // Bay door with hazard header.
  paintHazardStripes(canvas, const Rect.fromLTWH(16, 40, 32, 3.4));
  const door = Rect.fromLTWH(16, 43.4, 32, 13);
  canvas.drawRect(door, fillPaint(const Color(0xFF12171B)));
  for (var y = 46.0; y < 56; y += 3) {
    canvas.drawLine(
      Offset(17, y),
      Offset(47, y),
      strokePaint(_accent, 0.9, alpha: 0.5),
    );
  }
  paintBolts(canvas, const [
    Offset(7, 11),
    Offset(57, 11),
    Offset(7, 55),
    Offset(57, 55),
  ], radius: 1.1);
}
