import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_tank_model.dart';

/// Paints the friendly tank "2D object model" - the shared battle tank in an
/// olive livery (see [paintTankModel]). Ownership is the glowing team point.
void paintTank(Canvas canvas) => paintTankModel(canvas, VehiclePalette.ally);
