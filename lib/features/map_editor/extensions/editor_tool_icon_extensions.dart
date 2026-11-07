import 'package:flutter/material.dart';

import '../domain/enums/editor_tool.dart';

/// Icon and accent colour shown for each [EditorTool] in the tool palette.
extension EditorToolIconExtensions on EditorTool {
  IconData get icon => switch (this) {
    EditorTool.mountain => Icons.landscape,
    EditorTool.dune => Icons.grain,
    EditorTool.tree => Icons.park,
    EditorTool.erase => Icons.cleaning_services,
    EditorTool.river => Icons.water,
    EditorTool.lake => Icons.pool,
    EditorTool.lava => Icons.local_fire_department,
    EditorTool.volcanicLake => Icons.whatshot,
    EditorTool.homeSite => Icons.home,
    EditorTool.resourceNode => Icons.diamond,
  };

  Color get color => switch (this) {
    EditorTool.mountain => const Color(0xFFB0BEC5),
    EditorTool.dune => const Color(0xFFE0C27A),
    EditorTool.tree => const Color(0xFF66BB6A),
    EditorTool.erase => const Color(0xFFFF8A80),
    EditorTool.river => const Color(0xFF4FC3F7),
    EditorTool.lake => const Color(0xFF29B6F6),
    EditorTool.lava => const Color(0xFFFF7043),
    EditorTool.volcanicLake => const Color(0xFFFF5722),
    EditorTool.homeSite => const Color(0xFFFFD54A),
    EditorTool.resourceNode => const Color(0xFFB388FF),
  };
}
