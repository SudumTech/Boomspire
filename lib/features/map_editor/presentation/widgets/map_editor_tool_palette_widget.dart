import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../domain/enums/editor_tool.dart';
import '../../extensions/editor_tool_extensions.dart';
import '../../extensions/editor_tool_icon_extensions.dart';

/// The vertical icon palette docked on the map canvas: one button per
/// [EditorTool], the active one lit in the tool's own colour. Hovering shows
/// the tool's name.
class MapEditorToolPaletteWidget extends StatelessWidget {
  final EditorTool selected;
  final ValueChanged<EditorTool> onSelected;

  const MapEditorToolPaletteWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: AppThemeBorders.radius16,
        border: Border.all(color: AppThemeColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: AppThemeColors.scrimSubtle,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tool in EditorTool.values)
            _ToolButton(
              tool: tool,
              selected: tool == selected,
              onTap: () => onSelected(tool),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final EditorTool tool;
  final bool selected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.tool,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tool.color;
    return Tooltip(
      message: tool.label,
      waitDuration: const Duration(milliseconds: 250),
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: selected
              ? color.withValues(alpha: 0.22)
              : AppThemeColors.transparent,
          borderRadius: AppThemeBorders.radius12,
          child: InkWell(
            borderRadius: AppThemeBorders.radius12,
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: AppThemeBorders.radius12,
                border: Border.all(
                  color: selected ? color : AppThemeColors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                tool.icon,
                size: 22,
                color: selected ? color : AppThemeColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
