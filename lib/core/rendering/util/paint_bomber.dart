import 'package:flutter/material.dart';

/// The stealth-bomber sprite canvas is [kBomberSize] square.
const kBomberSize = 54.0;

/// Paints a top-down B-2 style flying wing: a two-kink swept leading edge,
/// the double-W sawtooth trailing edge, cockpit windows, intake slits, panel
/// lines and a lighter spine. Shared by both sides (ownership is shown by
/// the team ring/stripe overlays). Mirrors `stealth_bomber()` in
/// `tool/lottie_gen/gen_units.py` (the generated Lottie files are what the
/// game normally displays - keep both in sync).
void paintBomber(Canvas canvas) {
  const s = kBomberSize;
  const cx = s / 2;
  const cy = s / 2;

  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(cx + 0.04 * s, cy + 0.07 * s),
      width: 0.9 * s,
      height: 0.5 * s,
    ),
    Paint()..color = const Color(0x2A000000),
  );

  const right = [
    Offset(cx, cy - 0.40 * s),
    Offset(cx + 0.22 * s, cy - 0.16 * s),
    Offset(cx + 0.50 * s, cy + 0.20 * s),
    Offset(cx + 0.50 * s, cy + 0.27 * s),
    Offset(cx + 0.36 * s, cy + 0.40 * s),
    Offset(cx + 0.24 * s, cy + 0.32 * s),
    Offset(cx + 0.12 * s, cy + 0.42 * s),
    Offset(cx, cy + 0.30 * s),
  ];
  final left = [
    for (final p in right.sublist(1, right.length - 1).reversed)
      Offset(2 * cx - p.dx, p.dy),
  ];
  final wing = Path()..addPolygon([...right, ...left], true);
  canvas.drawPath(
    wing,
    Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFF59606A), Color(0xFF2A2F36), Color(0xFF121417)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(
              center: const Offset(cx, cy),
              width: 1.0 * s,
              height: 0.8 * s,
            ),
          ),
  );
  canvas.drawPath(
    wing,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xE60A0B0D),
  );

  // Lighter spine.
  canvas.drawPath(
    Path()..addPolygon(const [
      Offset(cx, cy - 0.38 * s),
      Offset(cx + 0.07 * s, cy - 0.1 * s),
      Offset(cx + 0.06 * s, cy + 0.26 * s),
      Offset(cx, cy + 0.29 * s),
      Offset(cx - 0.06 * s, cy + 0.26 * s),
      Offset(cx - 0.07 * s, cy - 0.1 * s),
    ], true),
    Paint()..color = const Color(0x427B838E),
  );

  // Panel lines.
  final panel = Paint()
    ..strokeWidth = 0.7
    ..color = const Color(0x59000000);
  for (final sx in [1.0, -1.0]) {
    canvas.drawLine(
      Offset(cx + sx * 0.08 * s, cy - 0.08 * s),
      Offset(cx + sx * 0.42 * s, cy + 0.22 * s),
      panel,
    );
    canvas.drawLine(
      Offset(cx + sx * 0.1 * s, cy + 0.08 * s),
      Offset(cx + sx * 0.3 * s, cy + 0.3 * s),
      panel,
    );
  }

  for (final sx in [1.0, -1.0]) {
    // Intake slit.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + sx * 0.1 * s, cy - 0.06 * s),
          width: 0.07 * s,
          height: 0.022 * s,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF050607),
    );
    // Cockpit window with a glint.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + sx * 0.035 * s, cy - 0.27 * s),
          width: 0.03 * s,
          height: 0.05 * s,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF1B2A38),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + sx * 0.035 * s, cy - 0.285 * s),
          width: 0.014 * s,
          height: 0.02 * s,
        ),
        const Radius.circular(0.5),
      ),
      Paint()..color = const Color(0xB39BC4E2),
    );
    // Exhaust slot between the trailing-edge teeth.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + sx * 0.18 * s, cy + 0.35 * s),
          width: 0.07 * s,
          height: 0.02 * s,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF050607),
    );
  }
}
