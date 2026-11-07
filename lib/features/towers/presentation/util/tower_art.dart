import 'dart:math';

import 'package:flutter/material.dart';

/// Shared drawing helpers for the tower/building art, so every sprite uses
/// the same shading language: light from the top-left, a dark rim, a small
/// specular glint.

/// A diagonal light-to-dark metal fill over [rect].
Paint metalPaint(
  Rect rect, {
  Color light = const Color(0xFF8995A3),
  Color dark = const Color(0xFF2F363E),
}) => Paint()
  ..shader = LinearGradient(
    colors: [light, dark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(rect);

Paint strokePaint(Color color, double width, {double alpha = 1}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..color = color.withValues(alpha: alpha);

Paint fillPaint(Color color, {double alpha = 1}) =>
    Paint()..color = color.withValues(alpha: alpha);

/// A closed regular polygon with [sides] corners.
Path regularPolygon(Offset center, double radius, int sides, double rotation) {
  final path = Path();
  for (var i = 0; i < sides; i++) {
    final a = rotation + i * 2 * pi / sides;
    final p = Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// A dome/round hull: metal fill, dark rim, bright accent ring and glint.
void paintDome(
  Canvas canvas,
  Offset center,
  double radius, {
  required Color accent,
  Color light = const Color(0xFF7D8997),
  Color dark = const Color(0xFF2A3037),
}) {
  final rect = Rect.fromCircle(center: center, radius: radius);
  canvas.drawCircle(
    center.translate(0.8, 1.2),
    radius,
    fillPaint(Colors.black, alpha: 0.3),
  );
  canvas.drawCircle(center, radius, metalPaint(rect, light: light, dark: dark));
  canvas.drawCircle(center, radius, strokePaint(const Color(0xFF14181C), 1.2));
  canvas.drawCircle(center, radius - 1.6, strokePaint(accent, 1.2, alpha: 0.9));
  paintGlint(
    canvas,
    center.translate(-radius * 0.35, -radius * 0.4),
    radius * 0.22,
  );
}

void paintGlint(Canvas canvas, Offset at, double radius) {
  canvas.drawCircle(at, radius, fillPaint(Colors.white, alpha: 0.55));
}

/// A straight barrel from [from] to [to] with a highlight along its top edge
/// and an optional wider muzzle brake at the tip.
void paintBarrel(
  Canvas canvas, {
  required Offset from,
  required Offset to,
  required double width,
  Color body = const Color(0xFF2B3138),
  Color highlight = const Color(0xFF6F7B88),
  double muzzleWidth = 0,
  Color muzzle = const Color(0xFF1A1E23),
}) {
  final length = (to - from).distance;
  final angle = atan2(to.dy - from.dy, to.dx - from.dx);
  canvas.save();
  canvas.translate(from.dx, from.dy);
  canvas.rotate(angle);
  final rect = Rect.fromLTWH(0, -width / 2, length, width);
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(width / 3)),
    fillPaint(body),
  );
  canvas.drawRect(
    Rect.fromLTWH(1, -width / 2 + 0.4, length - 2, width * 0.22),
    fillPaint(highlight, alpha: 0.7),
  );
  if (muzzleWidth > 0) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(length - 4, -muzzleWidth / 2, 4.5, muzzleWidth),
        const Radius.circular(1),
      ),
      fillPaint(muzzle),
    );
  }
  canvas.restore();
}

/// Small round rivets/bolts at [points].
void paintBolts(Canvas canvas, Iterable<Offset> points, {double radius = 1.3}) {
  for (final p in points) {
    canvas.drawCircle(
      p.translate(0.4, 0.5),
      radius,
      fillPaint(Colors.black, alpha: 0.4),
    );
    canvas.drawCircle(p, radius, fillPaint(const Color(0xFFC3CAD3)));
  }
}

/// Hazard stripes (yellow/black) filling [rect].
void paintHazardStripes(Canvas canvas, Rect rect, {double step = 4}) {
  canvas.save();
  canvas.clipRect(rect);
  canvas.drawRect(rect, fillPaint(const Color(0xFFF2B705)));
  final dark = fillPaint(const Color(0xFF1B1B1B));
  for (var x = rect.left - rect.height; x < rect.right; x += step * 2) {
    canvas.drawPath(
      Path()
        ..moveTo(x, rect.bottom)
        ..lineTo(x + step, rect.bottom)
        ..lineTo(x + step + rect.height, rect.top)
        ..lineTo(x + rect.height, rect.top)
        ..close(),
      dark,
    );
  }
  canvas.restore();
}
