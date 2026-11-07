import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/combat/unit_kind.dart';
import '../../../../generated/l10n.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../game_core/extensions/game_mode_extensions.dart';
import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/domain/models/obstacle_kind.dart';
import '../../../waves/domain/models/wave_loadout.dart';
import '../../../waves/impl/wave_loadout_generator.dart';
import '../../domain/enums/editor_tool.dart';
import '../../domain/models/editor_point.dart';
import '../../domain/models/editor_terrain_preview.dart';
import '../../domain/models/environment_settings.dart';
import '../../domain/models/ambience_settings.dart';
import '../../domain/models/map_draft.dart';
import '../../domain/models/painted_cell.dart';
import '../../domain/models/tree_cell.dart';
import '../../domain/models/water_path.dart';
import '../../domain/models/weather_keyframe.dart';
import '../../impl/editor_terrain_generator.dart';
import '../../impl/water_path_hit_tester.dart';
import 'map_editor_notice.dart';

export '../../domain/enums/editor_tool.dart';

/// Owns the map editor's draft-editing flow: the [MapDraft] itself, its
/// live terrain preview, brush selection, in-progress stroke, wave being
/// edited, and canvas zoom - every mutation is a public instruction method
/// that delegates its steps/calculations to single-purpose private helpers.
///
/// Registered per-editor-session with `getIt` by [MapEditorPage] (see the
/// `presentation-state-layer` instructions) and disposed when the page is
/// disposed.
class MapEditorDraftState {
  static const _homeSiteRemoveRadius = 32.0;
  static const _nodeRemoveRadius = 28.0;

  /// Most resource nodes a map may have.
  static const maxResourceNodes = 8;

  final WaterPathHitTester _waterHitTester = const WaterPathHitTester();

  final ValueNotifier<MapDraft> _draft;
  final ValueNotifier<EditorTerrainPreview?> _preview = ValueNotifier(null);
  final ValueNotifier<EditorTool> _tool = ValueNotifier(EditorTool.mountain);
  final ValueNotifier<double> _riverWidth = ValueNotifier(48);

  /// The brush type for the currently selected obstacle/water tool - null
  /// means "render with the map's own biome", the same look as before this
  /// feature existed.
  final ValueNotifier<Biome?> _variant = ValueNotifier(null);
  final ValueNotifier<int> _selectedWaveNumber = ValueNotifier(1);
  final ValueNotifier<List<EditorPoint>> _activeStroke = ValueNotifier(
    const [],
  );
  final ValueNotifier<double> _zoom = ValueNotifier(1.0);
  final ValueNotifier<double> _previewProgress = ValueNotifier(0.0);
  final ValueNotifier<MapEditorNotice?> _notice = ValueNotifier(null);

  final EditorTerrainGenerator _generator;
  Timer? _regenDebounce;
  int _generation = 0;
  bool _disposed = false;

  MapEditorDraftState(
    MapDraft initialDraft, {
    EditorTerrainGenerator? generator,
  }) : _draft = ValueNotifier(initialDraft),
       _generator = generator ?? EditorTerrainGenerator();

  ValueListenable<List<EditorPoint>> get activeStroke => _activeStroke;

  /// The wave the "Waves" panel currently shows/edits - falls back to an
  /// empty (auto) loadout when the wave has never been customized.
  WaveLoadout get currentLoadout => loadoutFor(_selectedWaveNumber.value);
  ValueListenable<MapDraft> get draft => _draft;

  /// A single [Listenable] combining every rebuild-relevant notifier, so the
  /// page can rebuild its whole (tightly-coupled) editor tree from one
  /// listener instead of nesting a builder per field. [notice] is
  /// deliberately excluded - the page listens to it separately.
  Listenable get listenable => Listenable.merge([
    _draft,
    _preview,
    _tool,
    _riverWidth,
    _variant,
    _selectedWaveNumber,
    _activeStroke,
    _zoom,
    _previewProgress,
  ]);

  /// Wave Defense has exactly one player base; Skirmish supports up to one
  /// per seat (see [GameMode.maxHomeSites]).
  int get maxHomeSites => _maxHomeSitesFor(_draft.value.mode);
  ValueListenable<MapEditorNotice?> get notice => _notice;
  ValueListenable<EditorTerrainPreview?> get preview => _preview;
  ValueListenable<double> get previewProgress => _previewProgress;
  ValueListenable<double> get riverWidth => _riverWidth;
  ValueListenable<int> get selectedWaveNumber => _selectedWaveNumber;
  ValueListenable<EditorTool> get tool => _tool;
  ValueListenable<Biome?> get variant => _variant;
  ValueListenable<double> get zoom => _zoom;

  void addKeyframe() {
    final timeline = _draft.value.environment.timeline;
    final nextProgress = _nextKeyframeProgress(timeline);
    _mutateEnvironment(
      (env) => env.copyWith(
        timeline: [
          ...timeline,
          WeatherKeyframe(atProgress: nextProgress),
        ],
      ),
    );
  }

  void applyArenaSize(String widthText, String heightText) {
    final width = _parseClampedDouble(widthText, 200, 8000);
    final height = _parseClampedDouble(heightText, 200, 8000);
    if (width == null || height == null) return;
    _mutateDraft((d) => d.copyWith(arenaWidth: width, arenaHeight: height));
  }

  void applyStartingGold(String text) {
    final gold = _parseClampedInt(text, 0, 100000);
    if (gold == null) return;
    _mutateDraft((d) => d.copyWith(startingGold: gold));
  }

  void applyWaveCount(String text) {
    final count = _parseClampedInt(text, 1, 200);
    if (count == null) return;
    _mutateDraft((d) => d.copyWith(waveCount: count));
    if (_selectedWaveNumber.value > count) _selectedWaveNumber.value = count;
  }

  void clearNotice() => _notice.value = null;

  void clearSelectedWave() {
    _replaceLoadout(WaveLoadout(waveNumber: _selectedWaveNumber.value));
  }

  void dispose() {
    _regenDebounce?.cancel();
    _disposed = true;
    _draft.dispose();
    _preview.dispose();
    _tool.dispose();
    _riverWidth.dispose();
    _variant.dispose();
    _selectedWaveNumber.dispose();
    _activeStroke.dispose();
    _zoom.dispose();
    _previewProgress.dispose();
    _notice.dispose();
  }

  void handlePanEnd() {
    final currentTool = _tool.value;
    final stroke = _activeStroke.value;
    final isWaterTool =
        currentTool == EditorTool.river ||
        currentTool == EditorTool.lake ||
        currentTool == EditorTool.lava ||
        currentTool == EditorTool.volcanicLake;
    if (isWaterTool && stroke.length >= 2) {
      _commitWaterPath(currentTool, stroke);
    }
    _activeStroke.value = const [];
  }

  /// A plain tap (press and release without dragging) on the canvas. The
  /// placement tools (home site, resource node) work only this way, and a
  /// brush stamps a single cell; the water tools need a drag to draw.
  void handleTap(Offset local, Size canvasSize) {
    final point = toWorld(local, canvasSize);
    switch (_tool.value) {
      case EditorTool.mountain:
      case EditorTool.dune:
      case EditorTool.tree:
      case EditorTool.erase:
        _paintAt(point);
      case EditorTool.homeSite:
        toggleHomeSiteAt(point);
      case EditorTool.resourceNode:
        toggleResourceNodeAt(point);
      case EditorTool.river:
      case EditorTool.lake:
      case EditorTool.lava:
      case EditorTool.volcanicLake:
        break; // a stroke needs a drag
    }
  }

  void handlePanStart(Offset local, Size canvasSize) {
    final point = toWorld(local, canvasSize);
    switch (_tool.value) {
      case EditorTool.mountain:
      case EditorTool.dune:
      case EditorTool.tree:
      case EditorTool.erase:
        _paintAt(point);
      case EditorTool.river:
      case EditorTool.lake:
      case EditorTool.lava:
      case EditorTool.volcanicLake:
        _activeStroke.value = [point];
      case EditorTool.homeSite:
        toggleHomeSiteAt(point);
      case EditorTool.resourceNode:
        toggleResourceNodeAt(point);
    }
  }

  void handlePanUpdate(Offset local, Size canvasSize) {
    final point = toWorld(local, canvasSize);
    switch (_tool.value) {
      case EditorTool.mountain:
      case EditorTool.dune:
      case EditorTool.tree:
      case EditorTool.erase:
        _paintAt(point);
      case EditorTool.river:
      case EditorTool.lake:
      case EditorTool.lava:
      case EditorTool.volcanicLake:
        _activeStroke.value = [..._activeStroke.value, point];
      case EditorTool.homeSite:
      case EditorTool.resourceNode:
        break; // single-tap placement only, handled in handlePanStart
    }
  }

  bool hasCustomLoadout(int waveNumber) =>
      loadoutFor(waveNumber).unitCounts.isNotEmpty;

  /// Runs the very first (non-debounced) terrain generation for a freshly
  /// opened draft - called once from the page's `initState`.
  Future<void> initialize() => _regenerate();

  WaveLoadout loadoutFor(int waveNumber) {
    for (final loadout in _draft.value.waveLoadouts) {
      if (loadout.waveNumber == waveNumber) return loadout;
    }
    return WaveLoadout(waveNumber: waveNumber);
  }

  void randomizeAllWaves() {
    _mutateDraft(
      (d) =>
          d.copyWith(waveLoadouts: WaveLoadoutGenerator.randomize(d.waveCount)),
    );
  }

  void randomizeSelectedWave() {
    _replaceLoadout(
      WaveLoadoutGenerator.randomizeWave(_selectedWaveNumber.value),
    );
  }

  void removeKeyframe(int index) {
    _mutateEnvironment((env) {
      final timeline = [...env.timeline]..removeAt(index);
      return env.copyWith(timeline: timeline);
    });
  }

  /// Swaps in a freshly-imported draft (keeping the original draft's id) and
  /// regenerates its preview immediately - used after an upload.
  Future<void> replaceDraft(MapDraft newDraft) async {
    _draft.value = newDraft;
    await _regenerate();
  }

  void replaceKeyframe(int index, WeatherKeyframe keyframe) {
    _mutateEnvironment((env) {
      final timeline = [...env.timeline];
      timeline[index] = keyframe;
      return env.copyWith(timeline: timeline);
    });
  }

  double resetZoom() {
    _zoom.value = 1.0;
    return _zoom.value;
  }

  void setBiome(Biome biome) => _mutateDraft((d) => d.copyWith(biome: biome));

  void setDynamicWeather(bool value) =>
      _mutateEnvironment((env) => env.copyWith(dynamicWeather: value));

  void setMode(GameMode mode) => _mutateDraft(
    (d) => d.copyWith(
      mode: mode,
      homeSites: d.homeSites.take(_maxHomeSitesFor(mode)).toList(),
    ),
  );

  void setName(String value) => _mutateDraft((d) => d.copyWith(name: value));

  void setPreviewProgress(double value) => _previewProgress.value = value;

  void setRiverWidth(double value) => _riverWidth.value = value;

  void setSelectedWaveNumber(int value) => _selectedWaveNumber.value = value;

  /// Replaces the map's environment-sound mix.
  void setAmbience(AmbienceSettings value) =>
      _mutateEnvironment((env) => env.copyWith(ambience: value));

  void setSunAngle(double value) =>
      _mutateEnvironment((env) => env.copyWith(sunAngle: value));

  void setTool(EditorTool value) => _tool.value = value;

  void setVariant(Biome? value) => _variant.value = value;

  void setWaveUnitCount(UnitKind kind, int count) {
    _replaceLoadout(currentLoadout.withCount(kind, count.clamp(0, 999)));
  }

  void setZoom(double value) => _zoom.value = value;

  /// Places a new numbered home site at [point], or removes an existing one
  /// if [point] lands near it. Wave Defense only ever has a single player
  /// base; Skirmish allows up to [maxHomeSites].
  void toggleHomeSiteAt(EditorPoint point) {
    final existingIndex = _findHomeSiteNear(point);
    final max = maxHomeSites;
    if (existingIndex == -1 && _draft.value.homeSites.length >= max) {
      _notice.value = MapEditorNotice(
        S.current.onlyHomeSitesSupportedEditorPage(max),
        icon: Icons.info_outline,
      );
      return;
    }
    _mutateDraft(
      (d) => existingIndex != -1
          ? _withHomeSiteRemoved(d, existingIndex)
          : _withHomeSiteAdded(d, point),
    );
  }

  /// Places a resource node at [point], or removes the one it lands near.
  void toggleResourceNodeAt(EditorPoint point) {
    final nodes = _draft.value.resourceNodes;
    final existing = nodes.indexWhere((n) => _isNodeAt(n, point));
    if (existing == -1 && nodes.length >= maxResourceNodes) {
      _notice.value = MapEditorNotice(
        S.current.onlyResourceNodesSupportedEditorPage(maxResourceNodes),
        icon: Icons.info_outline,
      );
      return;
    }
    _mutateDraft(
      (d) => d.copyWith(
        resourceNodes: existing == -1
            ? [...d.resourceNodes, point]
            : _withoutIndex(d.resourceNodes, existing),
      ),
    );
  }

  List<EditorPoint> _withoutIndex(List<EditorPoint> points, int index) => [
    for (final (i, p) in points.indexed)
      if (i != index) p,
  ];

  /// Whether the draft can be played as a skirmish: it needs a home site for
  /// every side. When it cannot, shows a notice saying so and returns false.
  bool canPlaySkirmish() {
    final needed = GameMode.skirmish.requiredHomeSites;
    if (_draft.value.homeSites.length >= needed) return true;
    _notice.value = MapEditorNotice(
      S.current.skirmishNeedsHomesEditorPage(needed),
      icon: Icons.info_outline,
    );
    return false;
  }

  /// Converts a canvas-local [Offset] into draft/world coordinates, given
  /// the canvas's current on-screen [canvasSize].
  EditorPoint toWorld(Offset local, Size canvasSize) {
    final currentDraft = _draft.value;
    return EditorPoint(
      x: (local.dx / canvasSize.width * currentDraft.arenaWidth).clamp(
        0,
        currentDraft.arenaWidth,
      ),
      y: (local.dy / canvasSize.height * currentDraft.arenaHeight).clamp(
        0,
        currentDraft.arenaHeight,
      ),
    );
  }

  double zoomBy(double factor) {
    _zoom.value = _clampZoom(_zoom.value * factor);
    return _zoom.value;
  }

  double _clampZoom(double value) => value.clamp(1.0, 4.0);

  void _commitWaterPath(EditorTool tool, List<EditorPoint> stroke) {
    final path = WaterPath(
      kind: switch (tool) {
        EditorTool.lake => WaterFeatureKind.lake,
        EditorTool.lava => WaterFeatureKind.lava,
        EditorTool.volcanicLake => WaterFeatureKind.volcanicLake,
        _ => WaterFeatureKind.river,
      },
      points: stroke,
      width: _riverWidth.value,
      variant: _variant.value,
    );
    _mutateDraft((d) => d.copyWith(waterPaths: [...d.waterPaths, path]));
  }

  int _findHomeSiteNear(EditorPoint point) =>
      _draft.value.homeSites.indexWhere((site) => _isHomeSiteAt(site, point));

  ObstacleKind? _kindForTool(EditorTool tool) => switch (tool) {
    EditorTool.mountain => ObstacleKind.mountain,
    EditorTool.dune => ObstacleKind.dune,
    EditorTool.tree => null,
    EditorTool.erase => null,
    EditorTool.river ||
    EditorTool.lake ||
    EditorTool.lava ||
    EditorTool.volcanicLake => null,
    EditorTool.homeSite => null,
    EditorTool.resourceNode => null,
  };

  int _maxHomeSitesFor(GameMode mode) => mode.maxHomeSites;

  void _mutateDraft(MapDraft Function(MapDraft) update) {
    _draft.value = update(_draft.value);
    _scheduleRegenerate();
  }

  void _mutateEnvironment(
    EnvironmentSettings Function(EnvironmentSettings) update,
  ) {
    _mutateDraft((d) => d.copyWith(environment: update(d.environment)));
  }

  double _nextKeyframeProgress(List<WeatherKeyframe> timeline) =>
      timeline.isEmpty
      ? 0.0
      : (timeline.last.atProgress + 0.25).clamp(0.0, 1.0);

  void _paintAt(EditorPoint point) {
    // Addressed from the draft's own size, never from the generated preview
    // (which may not exist yet): placing/erasing must work immediately.
    final draft = _draft.value;
    final grid = editorGridSize(draft.arenaWidth, draft.arenaHeight);
    final col = (point.x / kEditorCellSize).floor().clamp(0, grid.cols - 1);
    final row = (point.y / kEditorCellSize).floor().clamp(0, grid.rows - 1);
    final tool = _tool.value;

    // Trees are purely decorative (never block movement/building) so they
    // live in their own list, addable on any biome regardless of
    // [BiomePalette.hasTrees].
    if (tool == EditorTool.tree) {
      _mutateDraft((d) {
        final cells = [...d.treeCells]
          ..removeWhere((c) => c.col == col && c.row == row);
        cells.add(TreeCell(col: col, row: row, variant: _variant.value));
        return d.copyWith(treeCells: cells);
      });
      return;
    }

    if (tool == EditorTool.erase) {
      _mutateDraft((d) => _withEverythingErasedAt(d, point, col, row));
      return;
    }

    final kind = _kindForTool(tool);
    _mutateDraft((d) {
      final cells = [...d.paintedCells]
        ..removeWhere((c) => c.col == col && c.row == row);
      if (kind != null) {
        cells.add(
          PaintedCell(col: col, row: row, kind: kind, variant: _variant.value),
        );
      }
      return d.copyWith(paintedCells: cells);
    });
  }

  /// The eraser removes anything the author set at [point]: painted terrain,
  /// trees, river/lake/lava/volcanic-lake strokes and home sites.
  MapDraft _withEverythingErasedAt(
    MapDraft draft,
    EditorPoint point,
    int col,
    int row,
  ) {
    final reach = kEditorCellSize * 0.5;
    return draft.copyWith(
      paintedCells: [
        for (final c in draft.paintedCells)
          if (!(c.col == col && c.row == row)) c,
      ],
      treeCells: [
        for (final c in draft.treeCells)
          if (!(c.col == col && c.row == row)) c,
      ],
      waterPaths: [
        for (final path in draft.waterPaths)
          if (!_waterHitTester.hits(path, point, reach: reach)) path,
      ],
      homeSites: [
        for (final site in draft.homeSites)
          if (!_isHomeSiteAt(site, point)) site,
      ],
      resourceNodes: [
        for (final node in draft.resourceNodes)
          if (!_isNodeAt(node, point)) node,
      ],
    );
  }

  bool _isNodeAt(EditorPoint node, EditorPoint point) =>
      (node.x - point.x).abs() < _nodeRemoveRadius &&
      (node.y - point.y).abs() < _nodeRemoveRadius;

  bool _isHomeSiteAt(EditorPoint site, EditorPoint point) =>
      (site.x - point.x).abs() < _homeSiteRemoveRadius &&
      (site.y - point.y).abs() < _homeSiteRemoveRadius;

  double? _parseClampedDouble(String text, num min, num max) {
    final value = double.tryParse(text);
    if (value == null) return null;
    return value.clamp(min, max).toDouble();
  }

  int? _parseClampedInt(String text, num min, num max) {
    final value = int.tryParse(text);
    if (value == null) return null;
    return value.clamp(min, max).toInt();
  }

  Future<void> _regenerate() async {
    final generation = ++_generation;
    final result = await _generator.generate(_draft.value);
    if (_disposed || generation != _generation) return;
    _preview.value = result;
  }

  void _replaceLoadout(WaveLoadout loadout) {
    _mutateDraft((d) {
      final loadouts = [...d.waveLoadouts]
        ..removeWhere((l) => l.waveNumber == loadout.waveNumber);
      if (loadout.unitCounts.isNotEmpty) loadouts.add(loadout);
      return d.copyWith(waveLoadouts: loadouts);
    });
  }

  void _scheduleRegenerate() {
    _regenDebounce?.cancel();
    _regenDebounce = Timer(const Duration(milliseconds: 250), _regenerate);
  }

  MapDraft _withHomeSiteAdded(MapDraft d, EditorPoint point) {
    return d.copyWith(homeSites: [...d.homeSites, point]);
  }

  MapDraft _withHomeSiteRemoved(MapDraft d, int index) {
    final sites = [...d.homeSites]..removeAt(index);
    return d.copyWith(homeSites: sites);
  }
}
