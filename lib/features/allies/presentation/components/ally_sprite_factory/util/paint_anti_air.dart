import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_soldier_model.dart';

/// Paints the friendly anti-air soldier - the shared infantryman carrying a
/// missile tube with a sight (see [paintSoldierModel]).
void paintAntiAir(Canvas canvas) =>
    paintSoldierModel(canvas, SoldierPalette.ally, SoldierRole.antiAir);
