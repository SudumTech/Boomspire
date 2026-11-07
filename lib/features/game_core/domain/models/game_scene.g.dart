// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameScene _$GameSceneFromJson(Map<String, dynamic> json) => _GameScene(
  id: json['id'] as String,
  name: json['name'] as String,
  briefing: json['briefing'] as String,
  biome: $enumDecode(_$BiomeEnumMap, json['biome']),
  mode:
      $enumDecodeNullable(_$GameModeEnumMap, json['mode']) ??
      GameMode.waveDefense,
  waveCount: (json['waveCount'] as num?)?.toInt() ?? 0,
  aggressionBias: (json['aggressionBias'] as num?)?.toDouble() ?? 0.0,
  version: (json['version'] as num?)?.toInt() ?? 1,
  homeLayout:
      $enumDecodeNullable(_$HomeLayoutEnumMap, json['homeLayout']) ??
      HomeLayout.eastEdge,
  spawnLayout:
      $enumDecodeNullable(_$SpawnLayoutEnumMap, json['spawnLayout']) ??
      SpawnLayout.single,
  homeSites:
      (json['homeSites'] as List<dynamic>?)
          ?.map((e) => HomeSite.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HomeSite>[],
  resourceNodeSites:
      (json['resourceNodeSites'] as List<dynamic>?)
          ?.map((e) => ResourceNodeSite.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ResourceNodeSite>[],
  startingGold: (json['startingGold'] as num?)?.toInt(),
  environment: json['environment'] == null
      ? const EnvironmentSettings()
      : EnvironmentSettings.fromJson(
          json['environment'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GameSceneToJson(_GameScene instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'briefing': instance.briefing,
      'biome': _$BiomeEnumMap[instance.biome]!,
      'mode': _$GameModeEnumMap[instance.mode]!,
      'waveCount': instance.waveCount,
      'aggressionBias': instance.aggressionBias,
      'version': instance.version,
      'homeLayout': _$HomeLayoutEnumMap[instance.homeLayout]!,
      'spawnLayout': _$SpawnLayoutEnumMap[instance.spawnLayout]!,
      'homeSites': instance.homeSites.map((e) => e.toJson()).toList(),
      'resourceNodeSites': instance.resourceNodeSites
          .map((e) => e.toJson())
          .toList(),
      'startingGold': ?instance.startingGold,
      'environment': instance.environment.toJson(),
    };

const _$BiomeEnumMap = {
  Biome.grassPlains: 'grassPlains',
  Biome.snowTundra: 'snowTundra',
  Biome.desertDunes: 'desertDunes',
  Biome.mountainForest: 'mountainForest',
  Biome.cityRuins: 'cityRuins',
  Biome.savanna: 'savanna',
  Biome.frozenPeaks: 'frozenPeaks',
  Biome.sea: 'sea',
  Biome.snowyGrassland: 'snowyGrassland',
};

const _$GameModeEnumMap = {
  GameMode.waveDefense: 'waveDefense',
  GameMode.skirmish: 'skirmish',
};

const _$HomeLayoutEnumMap = {
  HomeLayout.eastEdge: 'eastEdge',
  HomeLayout.center: 'center',
  HomeLayout.northEastCorner: 'northEastCorner',
  HomeLayout.southWestCorner: 'southWestCorner',
};

const _$SpawnLayoutEnumMap = {
  SpawnLayout.single: 'single',
  SpawnLayout.twoSided: 'twoSided',
  SpawnLayout.surround: 'surround',
};

_HomeSite _$HomeSiteFromJson(Map<String, dynamic> json) => _HomeSite(
  layout: $enumDecode(_$HomeLayoutEnumMap, json['layout']),
  owner: $enumDecode(_$HomeSiteOwnerEnumMap, json['owner']),
);

Map<String, dynamic> _$HomeSiteToJson(_HomeSite instance) => <String, dynamic>{
  'layout': _$HomeLayoutEnumMap[instance.layout]!,
  'owner': _$HomeSiteOwnerEnumMap[instance.owner]!,
};

const _$HomeSiteOwnerEnumMap = {
  HomeSiteOwner.player: 'player',
  HomeSiteOwner.ai: 'ai',
};

_ResourceNodeSite _$ResourceNodeSiteFromJson(Map<String, dynamic> json) =>
    _ResourceNodeSite(
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
    );

Map<String, dynamic> _$ResourceNodeSiteToJson(_ResourceNodeSite instance) =>
    <String, dynamic>{'dx': instance.dx, 'dy': instance.dy};
