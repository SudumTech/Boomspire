import 'dart:math';

import 'package:flutter/material.dart';

import 'tower_art.dart';

/// Tech Lab: a rounded laboratory slab with glowing glass roof panels.
void paintTechLabBase(Canvas canvas) {
  const accent = Color(0xFF1DE9B6);
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(6, 6, 52, 52),
    const Radius.circular(10),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    metalPaint(
      body.outerRect,
      light: const Color(0xFF8AA0A6),
      dark: const Color(0xFF2B363A),
    ),
  );
  canvas.drawRRect(body, strokePaint(const Color(0xFF12191C), 2));
  canvas.drawRRect(body.deflate(2.5), strokePaint(accent, 1.4, alpha: 0.85));
  for (final dx in [-1, 1]) {
    for (final dy in [-1, 1]) {
      final panel = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(32 + dx * 11.5, 32 + dy * 11.5),
          width: 17,
          height: 17,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(panel, fillPaint(const Color(0xFF0D2A28)));
      canvas.drawRRect(panel.deflate(2), fillPaint(accent, alpha: 0.28));
      canvas.drawRRect(panel, strokePaint(accent, 1, alpha: 0.7));
    }
  }
  paintBolts(canvas, const [
    Offset(11, 11),
    Offset(53, 11),
    Offset(11, 53),
    Offset(53, 53),
  ]);
}

/// Command Post: an octagonal sandbagged bunker.
void paintCommandPostBase(Canvas canvas) {
  const accent = Color(0xFFFFD54A);
  const center = Offset(32, 32);
  final bunker = regularPolygon(center, 27, 8, pi / 8);
  canvas.drawShadow(bunker, const Color(0xFF000000), 4, false);
  canvas.drawPath(
    bunker,
    metalPaint(
      Rect.fromCircle(center: center, radius: 28),
      light: const Color(0xFF8A8C68),
      dark: const Color(0xFF33341F),
    ),
  );
  canvas.drawPath(bunker, strokePaint(const Color(0xFF1A1B0F), 2));
  // Sandbag ring.
  for (var i = 0; i < 16; i++) {
    final a = i * pi / 8;
    final c = center + Offset(cos(a), sin(a)) * 23.5;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(a + pi / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 9, height: 5),
        const Radius.circular(2.4),
      ),
      fillPaint(i.isEven ? const Color(0xFFB7A57A) : const Color(0xFFA08E63)),
    );
    canvas.restore();
  }
  canvas.drawCircle(center, 14, fillPaint(const Color(0xFF22240F)));
  canvas.drawCircle(center, 14, strokePaint(accent, 1.6));
}

/// Gold Mine: a rocky dirt pad with a timber frame, rails and ore.
void paintGoldMineBase(Canvas canvas) {
  const accent = Color(0xFFFFB300);
  final pad = Path()
    ..moveTo(10, 14)
    ..lineTo(30, 5)
    ..lineTo(54, 12)
    ..lineTo(60, 34)
    ..lineTo(52, 56)
    ..lineTo(28, 60)
    ..lineTo(8, 50)
    ..lineTo(4, 30)
    ..close();
  canvas.drawShadow(pad, const Color(0xFF000000), 4, false);
  canvas.drawPath(
    pad,
    metalPaint(
      const Rect.fromLTWH(4, 5, 56, 55),
      light: const Color(0xFF9B7A55),
      dark: const Color(0xFF42311F),
    ),
  );
  canvas.drawPath(pad, strokePaint(const Color(0xFF241A10), 2));
  // Rails.
  for (final dx in [-5.0, 5.0]) {
    canvas.drawLine(
      Offset(32 + dx, 36),
      Offset(32 + dx, 60),
      strokePaint(const Color(0xFF59595F), 1.6),
    );
  }
  for (var y = 38.0; y < 60; y += 5) {
    canvas.drawLine(
      Offset(25, y),
      Offset(39, y),
      strokePaint(const Color(0xFF5C4023), 1.6),
    );
  }
  // Timber frame around the shaft.
  canvas.drawRect(
    const Rect.fromLTWH(19, 16, 26, 24),
    fillPaint(const Color(0xFF110C07)),
  );
  canvas.drawRect(
    const Rect.fromLTWH(19, 16, 26, 24),
    strokePaint(const Color(0xFF8A5A2B), 3),
  );
  canvas.drawLine(
    const Offset(19, 16),
    const Offset(45, 40),
    strokePaint(const Color(0xFF8A5A2B), 1.4),
  );
  // Gold flecks.
  for (final p in const [
    Offset(12, 22),
    Offset(50, 22),
    Offset(14, 44),
    Offset(52, 46),
  ]) {
    canvas.drawCircle(p, 2.2, fillPaint(accent));
    paintGlint(canvas, p.translate(-0.6, -0.7), 0.6);
  }
}

/// Power Plant: an industrial slab with pipework and a hazard border.
void paintPowerPlantBase(Canvas canvas) {
  const accent = Color(0xFF42A5F5);
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(6, 6, 52, 52),
    const Radius.circular(5),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    metalPaint(
      body.outerRect,
      light: const Color(0xFF7F8B99),
      dark: const Color(0xFF2A3038),
    ),
  );
  canvas.drawRRect(body, strokePaint(const Color(0xFF14181C), 2));
  paintHazardStripes(canvas, const Rect.fromLTWH(9, 9, 46, 3));
  paintHazardStripes(canvas, const Rect.fromLTWH(9, 52, 46, 3));
  // Pipes.
  for (final y in [20.0, 44.0]) {
    canvas.drawLine(
      Offset(10, y),
      Offset(54, y),
      strokePaint(const Color(0xFF39434D), 4),
    );
    canvas.drawLine(
      Offset(10, y - 1),
      Offset(54, y - 1),
      strokePaint(Colors.white, 1, alpha: 0.3),
    );
  }
  for (final x in [14.0, 50.0]) {
    canvas.drawCircle(Offset(x, 20), 3, fillPaint(accent, alpha: 0.9));
    canvas.drawCircle(Offset(x, 44), 3, fillPaint(accent, alpha: 0.9));
  }
}
