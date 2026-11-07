import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/combat/enums/unit_domain.dart';
import '../../../../core/combat/enums/weapon_type.dart';

part 'secondary_weapon_definition.freezed.dart';
part 'secondary_weapon_definition.g.dart';

/// JSON shape of a unit's second weapon (see `SecondaryWeapon`) - lets the
/// content manifest describe a helicopter's rockets next to its gun.
@freezed
abstract class SecondaryWeaponDefinition with _$SecondaryWeaponDefinition {
  const factory SecondaryWeaponDefinition({
    required double damage,
    required double range,
    required double interval,
    required WeaponType weaponType,
    @Default(1) int projectileCount,
    @Default(0.12) double clipShotInterval,
    @Default({UnitDomain.ground}) Set<UnitDomain> attackDomains,
  }) = _SecondaryWeaponDefinition;

  factory SecondaryWeaponDefinition.fromJson(Map<String, dynamic> json) =>
      _$SecondaryWeaponDefinitionFromJson(json);
}
