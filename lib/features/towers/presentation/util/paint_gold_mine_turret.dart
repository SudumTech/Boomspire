import 'package:flutter/material.dart';

import 'tower_art.dart';

const _accent = Color(0xFFFFB300);

/// A heap of gold nuggets on an ore cart.
void paintGoldMineTurret(Canvas canvas, Offset center) {
  final cart = Rect.fromCenter(
    center: center.translate(0, 5),
    width: 21,
    height: 11,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      cart.shift(const Offset(0.8, 1.2)),
      const Radius.circular(2),
    ),
    fillPaint(Colors.black, alpha: 0.3),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(cart, const Radius.circular(2)),
    metalPaint(
      cart,
      light: const Color(0xFF7A5B3A),
      dark: const Color(0xFF3A2917),
    ),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(cart, const Radius.circular(2)),
    strokePaint(const Color(0xFF1E140B), 1.2),
  );
  for (final dx in [-6.0, 6.0]) {
    canvas.drawCircle(
      center.translate(dx, 11),
      2.4,
      fillPaint(const Color(0xFF1C1C20)),
    );
    canvas.drawCircle(
      center.translate(dx, 11),
      1,
      fillPaint(const Color(0xFF8A8A92)),
    );
  }
  // Nugget heap.
  const nuggets = [
    Offset(-6, -1),
    Offset(0, -4),
    Offset(6, -1),
    Offset(-3, 0),
    Offset(3, 0),
    Offset(0, -9),
    Offset(-4, -5),
    Offset(4, -5),
  ];
  for (final n in nuggets) {
    final c = center + n;
    canvas.drawCircle(c, 3.4, fillPaint(const Color(0xFFC98600)));
    canvas.drawCircle(c, 3.1, fillPaint(_accent));
    paintGlint(canvas, c.translate(-1, -1.1), 0.9);
  }
}
