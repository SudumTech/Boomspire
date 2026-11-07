import 'package:flutter/material.dart';

import 'tower_art.dart';

/// A flagpole with a fluttering pennant on a small round mount - reads as a
/// muster point rather than a weapon, since it never fires.
void paintTrainingCenterTurret(Canvas canvas, Offset center) {
  canvas.drawLine(
    center.translate(0, 6),
    center.translate(0, -19),
    strokePaint(const Color(0xFF2B2F36), 2.2),
  );
  canvas.drawLine(
    center.translate(-0.5, 6),
    center.translate(-0.5, -19),
    strokePaint(Colors.white, 0.6, alpha: 0.4),
  );
  final flag = Path()
    ..moveTo(center.dx + 1, center.dy - 19)
    ..quadraticBezierTo(
      center.dx + 8,
      center.dy - 21,
      center.dx + 13,
      center.dy - 16,
    )
    ..quadraticBezierTo(
      center.dx + 8,
      center.dy - 14,
      center.dx + 1,
      center.dy - 10,
    )
    ..close();
  canvas.drawPath(flag, fillPaint(const Color(0xFF66BB6A)));
  canvas.drawPath(flag, strokePaint(const Color(0xFF2E6B33), 0.9));
  canvas.drawCircle(
    center.translate(0, 7),
    4,
    fillPaint(const Color(0xFF3A444D)),
  );
  canvas.drawCircle(
    center.translate(0, 7),
    4,
    strokePaint(const Color(0xFF66BB6A), 1.1),
  );
  canvas.drawCircle(
    center.translate(0, -19.5),
    1.4,
    fillPaint(const Color(0xFFFFD54A)),
  );
}
