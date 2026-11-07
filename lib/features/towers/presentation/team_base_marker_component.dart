import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/unit.dart';

/// The owner-colour markings every tower/building wears, drawn live from
/// [TeamOwned.teamColor] so the colour is never baked into a sprite: a soft
/// tint under the structure, bold corner brackets and a small pennant. A
/// player's tower and an AI's tower of the same type are told apart by this
/// alone.
class TeamBaseMarkerComponent extends PositionComponent {
  final TeamOwned _owner;

  TeamBaseMarkerComponent(this._owner) : super(priority: 1);

  @override
  Future<void> onLoad() async {
    size = (parent! as PositionComponent).size.clone();
  }

  @override
  void render(Canvas canvas) {
    final color = _owner.teamColor;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(6)),
      Paint()..color = color.withValues(alpha: 0.16),
    );

    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.95);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final arm = size.x * 0.24;
    for (final corner in [
      (const Offset(1.5, 1.5), 1.0, 1.0),
      (Offset(size.x - 1.5, 1.5), -1.0, 1.0),
      (Offset(1.5, size.y - 1.5), 1.0, -1.0),
      (Offset(size.x - 1.5, size.y - 1.5), -1.0, -1.0),
    ]) {
      final (origin, dx, dy) = corner;
      final path = Path()
        ..moveTo(origin.dx + dx * arm, origin.dy)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx, origin.dy + dy * arm);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, bracket);
    }

    // Pennant on a short pole at the top-left corner.
    final poleTop = Offset(size.x * 0.1, -size.y * 0.1);
    canvas.drawLine(
      Offset(size.x * 0.1, size.y * 0.16),
      poleTop,
      Paint()
        ..strokeWidth = 1.4
        ..color = const Color(0xFF2B2F36),
    );
    canvas.drawPath(
      Path()
        ..moveTo(poleTop.dx, poleTop.dy)
        ..lineTo(poleTop.dx + size.x * 0.26, poleTop.dy + size.y * 0.08)
        ..lineTo(poleTop.dx, poleTop.dy + size.y * 0.17)
        ..close(),
      Paint()..color = color,
    );
  }
}
