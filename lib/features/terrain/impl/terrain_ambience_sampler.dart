import 'dart:math';
import 'dart:ui';

import '../domain/models/biome.dart';
import '../domain/models/obstacle_kind.dart';
import '../domain/models/terrain_ambience.dart';
import '../domain/models/terrain_map.dart';
import '../extensions/biome_extensions.dart';

/// Measures what part of the terrain the camera is looking at is water,
/// sea, lava and woodland, so the ambient sound engine can follow what the
/// player actually sees: a river you scroll toward gets louder, lava far off
/// screen is silent.
class TerrainAmbienceSampler {
  /// Hand-placed trees in view needed for a fully wooded soundscape.
  static const _fullForestTreeCount = 12;

  /// How wooded a biome that grows trees on its own already sounds.
  static const _naturalForestDensity = 0.5;

  const TerrainAmbienceSampler();

  TerrainAmbience sample(TerrainMap map, Rect view) {
    final cellSize = map.grid.cellSize;
    final firstCol = max(0, (view.left / cellSize).floor());
    final lastCol = min(map.grid.cols - 1, (view.right / cellSize).floor());
    final firstRow = max(0, (view.top / cellSize).floor());
    final lastRow = min(map.grid.rows - 1, (view.bottom / cellSize).floor());
    final cells = max(1, (lastCol - firstCol + 1) * (lastRow - firstRow + 1));

    var water = 0;
    var sea = 0;
    var lava = 0;
    var naturalTrees = false;
    for (var row = firstRow; row <= lastRow; row++) {
      for (var col = firstCol; col <= lastCol; col++) {
        switch (map.obstacleKinds[row][col]) {
          case ObstacleKind.river || ObstacleKind.lake:
            water++;
          case ObstacleKind.lava || ObstacleKind.volcanicLake:
            lava++;
          default:
            break;
        }
        final biome = map.biomeAt(col, row);
        if (biome == Biome.sea) sea++;
        if (biome.palette.hasTrees) naturalTrees = true;
      }
    }

    final placedTrees = map.treeCells
        .where(
          (t) =>
              t.x >= firstCol &&
              t.x <= lastCol &&
              t.y >= firstRow &&
              t.y <= lastRow,
        )
        .length;
    final trees = max(
      placedTrees / _fullForestTreeCount,
      naturalTrees ? _naturalForestDensity : 0.0,
    );

    return TerrainAmbience(
      treeDensity: trees.clamp(0.0, 1.0),
      waterShare: water / cells,
      seaShare: sea / cells,
      lavaShare: lava / cells,
    );
  }
}
