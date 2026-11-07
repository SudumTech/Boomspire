import 'package:flutter/material.dart';

const kHelicopterSize = 46.0;

Paint _fill(Color c, [double a = 1]) => Paint()..color = c.withValues(alpha: a);

Paint _stroke(Color c, double w, [double a = 1]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..color = c.withValues(alpha: a);

Paint _gradient(Rect r, List<Color> colors, {bool horizontal = false}) =>
    Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
        end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
      ).createShader(r);

void _rrect(Canvas c, Offset center, double w, double h, double r, Paint p) =>
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        Radius.circular(r),
      ),
      p,
    );

/// Top-down attack helicopter, nose up (it turns with its heading): tapered
/// fuselage with tandem canopies, a chin gun, stub wings carrying rocket
/// pods, and a tail boom with stabilisers and tail rotor. The main rotor is
/// spun separately at runtime (`RotorComponent`). Mirrors `heli_model()` in
/// `tool/lottie_gen/gen_units.py`.
void paintHelicopterModel(
  Canvas canvas, {
  Color light = const Color(0xFF8C9A86),
  Color hull = const Color(0xFF4F5D4A),
  Color dark = const Color(0xFF262E24),
  Color rocketTip = const Color(0xFFFF7043),
}) {
  const s = kHelicopterSize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.05 * s, cy + 0.08 * s),
      width: 0.7 * s,
      height: 0.82 * s,
    ),
    _fill(Colors.black, 0.16),
  );

  // Tail boom, stabilisers, tail rotor.
  final boom = Path()
    ..addPolygon(const [
      Offset(cx - 0.045 * s, cy + 0.1 * s),
      Offset(cx + 0.045 * s, cy + 0.1 * s),
      Offset(cx + 0.025 * s, cy + 0.47 * s),
      Offset(cx - 0.025 * s, cy + 0.47 * s),
    ], true);
  canvas.drawPath(
    boom,
    _gradient(
      Rect.fromCenter(
        center: const Offset(cx, cy + 0.28 * s),
        width: 0.09 * s,
        height: 0.37 * s,
      ),
      [hull, dark],
      horizontal: true,
    ),
  );
  _rrect(
    canvas,
    const Offset(cx, cy + 0.41 * s),
    0.3 * s,
    0.05 * s,
    1.5,
    _fill(dark),
  );
  _rrect(
    canvas,
    const Offset(cx, cy + 0.455 * s),
    0.025 * s,
    0.1 * s,
    1,
    _fill(const Color(0xFF14171A)),
  );
  canvas.drawCircle(
    const Offset(cx + 0.06 * s, cy + 0.46 * s),
    0.06 * s,
    _stroke(const Color(0xFFB0BEC5), 1.2, 0.5),
  );

  // Stub wings with rocket pods.
  for (final sx in [-1.0, 1.0]) {
    final wing = Path()
      ..addPolygon([
        Offset(cx + sx * 0.09 * s, cy - 0.04 * s),
        Offset(cx + sx * 0.36 * s, cy),
        Offset(cx + sx * 0.36 * s, cy + 0.07 * s),
        Offset(cx + sx * 0.09 * s, cy + 0.1 * s),
      ], true);
    canvas.drawPath(
      wing,
      _gradient(
        Rect.fromCenter(
          center: const Offset(cx, cy + 0.03 * s),
          width: 0.72 * s,
          height: 0.14 * s,
        ),
        [light, hull],
      ),
    );
    canvas.drawPath(wing, _stroke(dark, 0.9, 0.9));
    final pod = Rect.fromCenter(
      center: Offset(cx + sx * 0.3 * s, cy + 0.01 * s),
      width: 0.075 * s,
      height: 0.24 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pod, const Radius.circular(2.5)),
      _gradient(pod, const [
        Color(0xFF4A4F55),
        Color(0xFF1F2327),
      ], horizontal: true),
    );
    canvas.drawCircle(
      Offset(cx + sx * 0.3 * s, cy - 0.1 * s),
      0.022 * s,
      _fill(rocketTip),
    );
    canvas.drawCircle(
      Offset(cx + sx * 0.3 * s, cy + 0.12 * s),
      0.018 * s,
      _fill(const Color(0xFF0E1012)),
    );
  }

  // Fuselage.
  const right = [
    Offset(cx, cy - 0.4 * s),
    Offset(cx + 0.07 * s, cy - 0.3 * s),
    Offset(cx + 0.115 * s, cy - 0.08 * s),
    Offset(cx + 0.1 * s, cy + 0.12 * s),
    Offset(cx + 0.045 * s, cy + 0.26 * s),
  ];
  final left = [
    for (final o in right.sublist(1).reversed) Offset(2 * cx - o.dx, o.dy),
  ];
  final body = Path()..addPolygon([...right, ...left], true);
  canvas.drawPath(
    body,
    _gradient(
      Rect.fromCenter(
        center: const Offset(cx, cy - 0.05 * s),
        width: 0.23 * s,
        height: 0.66 * s,
      ),
      [dark, hull, light, hull, dark],
      horizontal: true,
    ),
  );
  canvas.drawPath(body, _stroke(dark, 1, 0.9));

  // Canopies, intakes, mast, chin gun.
  for (final (y, h) in [(cy - 0.23 * s, 0.12 * s), (cy - 0.07 * s, 0.14 * s)]) {
    _rrect(
      canvas,
      Offset(cx, y),
      0.115 * s,
      h,
      3,
      _fill(const Color(0xFF11161B)),
    );
    _rrect(
      canvas,
      Offset(cx, y),
      0.095 * s,
      h * 0.8,
      2.5,
      _fill(const Color(0xFF2F4350)),
    );
    _rrect(
      canvas,
      Offset(cx - 0.02 * s, y - h * 0.15),
      0.03 * s,
      h * 0.35,
      1,
      _fill(Colors.white, 0.5),
    );
  }
  for (final sx in [-1.0, 1.0]) {
    _rrect(
      canvas,
      Offset(cx + sx * 0.085 * s, cy + 0.1 * s),
      0.04 * s,
      0.1 * s,
      1.5,
      _fill(const Color(0xFF0E1012)),
    );
  }
  canvas.drawCircle(
    const Offset(cx, cy + 0.02 * s),
    0.045 * s,
    _fill(const Color(0xFF14171A)),
  );
  _rrect(
    canvas,
    const Offset(cx, cy - 0.42 * s),
    0.022 * s,
    0.1 * s,
    1,
    _fill(const Color(0xFF0E1012)),
  );
  canvas.drawCircle(
    const Offset(cx, cy - 0.35 * s),
    0.035 * s,
    _fill(const Color(0xFF1B1E22)),
  );
}
