import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF1DE9B6);

/// A satellite dish on a pedestal with a pulsing sensor core.
void paintTechLabTurret(Canvas canvas, Offset center) {
  final dish = Rect.fromCenter(
    center: center.translate(-1, -2),
    width: 22,
    height: 15,
  );
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(-0.5);
  canvas.translate(-center.dx, -center.dy);
  canvas.drawOval(
    dish.shift(const Offset(0.8, 1.2)),
    fillPaint(Colors.black, alpha: 0.3),
  );
  canvas.drawOval(
    dish,
    metalPaint(
      dish,
      light: const Color(0xFFE2EAEE),
      dark: const Color(0xFF7F8E99),
    ),
  );
  canvas.drawOval(dish.deflate(3), strokePaint(const Color(0xFF55646E), 1));
  canvas.drawOval(dish, strokePaint(const Color(0xFF14181C), 1.2));
  canvas.restore();
  // Feed horn.
  canvas.drawLine(
    center.translate(-1, -2),
    center.translate(7, -11),
    strokePaint(const Color(0xFF3A444D), 1.6),
  );
  canvas.drawCircle(center.translate(7, -11), 2, fillPaint(_accent));
  paintDome(canvas, center.translate(-1, 7), 5, accent: _accent);
}
