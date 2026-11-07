import 'package:flutter/material.dart';

import 'paint_viewhole.dart';
import 'tower_art.dart';

const _accent = Color(0xFFFFC107);

/// A heavy cannon: thick barrel with a muzzle brake and recoil sleeve on a
/// squat armoured turret.
void paintCannonTurret(Canvas canvas, Offset center) {
  paintBarrel(
    canvas,
    from: center.translate(0, -2),
    to: center.translate(0, -23),
    width: 6,
    muzzleWidth: 9,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -8), width: 9, height: 7),
      const Radius.circular(2),
    ),
    fillPaint(const Color(0xFF454E58)),
  );
  paintDome(canvas, center, 11, accent: _accent);
  canvas.drawCircle(
    center.translate(4, 3),
    2.6,
    fillPaint(const Color(0xFF14181C)),
  );
  canvas.drawCircle(
    center.translate(4, 3),
    2.6,
    strokePaint(_accent, 0.8, alpha: 0.8),
  );
  paintViewhole(canvas, center.translate(-3, 4));
}
