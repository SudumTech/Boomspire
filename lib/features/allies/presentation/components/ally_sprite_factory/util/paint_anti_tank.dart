import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_soldier_model.dart';

/// Paints the friendly anti-tank soldier - the shared infantryman carrying a
/// rocket tube (see [paintSoldierModel]).
void paintAntiTank(Canvas canvas) =>
    paintSoldierModel(canvas, SoldierPalette.ally, SoldierRole.antiTank);
