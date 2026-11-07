import 'package:flutter/material.dart';

/// Which kit an infantryman carries.
enum SoldierRole { rifle, heavy, antiTank, antiAir }

/// Paint for one side's [paintSoldierModel].
class SoldierPalette {
  final Color light;
  final Color hull;
  final Color dark;

  const SoldierPalette({
    required this.light,
    required this.hull,
    required this.dark,
  });

  static const ally = SoldierPalette(
    light: Color(0xFF8FA07C),
    hull: Color(0xFF58693F),
    dark: Color(0xFF2C3722),
  );

  static const enemy = SoldierPalette(
    light: Color(0xFFA48A78),
    hull: Color(0xFF6C5040),
    dark: Color(0xFF33241B),
  );
}

/// Sprite canvas edge for [role].
double soldierSize(SoldierRole role) => role == SoldierRole.heavy ? 60 : 48;

Paint _fill(Color c, [double a = 1]) => Paint()..color = c.withValues(alpha: a);

Paint _stroke(Color c, double w, [double a = 1]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
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

/// Top-down infantryman facing up: backpack, broad shoulders, arms bringing
/// the weapon forward and a helmet with chin strap and night-vision mount.
/// The legs are animated separately at runtime (`HumanLimbsComponent`).
/// Mirrors `soldier_model()` in `tool/lottie_gen/gen_units.py` (the generated
/// Lottie files are what the game normally shows - keep both in sync).
void paintSoldierModel(Canvas canvas, SoldierPalette p, SoldierRole role) {
  final heavy = role == SoldierRole.heavy;
  final s = soldierSize(role);
  final cx = s / 2;
  final cy = s / 2;
  final k = heavy ? 1.18 : 1.0;
  const skin = Color(0xFFC9A27C);

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(cx + 0.03 * s, cy + 0.05 * s),
      width: 0.56 * s,
      height: 0.46 * s,
    ),
    _fill(Colors.black, 0.2),
  );

  // Backpack.
  final pack = Rect.fromCenter(
    center: Offset(cx, cy + 0.13 * s),
    width: 0.27 * s * k,
    height: 0.22 * s,
  );
  final packR = RRect.fromRectAndRadius(pack, const Radius.circular(3));
  canvas.drawRRect(packR, _gradient(pack, [p.hull, p.dark]));
  canvas.drawRRect(packR, _stroke(p.dark, 0.9, 0.9));
  for (final dx in [-0.05 * s, 0.05 * s]) {
    canvas.drawLine(
      Offset(cx + dx, cy + 0.06 * s),
      Offset(cx + dx, cy + 0.2 * s),
      _stroke(p.dark, 1, 0.8),
    );
  }

  // Launcher tubes for the specialists.
  if (role == SoldierRole.antiTank) {
    final tube = Rect.fromCenter(
      center: Offset(cx + 0.14 * s, cy - 0.12 * s),
      width: 0.075 * s,
      height: 0.7 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tube, const Radius.circular(2.5)),
      _gradient(tube, const [
        Color(0xFF6A7078),
        Color(0xFF2C3036),
      ], horizontal: true),
    );
    canvas.drawPath(
      Path()..addPolygon([
        Offset(cx + 0.14 * s, cy - 0.5 * s),
        Offset(cx + 0.175 * s, cy - 0.44 * s),
        Offset(cx + 0.105 * s, cy - 0.44 * s),
      ], true),
      _fill(const Color(0xFFFF7043)),
    );
    _rrect(
      canvas,
      Offset(cx + 0.14 * s, cy + 0.22 * s),
      0.1 * s,
      0.05 * s,
      1.5,
      _fill(const Color(0xFF1A1C20)),
    );
  }
  if (role == SoldierRole.antiAir) {
    final tube = Rect.fromCenter(
      center: Offset(cx + 0.13 * s, cy - 0.1 * s),
      width: 0.07 * s,
      height: 0.62 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tube, const Radius.circular(2.5)),
      _gradient(tube, const [
        Color(0xFFB9C4CD),
        Color(0xFF59646E),
      ], horizontal: true),
    );
    canvas.drawPath(
      Path()..addPolygon([
        Offset(cx + 0.13 * s, cy - 0.46 * s),
        Offset(cx + 0.165 * s, cy - 0.4 * s),
        Offset(cx + 0.095 * s, cy - 0.4 * s),
      ], true),
      _fill(const Color(0xFF263238)),
    );
    _rrect(
      canvas,
      Offset(cx + 0.205 * s, cy - 0.06 * s),
      0.05 * s,
      0.14 * s,
      1.5,
      _fill(const Color(0xFF1A1C20)),
    );
    canvas.drawCircle(
      Offset(cx + 0.205 * s, cy - 0.1 * s),
      0.022 * s,
      _fill(const Color(0xFF29B6F6)),
    );
  }

  // Shoulders.
  final shoulders = Rect.fromCenter(
    center: Offset(cx, cy),
    width: 0.56 * s * k,
    height: 0.24 * s * k,
  );
  canvas.drawOval(shoulders, _gradient(shoulders, [p.light, p.hull, p.dark]));
  canvas.drawOval(shoulders, _stroke(p.dark, 1, 0.9));
  if (heavy) {
    _rrect(
      canvas,
      Offset(cx, cy),
      0.26 * s,
      0.2 * s,
      4,
      _fill(const Color(0xFF222A1B)),
    );
    for (final sx in [-1.0, 1.0]) {
      _rrect(
        canvas,
        Offset(cx + sx * 0.25 * s * k, cy - 0.04 * s),
        0.1 * s,
        0.1 * s,
        3,
        _fill(const Color(0xFFB71C1C)),
      );
    }
  }

  // Arms with gloved hands.
  for (final (from, to) in [
    (
      Offset(cx - 0.25 * s * k, cy - 0.01 * s),
      Offset(cx - 0.07 * s, cy - 0.25 * s),
    ),
    (
      Offset(cx + 0.24 * s * k, cy - 0.01 * s),
      Offset(cx + 0.1 * s, cy - 0.15 * s),
    ),
  ]) {
    canvas.drawLine(from, to, _stroke(p.hull, 0.085 * s));
    canvas.drawLine(from, to, _stroke(p.dark, 0.085 * s, 0.25));
    canvas.drawCircle(to, 0.04 * s, _fill(skin));
  }

  // Rifle / cannon.
  if (role == SoldierRole.rifle || heavy) {
    final barrelW = heavy ? 0.075 * s : 0.05 * s;
    _rrect(
      canvas,
      Offset(cx + 0.05 * s, cy - 0.31 * s),
      barrelW,
      0.34 * s,
      1.5,
      _fill(const Color(0xFF1C1F23)),
    );
    final receiver = Rect.fromCenter(
      center: Offset(cx + 0.05 * s, cy - 0.16 * s),
      width: 0.075 * s,
      height: 0.2 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(receiver, const Radius.circular(2)),
      _gradient(receiver, const [Color(0xFF3C4147), Color(0xFF1A1C1F)]),
    );
    _rrect(
      canvas,
      Offset(cx + 0.05 * s, cy - 0.46 * s),
      barrelW * 1.5,
      0.045 * s,
      1,
      _fill(const Color(0xFF0E1012)),
    );
    _rrect(
      canvas,
      Offset(cx + 0.085 * s, cy - 0.1 * s),
      0.035 * s,
      0.08 * s,
      1,
      _fill(const Color(0xFF14171A)),
    );
    if (heavy) {
      _rrect(
        canvas,
        Offset(cx + 0.22 * s, cy - 0.14 * s),
        0.1 * s,
        0.14 * s,
        2,
        _fill(const Color(0xFF3B4A2A)),
      );
    }
  }

  // Helmet.
  final hr = 0.135 * s * k;
  canvas.drawCircle(Offset(cx, cy - 0.04 * s), hr, _fill(p.dark));
  final shell = Rect.fromCircle(
    center: Offset(cx, cy - 0.045 * s),
    radius: hr * 0.9,
  );
  canvas.drawCircle(
    shell.center,
    hr * 0.9,
    Paint()
      ..shader = LinearGradient(
        colors: [p.light, p.hull],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(shell),
  );
  canvas.drawLine(
    Offset(cx - hr * 0.8, cy - 0.04 * s),
    Offset(cx + hr * 0.8, cy - 0.04 * s),
    _stroke(p.dark, 0.9, 0.7),
  );
  _rrect(
    canvas,
    Offset(cx, cy - 0.04 * s - hr * 0.92),
    hr * 0.5,
    hr * 0.28,
    1,
    _fill(const Color(0xFF14171A)),
  );
  canvas.drawCircle(
    Offset(cx - hr * 0.3, cy - 0.04 * s - hr * 0.35),
    hr * 0.2,
    _fill(Colors.white, 0.4),
  );
}
