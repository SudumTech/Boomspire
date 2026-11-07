import 'package:flutter/material.dart';

import '../../../../../../core/rendering/util/paint_soldier_model.dart';

/// Paints an enemy infantryman in a brown livery - [heavy] is the armoured
/// cannon-carrying variant (see [paintSoldierModel]).
void paintEnemySoldier(Canvas canvas, {required bool heavy}) =>
    paintSoldierModel(
      canvas,
      SoldierPalette.enemy,
      heavy ? SoldierRole.heavy : SoldierRole.rifle,
    );
