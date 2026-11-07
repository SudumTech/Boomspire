import 'dart:math';

import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF00E5FF);

/// A tilted twin-missile launcher rail with a rotating search radar - a
/// dedicated long-range AA site.
void paintSamTurret(Canvas canvas, Offset center) {
  // Launcher box.
  final box = Rect.fromCenter(
    center: center.translate(0, 5),
    width: 15,
    height: 12,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(box, const Radius.circular(2.5)),
    metalPaint(
      box,
      light: const Color(0xFF4E7077),
      dark: const Color(0xFF1B2C30),
    ),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(box, const Radius.circular(2.5)),
    strokePaint(const Color(0xFF0F181B), 1.1),
  );
  // Two missiles on rails, tilted skyward.
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(-0.3);
  for (final dx in [-3.6, 3.6]) {
    final m = Rect.fromCenter(center: Offset(dx, -13), width: 4.6, height: 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(m, const Radius.circular(2.3)),
      metalPaint(
        m,
        light: const Color(0xFFEEF2F5),
        dark: const Color(0xFF99A5B1),
      ),
    );
    canvas.drawPath(
      Path()
        ..moveTo(dx, -27)
        ..lineTo(dx + 2.3, -23)
        ..lineTo(dx - 2.3, -23)
        ..close(),
      fillPaint(const Color(0xFFFF6B35)),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(dx, -8), width: 4.6, height: 1.6),
      fillPaint(_accent),
    );
  }
  canvas.restore();
  // Search radar.
  canvas.save();
  canvas.translate(center.dx - 8, center.dy + 9);
  canvas.rotate(-pi / 6);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 9, height: 2.4),
      const Radius.circular(1),
    ),
    fillPaint(const Color(0xFF3A424C)),
  );
  canvas.restore();
  canvas.drawCircle(
    center.translate(0, 3),
    4,
    fillPaint(const Color(0xFF16282B)),
  );
  canvas.drawCircle(center.translate(0, 3), 4, strokePaint(_accent, 1.2));
}
