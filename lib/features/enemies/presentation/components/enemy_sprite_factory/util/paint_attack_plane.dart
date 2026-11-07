import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_jet.dart';

/// Paints the enemy attack-plane "2D object model" - a top-down fighter jet
/// in a grey/red livery (see [paintJet]).
void paintAttackPlane(Canvas canvas) => paintJet(
  canvas,
  const JetPalette(
    light: Color(0xFFB0BEC5),
    mid: Color(0xFF78909C),
    dark: Color(0xFF37474F),
    accent: Color(0xFFFF5252),
    exhaust: Color(0xFFFF7043),
  ),
);
