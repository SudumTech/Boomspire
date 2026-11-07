import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints a `MobileUnitComponent`'s render-time overlays: the selection
/// ring (range ring + pulsing outline) and the HP bar.
void paintMobileUnitOverlay(
  Canvas canvas, {
  required bool selected,
  required double idlePhase,
  required Color accent,
  required Color teamColor,
  required double attackRange,
  required double health,
  required double effectiveMaxHealth,
  required double healthRatio,
  required Vector2 size,
}) {
  final center = Offset(size.x / 2, size.y / 2);

  // Always-on team ring under the unit, so every unit reads as belonging to
  // a side at a glance regardless of its sprite.
  canvas.drawCircle(
    center,
    size.x * 0.55,
    Paint()..color = teamColor.withValues(alpha: 0.2),
  );
  canvas.drawCircle(
    center,
    size.x * 0.55,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = teamColor.withValues(alpha: 0.9),
  );

  if (selected) {
    final pulse = 0.5 + 0.5 * sin(idlePhase * 1.6);

    if (attackRange > 0) {
      canvas.drawCircle(
        center,
        attackRange,
        Paint()..color = accent.withValues(alpha: 0.04 + pulse * 0.04),
      );
      canvas.drawCircle(
        center,
        attackRange,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + pulse
          ..color = accent.withValues(alpha: 0.35 + pulse * 0.3),
      );
    }

    canvas.drawCircle(
      center,
      size.x * 0.62 + pulse * 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + pulse
        ..color = accent.withValues(alpha: 0.55 + pulse * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  if (health >= effectiveMaxHealth) return;
  final barWidth = size.x * 0.8;
  final barX = (size.x - barWidth) / 2;
  const barY = -8.0;
  canvas.drawRect(
    Rect.fromLTWH(barX, barY, barWidth, 4),
    Paint()..color = const Color(0xAA000000),
  );
  canvas.drawRect(
    Rect.fromLTWH(barX, barY, barWidth * healthRatio, 4),
    Paint()..color = accent,
  );
}
