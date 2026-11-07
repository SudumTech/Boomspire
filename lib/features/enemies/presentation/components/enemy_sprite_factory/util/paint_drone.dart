import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_uav.dart';

/// Paints the enemy drone "2D object model" - a Reaper-style UAV in a
/// desert-tan/red livery (see [paintUav]).
void paintDrone(Canvas canvas) => paintUav(
  canvas,
  const UavPalette(
    light: Color(0xFFC9C7A4),
    hull: Color(0xFF8A8868),
    dark: Color(0xFF33321F),
    accent: Color(0xFFE53935),
  ),
);
