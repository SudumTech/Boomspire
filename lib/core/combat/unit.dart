import 'dart:ui';

import 'team.dart';
import 'unit_domain.dart';

export 'unit_domain.dart';

/// Common contract + shared behavior for every combat-capable thing in the
/// game - tower/building blueprints, enemy blueprints, ally unit blueprints,
/// and the components built from them all mix this in instead of each
/// feature inventing its own isFlying/isNaval/canTargetGround/canTargetAir
/// booleans.
///
/// [domain] is the physical space this unit itself occupies; [attackDomains]
/// is the set of domains its weapon is capable of hitting. A ground-domain
/// tank whose [attackDomains] is just `{UnitDomain.ground}` can't hit an
/// air-domain plane - whether that plane is a friendly ally aircraft or an
/// enemy attack plane, since [canAttack] is checked the same way on both
/// sides of a fight.
/// Anything on the map that belongs to a side - every mobile unit and every
/// tower/building. It must always show its owner's colour, so the colour is
/// derived here, in one place, from the owning [Team]; renderers read
/// [teamColor] instead of picking colours themselves.
abstract mixin class TeamOwned {
  Team get ownerTeam;

  Color get teamColor => ownerTeam.color;
}

abstract mixin class Unit {
  Set<UnitDomain> get attackDomains;

  UnitDomain get domain;

  bool get isAirUnit => domain == UnitDomain.air;

  bool get isGroundUnit => domain == UnitDomain.ground;

  bool get isSeaUnit => domain == UnitDomain.sea;

  bool canAttack(UnitDomain other) => attackDomains.contains(other);
}
