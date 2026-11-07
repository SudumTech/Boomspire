import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_jet.dart';
import 'ally_livery.dart';

/// Paints the friendly aircraft "2D object model" - a top-down fighter jet
/// in the home base's cyan livery (see [paintJet]).
void paintAircraft(Canvas canvas) => paintJet(
  canvas,
  const JetPalette(
    light: Color(0xFFA9BCC6),
    mid: Color(0xFF3F5660),
    dark: kAllyHullDark,
    accent: kAllyAccent,
    exhaust: Color(0xFF00E5FF),
  ),
);
