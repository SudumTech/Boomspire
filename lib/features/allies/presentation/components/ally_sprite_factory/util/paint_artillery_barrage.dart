import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_tank_model.dart';

/// Paints the friendly artillery barrage - a rocket-artillery truck in an
/// olive livery (see [paintArtilleryModel]).
void paintArtilleryBarrage(Canvas canvas) =>
    paintArtilleryModel(canvas, VehiclePalette.ally);
