import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../../domain/models/map_draft.dart';
import 'map_draft_preview_widget.dart';

/// A saved hand-made map shown exactly like the built-in maps: a live
/// terrain preview filling the tile with its name and details over it.
/// [onTap] opens it; [onDelete], when given, adds a delete button.
class MapDraftCardWidget extends StatelessWidget {
  final MapDraft draft;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MapDraftCardWidget({
    super.key,
    required this.draft,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = draft.biome.palette;
    final name = draft.name.isEmpty
        ? S.current.untitledMapEditorPage
        : draft.name;
    return Material(
      color: AppThemeColors.transparent,
      child: InkWell(
        borderRadius: AppThemeBorders.radius14,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppThemeBorders.radius14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MapDraftPreviewWidget(draft: draft),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppThemeColors.cardOverlayTop,
                      AppThemeColors.cardOverlayBottomStrong,
                    ],
                  ),
                  border: Border.all(
                    color: palette.ridgeLight.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Padding(
                padding: AppThemePaddings.all16,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppThemeSpacing.space4),
                      Text(
                        '${draft.biome.displayName} · ${draft.mode.name} · '
                        '${draft.homeSites.length} home · '
                        '${draft.arenaWidth.toInt()}x${draft.arenaHeight.toInt()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onDelete != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .deleteButtonTooltip,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppThemeColors.accentRed,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppThemeColors.glassPill,
                    ),
                    onPressed: onDelete,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
