import 'dart:math';

import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF42A5F5);

/// A glowing reactor core ringed by coils with a lightning bolt.
void paintPowerPlantTurret(Canvas canvas, Offset center) {
  canvas.drawCircle(
    center,
    14,
    fillPaint(_accent, alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.drawCircle(center, 11, fillPaint(const Color(0xFF14181C)));
  for (var i = 0; i < 8; i++) {
    final a = i * pi / 4;
    canvas.drawCircle(
      center.translate(10 * cos(a), 10 * sin(a)),
      1.7,
      fillPaint(_accent, alpha: 0.9),
    );
  }
  canvas.drawCircle(center, 8, metalPaintForCore(center));
  canvas.drawCircle(center, 8, strokePaint(_accent, 1.4));
  final bolt = Path()
    ..moveTo(center.dx + 2, center.dy - 8)
    ..lineTo(center.dx - 4, center.dy + 1)
    ..lineTo(center.dx - 0.5, center.dy + 1)
    ..lineTo(center.dx - 2, center.dy + 8)
    ..lineTo(center.dx + 4.5, center.dy - 2)
    ..lineTo(center.dx + 0.8, center.dy - 2)
    ..close();
  canvas.drawPath(bolt, fillPaint(const Color(0xFFFFF176)));
  canvas.drawPath(bolt, strokePaint(const Color(0xFFFFB300), 0.7));
}

Paint metalPaintForCore(Offset center) => Paint()
  ..shader = const RadialGradient(
    colors: [Color(0xFF90CAF9), Color(0xFF1565C0)],
  ).createShader(Rect.fromCircle(center: center, radius: 8));
