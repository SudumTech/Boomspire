import 'dart:ui' as ui;

import '../../../../domain/models/biome.dart';

/// Static bank/bed/water layers only - baked once into the cached terrain
/// image. The moving shimmer/ripples are drawn separately every frame by
/// `TerrainPainter.paintRiverFlow` so the river reads as flowing water.
///
/// Built outward-in, each layer a narrower stroke of the same smoothed path,
/// so the river has real depth across its width whichever way it runs: a
/// soft damp-earth bank, a narrow pale shingle strip, a foam line at the
/// waterline, then deep water that lightens toward the middle.
void paintRiverBed(
  ui.Canvas canvas,
  ui.Path path,
  double cellSize,
  BiomePalette palette,
) {
  void stroke(double width, ui.Color color, {double blur = 0}) {
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = width
        ..color = color
        ..maskFilter = blur > 0
            ? ui.MaskFilter.blur(ui.BlurStyle.normal, blur)
            : null,
    );
  }

  final damp = ui.Color.lerp(
    const ui.Color(0xFF5c4a32),
    palette.groundBottom,
    0.45,
  )!;
  final shingle = ui.Color.lerp(
    const ui.Color(0xFFcdbb8c),
    palette.groundMid,
    0.4,
  )!;
  final deep = ui.Color.lerp(
    const ui.Color(0xFF0b3a55),
    palette.capColor,
    0.2,
  )!;
  final mid = ui.Color.lerp(
    const ui.Color(0xFF1b7f96),
    palette.capColor,
    0.22,
  )!;
  final light = ui.Color.lerp(
    const ui.Color(0xFF58c4d2),
    palette.capColor,
    0.25,
  )!;

  // Damp earth fading softly into the ground.
  stroke(cellSize * 2.3, damp.withValues(alpha: 0.32), blur: 7);
  stroke(cellSize * 1.75, damp.withValues(alpha: 0.5), blur: 2.5);
  // Pale shingle strip along the water.
  stroke(cellSize * 1.52, shingle.withValues(alpha: 0.7));
  // Foam line right at the waterline.
  stroke(cellSize * 1.38, const ui.Color(0xFFeaf8f8).withValues(alpha: 0.55));
  // Water: deep at the banks, brighter toward the centre.
  stroke(cellSize * 1.3, deep);
  stroke(cellSize * 1.0, mid);
  stroke(cellSize * 0.58, light.withValues(alpha: 0.85), blur: 3);
  // A thin bright glint down the middle of the current.
  stroke(
    cellSize * 0.16,
    const ui.Color(0xFFe6fdff).withValues(alpha: 0.18),
    blur: 1.5,
  );
}
