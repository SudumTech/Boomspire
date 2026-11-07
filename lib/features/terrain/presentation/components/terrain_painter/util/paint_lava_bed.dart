import 'dart:math';
import 'dart:ui' as ui;

/// Molten counterpart of `paintRiverBed` - a cooled-basalt crust around a
/// glowing magma channel, built outward-in like the river: heat bloom on the
/// ground, charred rock, a dark-red crust rim, orange magma and a white-hot
/// core, then dark crust plates and glowing cracks over the flow so it reads
/// as churning lava instead of a flat stripe. Deliberately not
/// `BiomePalette`-tinted: lava looks the same regardless of biome.
void paintLavaBed(ui.Canvas canvas, ui.Path path, double cellSize) {
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

  // Heat glow bleeding onto the surrounding ground.
  stroke(
    cellSize * 2.8,
    const ui.Color(0xFFff6a1a).withValues(alpha: 0.2),
    blur: 12,
  );
  // Scorched, charred rock.
  stroke(
    cellSize * 2.0,
    const ui.Color(0xFF1d1411).withValues(alpha: 0.7),
    blur: 2,
  );
  stroke(cellSize * 1.6, const ui.Color(0xFF0f0807).withValues(alpha: 0.85));
  // Cooling crust rim, then the molten body.
  stroke(cellSize * 1.42, const ui.Color(0xFF5a1405));
  stroke(cellSize * 1.22, const ui.Color(0xFFc22d06));
  stroke(cellSize * 0.9, const ui.Color(0xFFf2740f));
  stroke(cellSize * 0.5, const ui.Color(0xFFffc247), blur: 2.5);
  stroke(
    cellSize * 0.2,
    const ui.Color(0xFFfff0b0).withValues(alpha: 0.8),
    blur: 1.5,
  );

  final rnd = Random(53);
  for (final metric in path.computeMetrics()) {
    final length = metric.length;
    if (length <= 0) continue;
    final count = (length / (cellSize * 0.55)).floor().clamp(0, 400);
    for (var i = 0; i < count; i++) {
      final dist = ((i + rnd.nextDouble() * 0.8) * (length / count)).clamp(
        0.0,
        length,
      );
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
      final offset = (rnd.nextDouble() - 0.5) * cellSize * 0.9;
      final center = tangent.position + normal * offset;
      final angle = tangent.angle + (rnd.nextDouble() - 0.5) * 1.2;
      if (rnd.nextDouble() < 0.55) {
        // A dark cooled crust plate drifting on the surface.
        final w = cellSize * (0.3 + rnd.nextDouble() * 0.4);
        final h = cellSize * (0.14 + rnd.nextDouble() * 0.16);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);
        canvas.drawRRect(
          ui.RRect.fromRectAndRadius(
            ui.Rect.fromCenter(center: ui.Offset.zero, width: w, height: h),
            ui.Radius.circular(h / 2),
          ),
          ui.Paint()
            ..color = const ui.Color(0xFF2b0e07).withValues(alpha: 0.72),
        );
        canvas.restore();
      } else {
        // A glowing crack/vein.
        final len = cellSize * (0.18 + rnd.nextDouble() * 0.3);
        final d = ui.Offset(cos(angle), sin(angle)) * len / 2;
        canvas.drawLine(
          center - d,
          center + d,
          ui.Paint()
            ..strokeWidth = 1.6
            ..strokeCap = ui.StrokeCap.round
            ..color = const ui.Color(0xFFffd27a).withValues(alpha: 0.65),
        );
      }
    }
  }
}
