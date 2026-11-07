import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_uav.dart';
import 'ally_livery.dart';

/// Paints the friendly drone "2D object model" - a Reaper-style UAV in the
/// home base's cyan livery (see [paintUav]). Flies the exact same
/// strafing-run AI as the other plane-body kinds (see
/// `UnitKind.drone.bodyType`).
void paintDrone(Canvas canvas) => paintUav(
  canvas,
  const UavPalette(
    light: Color(0xFFA9BCC6),
    hull: Color(0xFF3F5660),
    dark: kAllyHullDark,
    accent: kAllyAccent,
  ),
);
