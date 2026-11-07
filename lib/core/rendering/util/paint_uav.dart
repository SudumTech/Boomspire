import 'package:flutter/material.dart';

/// Colours for one side's [paintUav] livery.
class UavPalette {
  final Color light;
  final Color hull;
  final Color dark;
  final Color accent;

  const UavPalette({
    required this.light,
    required this.hull,
    required this.dark,
    required this.accent,
  });
}

/// The drone sprite canvas is [kUavSize] square.
const kUavSize = 42.0;

/// Paints a top-down MQ-9 Reaper-style UAV: long tapered straight wings
/// with under-wing pods, a bulbous sensor nose, a slim body, an inverted
/// V-tail and a blurred pusher propeller. Mirrors `drone()` in
/// `tool/lottie_gen/gen_units.py` (the generated Lottie files are what the
/// game normally displays - keep both in sync).
void paintUav(Canvas canvas, UavPalette palette) {
  const s = kUavSize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.04 * s, cy + 0.07 * s),
      width: 0.7 * s,
      height: 0.5 * s,
    ),
    Paint()..color = const Color(0x26000000),
  );

  final wing = _outline(cx, const [
    Offset(cx + 0.08 * s, cy - 0.05 * s),
    Offset(cx + 0.48 * s, cy - 0.01 * s),
    Offset(cx + 0.48 * s, cy + 0.07 * s),
    Offset(cx + 0.08 * s, cy + 0.11 * s),
  ]);
  canvas.drawPath(
    wing,
    Paint()
      ..shader =
          LinearGradient(
            colors: [palette.light, palette.hull, palette.dark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(
              center: const Offset(cx, cy),
              width: 0.96 * s,
              height: 0.16 * s,
            ),
          ),
  );
  canvas.drawPath(
    wing,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = palette.dark.withValues(alpha: 0.9),
  );

  // Under-wing pods and wingtip markings.
  for (final dx in [-0.27 * s, 0.27 * s]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + dx, cy + 0.04 * s),
        width: 0.045 * s,
        height: 0.15 * s,
      ),
      Paint()..color = const Color(0xFF1A1C20),
    );
  }
  for (final dx in [-0.44 * s, 0.44 * s]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, cy + 0.03 * s),
          width: 0.05 * s,
          height: 0.07 * s,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = palette.accent.withValues(alpha: 0.85),
    );
  }

  // Inverted V-tail.
  final rightTail = const [
    Offset(cx + 0.025 * s, cy + 0.28 * s),
    Offset(cx + 0.2 * s, cy + 0.42 * s),
    Offset(cx + 0.16 * s, cy + 0.45 * s),
    Offset(cx + 0.02 * s, cy + 0.36 * s),
  ];
  canvas.drawPath(
    Path()
      ..addPolygon(rightTail, true)
      ..addPolygon([
        for (final p in rightTail) Offset(2 * cx - p.dx, p.dy),
      ], true),
    Paint()..color = palette.dark,
  );

  // Slim fuselage with a bulbous nose.
  final body = _outline(cx, const [
    Offset(cx, cy - 0.44 * s),
    Offset(cx + 0.085 * s, cy - 0.33 * s),
    Offset(cx + 0.09 * s, cy - 0.2 * s),
    Offset(cx + 0.06 * s, cy - 0.05 * s),
    Offset(cx + 0.04 * s, cy + 0.36 * s),
  ], skipFirstWhenMirroring: true);
  canvas.drawPath(
    body,
    Paint()
      ..shader =
          LinearGradient(
            colors: [
              palette.dark,
              palette.hull,
              palette.light,
              palette.hull,
              palette.dark,
            ],
          ).createShader(
            Rect.fromCenter(
              center: const Offset(cx, cy),
              width: 0.18 * s,
              height: 0.8 * s,
            ),
          ),
  );
  canvas.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = palette.dark.withValues(alpha: 0.9),
  );

  // Sensor ball + dorsal antenna.
  canvas.drawCircle(
    const Offset(cx, cy - 0.33 * s),
    0.065 * s,
    Paint()..color = const Color(0xFF1A1C20),
  );
  canvas.drawCircle(
    const Offset(cx, cy - 0.33 * s),
    0.04 * s,
    Paint()..color = palette.accent.withValues(alpha: 0.9),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(cx, cy - 0.08 * s),
        width: 0.02 * s,
        height: 0.1 * s,
      ),
      const Radius.circular(1),
    ),
    Paint()..color = palette.light.withValues(alpha: 0.9),
  );

  // Pusher propeller: faint disc plus hub.
  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx, cy + 0.41 * s),
      width: 0.3 * s,
      height: 0.06 * s,
    ),
    Paint()..color = const Color(0x2EFFFFFF),
  );
  canvas.drawCircle(
    const Offset(cx, cy + 0.39 * s),
    0.045 * s,
    Paint()..color = const Color(0xFF1A1C20),
  );
}

Path _outline(
  double cx,
  List<Offset> rightHalf, {
  bool skipFirstWhenMirroring = false,
}) {
  final source = skipFirstWhenMirroring ? rightHalf.sublist(1) : rightHalf;
  final left = [for (final p in source.reversed) Offset(2 * cx - p.dx, p.dy)];
  return Path()..addPolygon([...rightHalf, ...left], true);
}
