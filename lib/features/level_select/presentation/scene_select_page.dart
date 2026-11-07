import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../../shared/app_theme/app_theme_borders.dart';
import '../../../shared/app_theme/app_theme_colors.dart';
import '../../../shared/app_theme/app_theme_paddings.dart';
import '../../../shared/app_theme/app_theme_spacing.dart';
import '../../account/presentation/account_badge.dart';
import '../../account/presentation/state/account_profile_state.dart';
import '../../game_core/domain/models/game_difficulty.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/domain/repos/scene_catalog_repository.dart';
import '../../game_core/extensions/game_mode_extensions.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/domain/repos/map_draft_repository.dart';
import '../../map_editor/presentation/widgets/map_draft_card_widget.dart';
import '../../progress/domain/models/progress_snapshot.dart';
import '../../progress/domain/repos/progress_repository.dart';
import 'scene_launcher.dart';
import 'state/scene_select_state.dart';
import 'widgets/level_select_difficulty_selector_widget.dart';
import 'widgets/scene_card_widget.dart';

/// The one scene picker, for every game mode. It is given a [GameMode] and
/// shows that mode's built-in scenes (from the scene catalog) and the
/// player's saved maps of that mode; picking one starts it through
/// [SceneLauncher], and the scene itself decides the gameplay.
class SceneSelectPage extends StatefulWidget {
  final GameMode mode;

  const SceneSelectPage({super.key, required this.mode});

  @override
  State<SceneSelectPage> createState() => _SceneSelectPageState();
}

class _SceneSelectPageState extends State<SceneSelectPage> {
  final AccountProfileState _accountProfileState = getIt<AccountProfileState>();
  // The scrollbar and the scroll view share this controller - a Scrollbar
  // without one only works where the platform makes a scroll view "primary".
  final ScrollController _scroll = ScrollController();
  late final SceneSelectState _state = SceneSelectState(
    widget.mode,
    getIt<SceneCatalogRepository>(),
    getIt<MapDraftRepository>(),
    getIt<ProgressRepository>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Scrollbar(
              controller: _scroll,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: AppThemePaddings.h16v24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _header(),
                        const SizedBox(height: AppThemeSpacing.space20),
                        AccountBadge(state: _accountProfileState),
                        Center(
                          child: ValueListenableBuilder<GameDifficulty>(
                            valueListenable: _state.difficulty,
                            builder: (context, difficulty, _) =>
                                LevelSelectDifficultySelectorWidget(
                                  value: difficulty,
                                  onChanged: _state.selectDifficulty,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppThemeSpacing.space28),
                        _sectionTitle(S.current.skirmishSelectFeatured),
                        const SizedBox(height: AppThemeSpacing.space12),
                        _scenes(),
                        const SizedBox(height: AppThemeSpacing.space28),
                        _sectionTitle(S.current.skirmishSelectCustomMaps),
                        const SizedBox(height: AppThemeSpacing.space12),
                        _customMaps(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: const WindowControls()),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.glassPill,
                  borderRadius: AppThemeBorders.radius24,
                  border: Border.all(color: AppThemeColors.borderSubtle),
                ),
                child: IconButton(
                  tooltip: S.current.backTooltip,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppThemeColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _state.load();
  }

  Widget _customMaps() => ValueListenableBuilder<List<MapDraft>?>(
    valueListenable: _state.drafts,
    builder: (context, drafts, _) {
      if (drafts == null) {
        return const Padding(
          padding: AppThemePaddings.v24,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (drafts.isEmpty) {
        return Padding(
          padding: AppThemePaddings.v12,
          child: Text(
            S.current.sceneSelectEmptyCustom,
            style: const TextStyle(color: AppThemeColors.textFaint),
          ),
        );
      }
      return _grid([
        for (final draft in drafts)
          MapDraftCardWidget(
            draft: draft,
            onTap: () => SceneLauncher.openDraft(
              context,
              draft,
              _state.difficulty.value,
            ),
          ),
      ]);
    },
  );

  Widget _grid(List<Widget> children) => GridView.count(
    shrinkWrap: true,
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1.4,
    physics: const NeverScrollableScrollPhysics(),
    children: children,
  );

  Widget _header() => Center(
    child: Column(
      spacing: AppThemeSpacing.space6,
      children: [
        Text(
          widget.mode.selectTitle,
          style: const TextStyle(
            color: AppThemeColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        Text(
              widget.mode.selectSubtitle,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 16,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 80.ms)
            .slideY(begin: -0.2, end: 0),
      ],
    ),
  );

  Widget _scenes() => ValueListenableBuilder<ProgressSnapshot?>(
    valueListenable: _state.progress,
    builder: (context, progressValue, _) {
      final progress = progressValue ?? ProgressSnapshot.empty;
      return _grid([
        for (final (index, scene) in _state.scenes.indexed)
          SceneCardWidget(
                scene: scene,
                progress: progress,
                onTap: () async {
                  await SceneLauncher.openScene(
                    context,
                    scene,
                    _state.difficulty.value,
                  );
                  await _state.load();
                },
              )
              .animate()
              .fadeIn(duration: 380.ms, delay: (120 + index * 90).ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                curve: Curves.easeOutCubic,
              ),
      ]);
    },
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: AppThemeColors.textMuted,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );
}
