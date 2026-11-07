import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../skirmish_ai/domain/models/ai_intel.dart';
import '../boomspire_game.dart';

/// Debug-only readout of what the skirmish AI is currently planning
/// (stance, target, raid, army power vs. yours, economy). Renders nothing in
/// release builds or outside a skirmish match.
class GameCoreAiIntelWidget extends StatelessWidget {
  final BoomspireGame game;

  const GameCoreAiIntelWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return ValueListenableBuilder<AiIntel?>(
      valueListenable: game.aiIntel,
      builder: (context, intel, _) {
        if (intel == null) return const SizedBox.shrink();
        return Text(
          S.current.aiIntelDebugLabel(
            intel.stance.name.toUpperCase(),
            intel.targetLabel,
            intel.raidLabel,
            intel.armySize,
            intel.armyPower.round(),
            intel.enemyPower.round(),
            intel.structures,
            intel.ownedNodes,
            intel.gold,
            intel.airTargetLabel,
            intel.spotsNoAntiAir ? 'NO-AA' : '-',
          ),
          style: const TextStyle(
            color: AppThemeColors.accentAmber,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
