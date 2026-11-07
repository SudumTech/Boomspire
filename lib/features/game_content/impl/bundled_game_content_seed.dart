import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/models/game_object_definition.dart';

/// Reads the manifest shipped inside the app (`assets/game_content/
/// manifest.json`) - the game's data source until a server provides newer
/// versions: every unit's cost, damage, range, health, speed, weapons and
/// model, for both its friendly and enemy form. Never throws; an unreadable
/// asset just means the built-in defaults are used.
Future<List<GameObjectDefinition>> loadBundledGameContentSeed({
  String path = 'assets/game_content/manifest.json',
}) async {
  try {
    final raw = await rootBundle.loadString(path);
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => GameObjectDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return const [];
  }
}
