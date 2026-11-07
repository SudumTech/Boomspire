import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFB0BEC5);

/// A gantry crane arm with a hanging hook over the assembly bay.
void paintWarFactoryTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 4), width: 9, height: 9),
      const Radius.circular(2),
    ),
    fillPaint(const Color(0xFF3A444D)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 4), width: 9, height: 9),
      const Radius.circular(2),
    ),
    strokePaint(_accent, 1),
  );
  paintBarrel(
    canvas,
    from: center.translate(0, 4),
    to: center.translate(0, -17),
    width: 3.2,
    body: const Color(0xFF59646E),
    highlight: const Color(0xFFB9C4CD),
  );
  paintBarrel(
    canvas,
    from: center.translate(-9, -16),
    to: center.translate(11, -16),
    width: 3,
    body: const Color(0xFF59646E),
    highlight: const Color(0xFFB9C4CD),
  );
  canvas.drawLine(
    center.translate(8, -16),
    center.translate(8, -7),
    strokePaint(const Color(0xFF1F2429), 1),
  );
  canvas.drawPath(
    Path()..addArc(
      Rect.fromCenter(center: center.translate(8, -5.5), width: 5, height: 5),
      0,
      4.2,
    ),
    strokePaint(const Color(0xFFF2B705), 1.4),
  );
}
