import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../../domain/enums/editor_tool.dart';

/// The options for the active brush in the side panel: a home-site counter,
/// the channel width for rivers/lava, and the brush type (which biome look
/// the stroke gets) as one compact dropdown.
class MapEditorBrushOptionsWidget extends StatelessWidget {
  final EditorTool tool;
  final int homeSiteCount;
  final int maxHomeSites;
  final double riverWidth;
  final ValueChanged<double> onRiverWidthChanged;
  final Biome? variant;
  final ValueChanged<Biome?> onVariantChanged;

  const MapEditorBrushOptionsWidget({
    super.key,
    required this.tool,
    required this.homeSiteCount,
    required this.maxHomeSites,
    required this.riverWidth,
    required this.onRiverWidthChanged,
    required this.variant,
    required this.onVariantChanged,
  });

  bool get _isChannel => tool == EditorTool.river || tool == EditorTool.lava;

  bool get _hasBrushType =>
      tool != EditorTool.erase &&
      tool != EditorTool.homeSite &&
      tool != EditorTool.resourceNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tool == EditorTool.homeSite)
          Text(
            S.current.homeSitesHintEditorPage(homeSiteCount, maxHomeSites),
            style: const TextStyle(
              color: AppThemeColors.textMuted,
              fontSize: 12,
            ),
          ),
        if (_isChannel) ...[
          Text(
            S.current.riverWidthLabelEditorPage(riverWidth.round()),
            style: const TextStyle(color: AppThemeColors.textMuted),
          ),
          Slider(
            value: riverWidth,
            min: 16,
            max: 160,
            onChanged: onRiverWidthChanged,
          ),
        ],
        if (_hasBrushType) ...[
          SizedBox(height: AppThemeSpacing.space4),
          DropdownButtonFormField<Biome?>(
            initialValue: variant,
            isExpanded: true,
            dropdownColor: AppThemeColors.surfacePanel,
            style: const TextStyle(
              color: AppThemeColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: S.current.brushTypeLabelEditorPage,
              isDense: true,
            ),
            items: [
              DropdownMenuItem<Biome?>(
                value: null,
                child: Text(S.current.brushTypeMatchBiomeEditorPage),
              ),
              for (final biome in Biome.values)
                DropdownMenuItem<Biome?>(
                  value: biome,
                  child: Text(biome.displayName),
                ),
            ],
            onChanged: onVariantChanged,
          ),
        ],
      ],
    );
  }
}
