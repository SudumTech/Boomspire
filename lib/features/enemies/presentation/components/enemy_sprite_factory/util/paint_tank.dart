import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_tank_model.dart';

/// Paints the enemy tank "2D object model" - the shared battle tank in a
/// brown livery (see [paintTankModel]).
void paintTank(Canvas canvas) => paintTankModel(canvas, VehiclePalette.enemy);
