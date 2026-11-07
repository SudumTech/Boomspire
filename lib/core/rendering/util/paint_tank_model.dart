import 'package:flutter/material.dart';

/// Paint for one side's [paintTankModel]/[paintArtilleryModel].
class VehiclePalette {
  final Color light;
  final Color hull;
  final Color dark;
  final Color track;
  final Color accent;

  const VehiclePalette({
    required this.light,
    required this.hull,
    required this.dark,
    this.track = const Color(0xFF1B1D20),
    this.accent = const Color(0xFFFFB300),
  });

  static const ally = VehiclePalette(
    light: Color(0xFF8FA07C),
    hull: Color(0xFF58693F),
    dark: Color(0xFF2C3722),
  );

  static const enemy = VehiclePalette(
    light: Color(0xFFA48A78),
    hull: Color(0xFF6C5040),
    dark: Color(0xFF33241B),
  );
}

const kTankSize = 54.0;
const kArtillerySize = 52.0;

Paint _fill(Color c, [double alpha = 1]) =>
    Paint()..color = c.withValues(alpha: alpha);

Paint _stroke(Color c, double w, [double alpha = 1]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..color = c.withValues(alpha: alpha);

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

/// Top-down main battle tank (barrel up): tracked sides with tread ticks, a
/// wedge-fronted hull with glacis and engine grille, a rounded turret with
/// smoke dischargers and hatch, and a barrel with bore evacuator and muzzle
/// brake. Mirrors `tank_model()` in `tool/lottie_gen/gen_units.py` (the
/// generated Lottie files are what the game normally shows - keep in sync).
void paintTankModel(Canvas canvas, VehiclePalette p) {
  const s = kTankSize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.03 * s, cy + 0.05 * s),
      width: 0.8 * s,
      height: 0.9 * s,
    ),
    _fill(Colors.black, 0.16),
  );

  for (final sx in [-1.0, 1.0]) {
    final x = cx + sx * 0.31 * s;
    _rrect(canvas, Offset(x, cy), 0.2 * s, 0.9 * s, 3.5, _fill(p.track));
    for (var i = 0; i < 13; i++) {
      final y = cy - 0.41 * s + i * 0.068 * s;
      canvas.drawLine(
        Offset(x - 0.085 * s, y),
        Offset(x + 0.085 * s, y),
        _stroke(Colors.black, 0.8, 0.5),
      );
    }
    _rrect(
      canvas,
      Offset(x - sx * 0.05 * s, cy),
      0.03 * s,
      0.84 * s,
      1,
      _fill(Colors.white, 0.1),
    );
  }

  final body = Path()
    ..addPolygon(const [
      Offset(cx - 0.12 * s, cy - 0.44 * s),
      Offset(cx + 0.12 * s, cy - 0.44 * s),
      Offset(cx + 0.22 * s, cy - 0.31 * s),
      Offset(cx + 0.22 * s, cy + 0.4 * s),
      Offset(cx - 0.22 * s, cy + 0.4 * s),
      Offset(cx - 0.22 * s, cy - 0.31 * s),
    ], true);
  canvas.drawPath(
    body,
    _gradient(
      Rect.fromCenter(
        center: const Offset(cx, cy),
        width: 0.44 * s,
        height: 0.84 * s,
      ),
      [p.light, p.hull, p.dark],
    ),
  );
  canvas.drawPath(body, _stroke(p.dark, 1, 0.9));
  canvas.drawPath(
    Path()..addPolygon(const [
      Offset(cx - 0.12 * s, cy - 0.44 * s),
      Offset(cx + 0.12 * s, cy - 0.44 * s),
      Offset(cx + 0.2 * s, cy - 0.32 * s),
      Offset(cx - 0.2 * s, cy - 0.32 * s),
    ], true),
    _fill(Colors.white, 0.16),
  );
  _rrect(
    canvas,
    const Offset(cx, cy + 0.31 * s),
    0.34 * s,
    0.14 * s,
    2,
    _fill(p.dark, 0.55),
  );
  for (var i = 0; i < 4; i++) {
    final y = cy + 0.26 * s + i * 0.035 * s;
    canvas.drawLine(
      Offset(cx - 0.15 * s, y),
      Offset(cx + 0.15 * s, y),
      _stroke(Colors.black, 0.8, 0.5),
    );
  }

  // Barrel, bore evacuator, muzzle brake.
  final barrel = Rect.fromCenter(
    center: const Offset(cx, cy - 0.29 * s),
    width: 0.07 * s,
    height: 0.4 * s,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(barrel, const Radius.circular(1.5)),
    _gradient(barrel, const [
      Color(0xFF4A4F55),
      Color(0xFF1D2125),
    ], horizontal: true),
  );
  _rrect(
    canvas,
    const Offset(cx, cy - 0.27 * s),
    0.1 * s,
    0.05 * s,
    1.5,
    _fill(const Color(0xFF2A2E33)),
  );
  _rrect(
    canvas,
    const Offset(cx, cy - 0.49 * s),
    0.11 * s,
    0.05 * s,
    1,
    _fill(const Color(0xFF14171A)),
  );

  // Coaxial machine gun beside the main barrel (the tank's second weapon).
  _rrect(
    canvas,
    const Offset(cx - 0.075 * s, cy - 0.2 * s),
    0.028 * s,
    0.3 * s,
    1,
    _fill(const Color(0xFF1C1F23)),
  );
  _rrect(
    canvas,
    const Offset(cx - 0.075 * s, cy - 0.36 * s),
    0.04 * s,
    0.03 * s,
    0.8,
    _fill(const Color(0xFF0E1012)),
  );

  // Turret.
  _rrect(
    canvas,
    const Offset(cx, cy + 0.15 * s),
    0.26 * s,
    0.09 * s,
    3,
    _fill(p.dark),
  );
  final turret = Rect.fromCenter(
    center: const Offset(cx, cy - 0.01 * s),
    width: 0.38 * s,
    height: 0.34 * s,
  );
  final turretRRect = RRect.fromRectAndRadius(
    turret,
    const Radius.circular(0.13 * s),
  );
  canvas.drawRRect(
    turretRRect,
    Paint()
      ..shader = LinearGradient(
        colors: [p.light, p.hull],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(turret),
  );
  canvas.drawRRect(turretRRect, _stroke(p.dark, 1, 0.9));
  for (final sx in [-1.0, 1.0]) {
    for (var i = 0; i < 3; i++) {
      _rrect(
        canvas,
        Offset(cx + sx * 0.2 * s, cy - 0.07 * s + i * 0.045 * s),
        0.035 * s,
        0.03 * s,
        0.8,
        _fill(p.dark),
      );
    }
  }
  canvas.drawCircle(
    const Offset(cx + 0.07 * s, cy + 0.04 * s),
    0.05 * s,
    _fill(p.dark),
  );
  canvas.drawCircle(
    const Offset(cx + 0.07 * s, cy + 0.04 * s),
    0.05 * s,
    _stroke(p.light, 0.8, 0.8),
  );
  _rrect(
    canvas,
    const Offset(cx - 0.08 * s, cy - 0.1 * s),
    0.05 * s,
    0.025 * s,
    0.6,
    _fill(const Color(0xFF0E1417)),
  );
}

/// Top-down rocket-artillery truck (launcher forward): six wheels, a small
/// cab, and a raised launcher box with three rocket tubes. Mirrors
/// `artillery_model()` in `tool/lottie_gen/gen_units.py`.
void paintArtilleryModel(Canvas canvas, VehiclePalette p) {
  const s = kArtillerySize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.03 * s, cy + 0.05 * s),
      width: 0.75 * s,
      height: 0.9 * s,
    ),
    _fill(Colors.black, 0.16),
  );
  for (final sx in [-1.0, 1.0]) {
    for (final dy in [-0.28, 0.0, 0.28]) {
      final c = Offset(cx + sx * 0.31 * s, cy + dy * s);
      _rrect(canvas, c, 0.15 * s, 0.22 * s, 3, _fill(p.track));
      _rrect(canvas, c, 0.07 * s, 0.14 * s, 2, _fill(const Color(0xFF50555B)));
    }
  }
  final chassis = Rect.fromCenter(
    center: const Offset(cx, cy + 0.02 * s),
    width: 0.5 * s,
    height: 0.86 * s,
  );
  final chassisR = RRect.fromRectAndRadius(chassis, const Radius.circular(4));
  canvas.drawRRect(chassisR, _gradient(chassis, [p.light, p.hull, p.dark]));
  canvas.drawRRect(chassisR, _stroke(p.dark, 1, 0.9));

  final cab = Rect.fromCenter(
    center: const Offset(cx, cy - 0.32 * s),
    width: 0.4 * s,
    height: 0.2 * s,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(cab, const Radius.circular(4)),
    _gradient(cab, [p.light, p.hull]),
  );
  _rrect(
    canvas,
    const Offset(cx, cy - 0.38 * s),
    0.3 * s,
    0.06 * s,
    2,
    _fill(const Color(0xFF14202B)),
  );

  final box = Rect.fromCenter(
    center: const Offset(cx, cy + 0.12 * s),
    width: 0.42 * s,
    height: 0.4 * s,
  );
  final boxR = RRect.fromRectAndRadius(box, const Radius.circular(4));
  canvas.drawRRect(boxR, _gradient(box, [p.hull, p.dark]));
  canvas.drawRRect(boxR, _stroke(p.dark, 1, 0.9));
  for (final dx in [-0.13 * s, 0.0, 0.13 * s]) {
    final c = Offset(cx + dx, cy + 0.1 * s);
    canvas.drawCircle(c, 0.065 * s, _fill(const Color(0xFF101316)));
    canvas.drawCircle(c, 0.065 * s, _stroke(p.accent, 0.9, 0.8));
    canvas.drawCircle(c, 0.03 * s, _fill(const Color(0xFFE8ECEF)));
    canvas.drawCircle(c, 0.015 * s, _fill(p.accent));
  }
  for (final sx in [-1.0, 1.0]) {
    _rrect(
      canvas,
      Offset(cx + sx * 0.25 * s, cy + 0.36 * s),
      0.07 * s,
      0.07 * s,
      1.5,
      _fill(p.dark),
    );
  }
}
