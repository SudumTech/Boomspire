import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../game_core/domain/enums/game_mode.dart';
import '../../../game_core/extensions/game_mode_extensions.dart';

/// Chooses which kind of map is being made - Tower Defense or Skirmish - with
/// a line saying how many home sites that mode allows.
class MapEditorModeSelectorWidget extends StatelessWidget {
  final GameMode mode;
  final ValueChanged<GameMode> onChanged;

  const MapEditorModeSelectorWidget({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.current.modeLabelEditorPage,
          style: const TextStyle(color: AppThemeColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<GameMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: GameMode.waveDefense,
                icon: const Icon(Icons.shield, size: 16),
                label: Text(S.current.waveDefenseOptionEditorPage),
              ),
              ButtonSegment(
                value: GameMode.skirmish,
                icon: const Icon(Icons.flag, size: 16),
                label: Text(S.current.skirmishOptionEditorPage),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          S.current.modeHomesHintEditorPage(mode.maxHomeSites),
          style: const TextStyle(color: AppThemeColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
