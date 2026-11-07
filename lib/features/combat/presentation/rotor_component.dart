import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_rotor.dart';

/// Always-spinning main rotor blur disc, layered above a helicopter-kind
/// unit's static fuselage sprite so it reads as "alive" even while idling -
/// attached via `MobileUnitComponent.addExtraVisuals`.
class RotorComponent extends PositionComponent {
  double _spin = 0;

  /// Mounted over the main-rotor mast of a top-down, nose-up helicopter
  /// sprite (a little behind the middle of the fuselage); the blur disc is
  /// wider than the fuselage, like a real rotor.
  RotorComponent({required Vector2 hullSize})
    : super(
        position: Vector2(hullSize.x * 0.5, hullSize.y * 0.52),
        anchor: Anchor.center,
        size: Vector2.all(hullSize.x * 1.3),
        priority: 5,
      );

  @override
  void render(Canvas canvas) => paintRotor(canvas, size: size, spin: _spin);

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 18;
  }
}
