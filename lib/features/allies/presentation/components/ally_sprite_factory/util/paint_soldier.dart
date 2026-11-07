import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_soldier_model.dart';

/// Paints the friendly soldier "2D object model" - the shared top-down
/// infantryman in an olive livery (see [paintSoldierModel]).
void paintSoldier(Canvas canvas) =>
    paintSoldierModel(canvas, SoldierPalette.ally, SoldierRole.rifle);
