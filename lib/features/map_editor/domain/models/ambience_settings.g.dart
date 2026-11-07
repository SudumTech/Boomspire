// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambience_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AmbienceSettings _$AmbienceSettingsFromJson(Map<String, dynamic> json) =>
    _AmbienceSettings(
      enabled: json['enabled'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      wind: (json['wind'] as num?)?.toDouble() ?? 1.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 1.0,
      snow: (json['snow'] as num?)?.toDouble() ?? 1.0,
      dust: (json['dust'] as num?)?.toDouble() ?? 1.0,
      birds: (json['birds'] as num?)?.toDouble() ?? 1.0,
      leaves: (json['leaves'] as num?)?.toDouble() ?? 1.0,
      water: (json['water'] as num?)?.toDouble() ?? 1.0,
      sea: (json['sea'] as num?)?.toDouble() ?? 1.0,
      lava: (json['lava'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$AmbienceSettingsToJson(_AmbienceSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'volume': instance.volume,
      'wind': instance.wind,
      'rain': instance.rain,
      'snow': instance.snow,
      'dust': instance.dust,
      'birds': instance.birds,
      'leaves': instance.leaves,
      'water': instance.water,
      'sea': instance.sea,
      'lava': instance.lava,
    };
