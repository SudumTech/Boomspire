import 'dart:ui';

import '../enums/unit_kind.dart';

/// Where on each unit's sprite the glowing team-colour point sits, as a
/// fraction of the sprite size (0,0 = top-left, 1,1 = bottom-right, nose of
/// every sprite pointing up). Each point is placed on a spot that reads as a
/// natural indicator light for that machine - a helmet, a turret hatch, a
/// cockpit, a roof beacon.
extension UnitMarkerExtensions on UnitKind {
  Offset get markerAnchor => switch (this) {
    UnitKind.soldier ||
    UnitKind.heavySoldier ||
    UnitKind.antiTankSoldier ||
    UnitKind.antiAirSoldier => const Offset(0.5, 0.4),
    UnitKind.tank => const Offset(0.5, 0.5),
    UnitKind.lightVehicle => const Offset(0.5, 0.45),
    UnitKind.rocketBarrage ||
    UnitKind.artilleryBarrage => const Offset(0.5, 0.62),
    UnitKind.antiAirVehicle => const Offset(0.5, 0.5),
    UnitKind.helicopter => const Offset(0.5, 0.58),
    UnitKind.attackPlane || UnitKind.aircraft => const Offset(0.5, 0.58),
    UnitKind.stealthBomber => const Offset(0.5, 0.46),
    UnitKind.drone => const Offset(0.5, 0.3),
  };
}
