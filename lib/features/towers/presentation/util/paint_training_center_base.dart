import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFF66BB6A);

/// A barracks seen from above: a flat panelled roof with a ridge line, a
/// door with steps, windows and a painted accent stripe - reads as a muster
/// point rather than a gun emplacement.
void paintTrainingCenterBase(Canvas canvas) {
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(7, 9, 50, 46),
    const Radius.circular(4),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    metalPaint(
      body.outerRect,
      light: const Color(0xFF6E8B6F),
      dark: const Color(0xFF28362A),
    ),
  );
  canvas.drawRRect(body, strokePaint(const Color(0xFF14201A), 2));

  // Roof: two panels split by a ridge.
  const roofTop = Rect.fromLTWH(12, 13, 40, 20);
  const roofBottom = Rect.fromLTWH(12, 33, 40, 14);
  canvas.drawRect(
    roofTop,
    metalPaint(
      roofTop,
      light: const Color(0xFF86A887),
      dark: const Color(0xFF3D5440),
    ),
  );
  canvas.drawRect(
    roofBottom,
    metalPaint(
      roofBottom,
      light: const Color(0xFF4A6A4C),
      dark: const Color(0xFF263A29),
    ),
  );
  canvas.drawLine(
    const Offset(12, 33),
    const Offset(52, 33),
    strokePaint(const Color(0xFF1B2A1D), 1.6),
  );
  for (var x = 18.0; x < 52; x += 8) {
    canvas.drawLine(
      Offset(x, 13),
      Offset(x, 33),
      strokePaint(Colors.black, 0.8, alpha: 0.22),
    );
  }
  canvas.drawRect(
    const Rect.fromLTWH(12, 13, 40, 2.4),
    fillPaint(_accent, alpha: 0.9),
  );

  // Windows along the lower wall.
  for (final x in [16.0, 24.0, 44.0]) {
    final w = Rect.fromLTWH(x, 37, 6, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(w, const Radius.circular(1)),
      fillPaint(const Color(0xFF0F1A12)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(w, const Radius.circular(1)),
      strokePaint(_accent, 0.8, alpha: 0.8),
    );
  }
  // Door and steps.
  const door = Rect.fromLTWH(28, 38, 9, 10);
  canvas.drawRRect(
    RRect.fromRectAndRadius(door, const Radius.circular(1.5)),
    fillPaint(const Color(0xFF0F1A12)),
  );
  canvas.drawRect(
    const Rect.fromLTWH(26, 48, 13, 3),
    fillPaint(const Color(0xFF9AA39B)),
  );
  paintBolts(canvas, const [
    Offset(10.5, 11.5),
    Offset(53.5, 11.5),
    Offset(10.5, 52.5),
    Offset(53.5, 52.5),
  ], radius: 1.1);
}
