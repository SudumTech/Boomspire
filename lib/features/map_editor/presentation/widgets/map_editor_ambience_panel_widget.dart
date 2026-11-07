import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../domain/models/ambience_settings.dart';

/// Sliders for a map's environment-sound mix (see [AmbienceSettings]): a
/// master switch, an overall level and one level per sound layer.
class MapEditorAmbiencePanelWidget extends StatelessWidget {
  final AmbienceSettings settings;
  final ValueChanged<AmbienceSettings> onChanged;

  const MapEditorAmbiencePanelWidget({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                S.current.ambienceEnabledLabelEditorPage,
                style: const TextStyle(color: AppThemeColors.textMuted),
              ),
            ),
            Switch(
              value: settings.enabled,
              activeThumbColor: AppThemeColors.accentCyan,
              onChanged: (value) =>
                  onChanged(settings.copyWith(enabled: value)),
            ),
          ],
        ),
        if (settings.enabled) ...[
          _layer(
            S.current.ambienceVolumeEditorPage,
            settings.volume,
            (v) => settings.copyWith(volume: v),
          ),
          _layer(
            S.current.ambienceWindEditorPage,
            settings.wind,
            (v) => settings.copyWith(wind: v),
          ),
          _layer(
            S.current.ambienceRainEditorPage,
            settings.rain,
            (v) => settings.copyWith(rain: v),
          ),
          _layer(
            S.current.ambienceSnowEditorPage,
            settings.snow,
            (v) => settings.copyWith(snow: v),
          ),
          _layer(
            S.current.ambienceDustEditorPage,
            settings.dust,
            (v) => settings.copyWith(dust: v),
          ),
          _layer(
            S.current.ambienceBirdsEditorPage,
            settings.birds,
            (v) => settings.copyWith(birds: v),
          ),
          _layer(
            S.current.ambienceLeavesEditorPage,
            settings.leaves,
            (v) => settings.copyWith(leaves: v),
          ),
          _layer(
            S.current.ambienceWaterEditorPage,
            settings.water,
            (v) => settings.copyWith(water: v),
          ),
          _layer(
            S.current.ambienceSeaEditorPage,
            settings.sea,
            (v) => settings.copyWith(sea: v),
          ),
          _layer(
            S.current.ambienceLavaEditorPage,
            settings.lava,
            (v) => settings.copyWith(lava: v),
          ),
        ],
      ],
    );
  }

  Widget _layer(
    String label,
    double value,
    AmbienceSettings Function(double) update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        S.current.ambienceLayerLabelEditorPage(label, (value * 100).round()),
        style: const TextStyle(color: AppThemeColors.textMuted, fontSize: 12),
      ),
      Slider(
        value: value.clamp(0.0, 2.0),
        max: 2,
        activeColor: AppThemeColors.accentAmber,
        onChanged: (v) => onChanged(update(v)),
      ),
    ],
  );
}
