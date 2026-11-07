import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';

/// The zoom pill floating over the map canvas: zoom out, current percentage,
/// zoom in, and reset.
class MapEditorZoomBarWidget extends StatelessWidget {
  final double zoom;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onReset;

  const MapEditorZoomBarWidget({
    super.key,
    required this.zoom,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: AppThemeBorders.radius20,
        border: Border.all(color: AppThemeColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove, S.current.zoomOutTooltipEditorPage, onZoomOut),
          SizedBox(
            width: 48,
            child: Text(
              S.current.zoomPercentEditorPage((zoom * 100).round()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _button(Icons.add, S.current.zoomInTooltipEditorPage, onZoomIn),
          _button(
            Icons.center_focus_weak,
            S.current.resetZoomTooltipEditorPage,
            onReset,
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback onPressed) =>
      IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, color: AppThemeColors.textMuted, size: 20),
        onPressed: onPressed,
      );
}
