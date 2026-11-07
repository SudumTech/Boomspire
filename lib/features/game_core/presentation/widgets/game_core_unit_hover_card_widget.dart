import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/combat/unit_domain.dart';
import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../domain/models/unit_card_info.dart';

/// Frosted-glass hover card for a unit in the produce row: its name, what it
/// can attack, and its power, health and speed (plus cost and any lock).
class GameCoreUnitHoverCardWidget extends StatelessWidget {
  final UnitCardInfo info;
  final int cost;
  final String? lockReason;

  const GameCoreUnitHoverCardWidget({
    super.key,
    required this.info,
    required this.cost,
    required this.lockReason,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.transparent,
      child: ClipRRect(
        borderRadius: AppThemeBorders.radius12,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: AppThemePaddings.h12v10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: AppThemeBorders.radius12,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: const TextStyle(
                    color: AppThemeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppThemeSpacing.space4),
                Text(
                  _targetsLabel(),
                  style: const TextStyle(
                    color: AppThemeColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppThemeSpacing.space6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _stat(Icons.paid, '${cost}g'),
                    _stat(
                      Icons.flash_on,
                      '${S.current.unitCardPower} ${info.power.round()}',
                    ),
                    _stat(
                      Icons.favorite,
                      '${S.current.unitCardHealth} ${info.health.round()}',
                    ),
                    _stat(
                      Icons.speed,
                      '${S.current.unitCardSpeed} ${info.speed.round()}',
                    ),
                    if (info.range > 0)
                      _stat(
                        Icons.social_distance,
                        '${S.current.unitCardRange} ${info.range.round()}',
                      ),
                  ],
                ),
                if (lockReason != null) ...[
                  SizedBox(height: AppThemeSpacing.space6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 12,
                        color: AppThemeColors.accentAmber,
                      ),
                      SizedBox(width: AppThemeSpacing.space4),
                      Flexible(
                        child: Text(
                          lockReason!,
                          style: const TextStyle(
                            color: AppThemeColors.accentAmber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _targetsLabel() {
    if (!info.isArmed) return S.current.unitCardUnarmed;
    final names = [
      if (info.targets.contains(UnitDomain.ground))
        S.current.unitCardTargetGround,
      if (info.targets.contains(UnitDomain.air)) S.current.unitCardTargetAir,
      if (info.targets.contains(UnitDomain.sea)) S.current.unitCardTargetSea,
    ];
    return '${S.current.unitCardAttacksLabel}: ${names.join(' · ')}';
  }

  Widget _stat(IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppThemeColors.textMuted),
      SizedBox(width: AppThemeSpacing.space3),
      Text(
        value,
        style: const TextStyle(
          color: AppThemeColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
