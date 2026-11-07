import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../progress/domain/models/progress_snapshot.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../biome_preview.dart';

/// One built-in scene tile - the same for every mode: live terrain preview,
/// name and briefing, and the facts that matter for that scene's gameplay
/// (waves and best wave for tower defense, player count for a skirmish).
class SceneCardWidget extends StatelessWidget {
  final GameScene scene;
  final ProgressSnapshot progress;
  final VoidCallback onTap;

  const SceneCardWidget({
    super.key,
    required this.scene,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    final completed = progress.isCompleted(scene.id);
    final bestWave = progress.bestWaveFor(scene.id);
    final isWaveDefense = scene.mode == GameMode.waveDefense;
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
              // The game screen flies the same preview in as its backdrop
              // when a tower-defense scene starts.
              if (isWaveDefense)
                Hero(
                  tag: 'scene-preview-${scene.id}',
                  child: BiomePreview(scene: scene),
                )
              else
                BiomePreview(scene: scene),
              LayoutBuilder(
                builder: (context, constraints) => GlassmorphicContainer(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  borderRadius: 14,
                  blur: 6,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppThemeColors.cardOverlayTop,
                      AppThemeColors.cardOverlayBottom,
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      palette.ridgeLight.withValues(alpha: 0.7),
                      palette.ridgeLight.withValues(alpha: 0.2),
                    ],
                  ),
                  child: Padding(
                    padding: AppThemePaddings.all16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (completed)
                          Container(
                            margin: AppThemePaddings.bottom6,
                            padding: AppThemePaddings.h8v2,
                            decoration: BoxDecoration(
                              color: AppThemeColors.accentGreen.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: AppThemeBorders.radius6,
                              border: Border.all(
                                color: AppThemeColors.accentGreen,
                              ),
                            ),
                            child: Text(
                              S.current.sceneCompleted,
                              style: const TextStyle(
                                color: AppThemeColors.accentGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        Text(
                          scene.name,
                          style: const TextStyle(
                            color: AppThemeColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppThemeSpacing.space4),
                        Text(
                          scene.briefing,
                          style: const TextStyle(
                            color: AppThemeColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppThemeSpacing.space8),
                        Row(
                          spacing: AppThemeSpacing.space10,
                          children: [
                            Text(
                              isWaveDefense
                                  ? S.current.wavesCount(scene.waveCount)
                                  : S.current.seatsCount(
                                      scene.homeSites.length,
                                    ),
                              style: TextStyle(
                                color: palette.ridgeLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            if (isWaveDefense && bestWave > 0)
                              Text(
                                S.current.bestWaveReached(bestWave),
                                style: const TextStyle(
                                  color: AppThemeColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
