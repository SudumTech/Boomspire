// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secondary_weapon_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SecondaryWeaponDefinition _$SecondaryWeaponDefinitionFromJson(
  Map<String, dynamic> json,
) => _SecondaryWeaponDefinition(
  damage: (json['damage'] as num).toDouble(),
  range: (json['range'] as num).toDouble(),
  interval: (json['interval'] as num).toDouble(),
  weaponType: $enumDecode(_$WeaponTypeEnumMap, json['weaponType']),
  projectileCount: (json['projectileCount'] as num?)?.toInt() ?? 1,
  clipShotInterval: (json['clipShotInterval'] as num?)?.toDouble() ?? 0.12,
  attackDomains:
      (json['attackDomains'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$UnitDomainEnumMap, e))
          .toSet() ??
      const {UnitDomain.ground},
);

Map<String, dynamic> _$SecondaryWeaponDefinitionToJson(
  _SecondaryWeaponDefinition instance,
) => <String, dynamic>{
  'damage': instance.damage,
  'range': instance.range,
  'interval': instance.interval,
  'weaponType': _$WeaponTypeEnumMap[instance.weaponType]!,
  'projectileCount': instance.projectileCount,
  'clipShotInterval': instance.clipShotInterval,
  'attackDomains': instance.attackDomains
      .map((e) => _$UnitDomainEnumMap[e]!)
      .toList(),
};

const _$WeaponTypeEnumMap = {
  WeaponType.bullet: 'bullet',
  WeaponType.cannon: 'cannon',
  WeaponType.rocket: 'rocket',
  WeaponType.laser: 'laser',
};

const _$UnitDomainEnumMap = {
  UnitDomain.ground: 'ground',
  UnitDomain.air: 'air',
  UnitDomain.sea: 'sea',
};
