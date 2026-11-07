import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/models/game_scene.dart';

/// Reads the maps shipped inside the app (`assets/scenes/scenes.json`) - the
/// source of truth for every built-in map's terrain flavour, layout, weather
/// and environment sound until a server provides newer versions. Never
/// throws; an unreadable asset just means the built-in defaults are used.
Future<List<GameScene>> loadBundledScenesSeed({
  String path = 'assets/scenes/scenes.json',
}) async {
  try {
    final raw = await rootBundle.loadString(path);
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => GameScene.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return const [];
  }
}
