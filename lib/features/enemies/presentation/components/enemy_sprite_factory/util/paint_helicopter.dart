import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_helicopter_model.dart';

/// Paints the helicopter gunship "2D object model" - a top-down, nose-up
/// attack helicopter (see [paintHelicopterModel]); the main rotor is spun
/// separately at runtime.
void paintHelicopter(Canvas canvas) => paintHelicopterModel(canvas);
