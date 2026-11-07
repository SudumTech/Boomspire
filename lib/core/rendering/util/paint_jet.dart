import 'package:flutter/material.dart';

/// Colours for one side's [paintJet] livery.
class JetPalette {
  final Color light;
  final Color mid;
  final Color dark;
  final Color accent;
  final Color exhaust;

  const JetPalette({
    required this.light,
    required this.mid,
    required this.dark,
    required this.accent,
    required this.exhaust,
  });
}

/// Side-neutral jet size - the sprite canvas is [kJetSize] square.
const kJetSize = 50.0;

/// Paints a top-down fighter jet (nose up): swept main wings, tailplanes,
/// twin fins, wingtip missiles, tapered fuselage, intakes, canopy and twin
/// engine nozzles. Shared by the ally Aircraft and the enemy Attack Plane;
/// only [palette] differs. Mirrors `jet()` in `tool/lottie_gen/gen_units.py`
/// (the generated Lottie files are what the game normally displays - keep
/// both in sync).
void paintJet(Canvas canvas, JetPalette palette) {
  const s = kJetSize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.04 * s, cy + 0.07 * s),
      width: 0.5 * s,
      height: 0.72 * s,
    ),
    Paint()..color = const Color(0x2A000000),
  );

  // Swept main wings.
  final wing = _symmetricPath(cx, const [
    Offset(cx + 0.07 * s, cy - 0.06 * s),
    Offset(cx + 0.47 * s, cy + 0.27 * s),
    Offset(cx + 0.47 * s, cy + 0.37 * s),
    Offset(cx + 0.09 * s, cy + 0.25 * s),
  ]);
  canvas.drawPath(
    wing,
    Paint()
      ..shader =
          LinearGradient(
            colors: [palette.light, palette.mid, palette.dark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(
              center: const Offset(cx, cy),
              width: 0.94 * s,
              height: 0.4 * s,
            ),
          ),
  );
  canvas.drawPath(
    wing,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = palette.accent.withValues(alpha: 0.55),
  );

  // Tailplanes and twin fins.
  final tail = _symmetricPath(cx, const [
    Offset(cx + 0.07 * s, cy + 0.3 * s),
    Offset(cx + 0.23 * s, cy + 0.43 * s),
    Offset(cx + 0.22 * s, cy + 0.47 * s),
    Offset(cx + 0.06 * s, cy + 0.4 * s),
  ], separate: true);
  canvas.drawPath(tail, Paint()..color = palette.dark);
  for (final dx in [-0.06 * s, 0.06 * s]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, cy + 0.34 * s),
          width: 0.025 * s,
          height: 0.17 * s,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = palette.dark,
    );
  }

  // Wingtip missiles.
  for (final dx in [-0.41 * s, 0.41 * s]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, cy + 0.27 * s),
          width: 0.035 * s,
          height: 0.15 * s,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFECEFF1),
    );
    canvas.drawCircle(
      Offset(cx + dx, cy + 0.2 * s),
      0.02 * s,
      Paint()..color = palette.accent,
    );
  }

  // Fuselage.
  final body = _symmetricPath(cx, const [
    Offset(cx, cy - 0.47 * s),
    Offset(cx + 0.05 * s, cy - 0.3 * s),
    Offset(cx + 0.08 * s, cy - 0.05 * s),
    Offset(cx + 0.075 * s, cy + 0.3 * s),
    Offset(cx + 0.05 * s, cy + 0.44 * s),
  ], skipFirstWhenMirroring: true);
  canvas.drawPath(
    body,
    Paint()
      ..shader =
          LinearGradient(
            colors: [
              palette.dark,
              palette.mid,
              palette.light,
              palette.mid,
              palette.dark,
            ],
          ).createShader(
            Rect.fromCenter(
              center: const Offset(cx, cy),
              width: 0.17 * s,
              height: 0.9 * s,
            ),
          ),
  );
  canvas.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = palette.dark.withValues(alpha: 0.8),
  );

  // Intakes.
  for (final dx in [-0.07 * s, 0.07 * s]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, cy + 0.04 * s),
          width: 0.03 * s,
          height: 0.1 * s,
        ),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF11161A),
    );
  }

  // Canopy + highlight.
  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx, cy - 0.16 * s),
      width: 0.1 * s,
      height: 0.22 * s,
    ),
    Paint()..color = const Color(0xFF14202B),
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx - 0.01 * s, cy - 0.19 * s),
      width: 0.045 * s,
      height: 0.1 * s,
    ),
    Paint()..color = palette.accent.withValues(alpha: 0.55),
  );

  // Spine stripe in the team colour.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(cx, cy + 0.14 * s),
        width: 0.025 * s,
        height: 0.22 * s,
      ),
      const Radius.circular(1),
    ),
    Paint()..color = palette.accent.withValues(alpha: 0.85),
  );

  // Twin engine nozzles with glow.
  for (final dx in [-0.035 * s, 0.035 * s]) {
    canvas.drawCircle(
      Offset(cx + dx, cy + 0.45 * s),
      0.05 * s,
      Paint()..color = palette.exhaust.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(cx + dx, cy + 0.43 * s),
      0.032 * s,
      Paint()..color = const Color(0xFF0D0F10),
    );
  }
}

/// A closed outline made of [rightHalf] plus its left mirror around [cx].
/// With [separate] the two halves are two independent sub-paths instead of
/// one outline; with [skipFirstWhenMirroring] the first point (on the axis
/// itself) is not mirrored again.
Path _symmetricPath(
  double cx,
  List<Offset> rightHalf, {
  bool separate = false,
  bool skipFirstWhenMirroring = false,
}) {
  final mirrorSource = skipFirstWhenMirroring
      ? rightHalf.sublist(1)
      : rightHalf;
  final left = [
    for (final p in mirrorSource.reversed) Offset(2 * cx - p.dx, p.dy),
  ];
  final path = Path();
  if (separate) {
    path
      ..addPolygon(rightHalf, true)
      ..addPolygon(left.reversed.toList(), true);
    return path;
  }
  path.addPolygon([...rightHalf, ...left], true);
  return path;
}
