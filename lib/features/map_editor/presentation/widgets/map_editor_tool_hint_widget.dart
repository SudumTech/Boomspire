import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../domain/enums/editor_tool.dart';
import '../../extensions/editor_tool_extensions.dart';
import '../../extensions/editor_tool_icon_extensions.dart';

/// A small status chip on the canvas naming the active tool and saying what
/// it does.
class MapEditorToolHintWidget extends StatelessWidget {
  final EditorTool tool;

  const MapEditorToolHintWidget({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: AppThemeBorders.radius20,
        border: Border.all(color: tool.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tool.icon, size: 16, color: tool.color),
          const SizedBox(width: 8),
          Text(
            tool.label,
            style: TextStyle(
              color: tool.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _hint(),
            style: const TextStyle(
              color: AppThemeColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _hint() => switch (tool) {
    EditorTool.mountain => S.current.mountainHintEditorPage,
    EditorTool.dune => S.current.duneHintEditorPage,
    EditorTool.tree => S.current.treeHintEditorPage,
    EditorTool.erase => S.current.eraseHintEditorPage,
    EditorTool.river => S.current.riverHintEditorPage,
    EditorTool.lake => S.current.lakeHintEditorPage,
    EditorTool.lava => S.current.lavaHintEditorPage,
    EditorTool.volcanicLake => S.current.volcanicLakeHintEditorPage,
    EditorTool.homeSite => S.current.homeSiteHintEditorPage,
    EditorTool.resourceNode => S.current.resourceNodeHintEditorPage,
  };
}
