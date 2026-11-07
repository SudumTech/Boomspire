import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_tank_model.dart';

/// Paints the enemy artillery barrage - a rocket-artillery truck in a brown
/// livery (see [paintArtilleryModel]).
void paintArtilleryBarrage(Canvas canvas) =>
    paintArtilleryModel(canvas, VehiclePalette.enemy);
