import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';

/// A small glowing point in the owner's colour mounted on a unit's body - the
/// one team marking every unit carries (see `UnitMarkerExtensions` for where
/// it sits on each kind). It breathes gently, so a unit reads as "alive" and
/// as belonging to a side without any ring or badge behind it.
class TeamGlowMarkerComponent extends PositionComponent {
  /// Core radius as a fraction of the sprite width, with a floor so even the
  /// smallest unit's light stays visible.
  static const _coreFraction = 0.065;
  static const _minCoreRadius = 2.0;

  final Color color;
  double _phase;

  TeamGlowMarkerComponent({
    required Vector2 hullSize,
    required Team team,
    required Offset anchorFraction,
    this._phase = 0,
  }) : color = team.color,
       super(
         position: Vector2(
           hullSize.x * anchorFraction.dx,
           hullSize.y * anchorFraction.dy,
         ),
         anchor: Anchor.center,
         size: Vector2.all(max(_minCoreRadius, hullSize.x * _coreFraction) * 2),
         priority: 6,
       );

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 2.4;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final core = size.x / 2;
    final pulse = 0.5 + 0.5 * sin(_phase);

    canvas.drawCircle(
      center,
      core * (2.2 + pulse * 0.5),
      Paint()
        ..color = color.withValues(alpha: 0.35 + pulse * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, core, Paint()..color = color);
    canvas.drawCircle(
      center,
      core * 0.45,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85),
    );
  }
}
