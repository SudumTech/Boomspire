import 'enums/unit_domain.dart';
import 'enums/weapon_type.dart';

/// A second, independent weapon on a unit (e.g. a helicopter's rocket pods
/// alongside its gun). It reloads and fires on its own timer, and can be
/// limited to certain target domains - rockets that cannot hit aircraft,
/// say - while the primary weapon keeps its own domains.
class SecondaryWeapon {
  /// Total damage per salvo, split across [projectileCount] rounds.
  final double damage;

  /// Furthest target distance it will fire at (never more than the unit's
  /// own engagement range in practice - targets are found with that).
  final double range;

  /// Seconds to reload after a full salvo.
  final double interval;

  /// Rounds per salvo.
  final int projectileCount;

  /// Seconds between rounds within a salvo.
  final double clipShotInterval;

  final WeaponType weaponType;

  /// What it can hit.
  final Set<UnitDomain> attackDomains;

  const SecondaryWeapon({
    required this.damage,
    required this.range,
    required this.interval,
    required this.weaponType,
    this.projectileCount = 1,
    this.clipShotInterval = 0.12,
    this.attackDomains = const {UnitDomain.ground},
  });

  /// Damage per second, counting the whole reload cycle.
  double get dps => damage / (interval + projectileCount * clipShotInterval);
}
