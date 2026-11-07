import 'dart:math';
import 'dart:ui';

import 'package:boomspire/core/pathfinding/grid.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:boomspire/features/terrain/domain/models/obstacle_kind.dart';
import 'package:boomspire/features/terrain/domain/models/terrain_map.dart';
import 'package:boomspire/features/terrain/impl/terrain_ambience_sampler.dart';
import 'package:flutter_test/flutter_test.dart';

TerrainMap _map({
  required void Function(List<List<ObstacleKind?>>) paint,
  List<Point<int>> trees = const [],
  Biome biome = Biome.desertDunes,
}) {
  final grid = Grid(cols: 20, rows: 10, cellSize: 10);
  final kinds = List.generate(10, (_) => List<ObstacleKind?>.filled(20, null));
  paint(kinds);
  return TerrainMap(
    arenaWidth: 200,
    arenaHeight: 100,
    grid: grid,
    biome: biome,
    obstacleKinds: kinds,
    spawnPoints: const [],
    basePoint: const PathPoint(0, 0),
    treeCells: trees,
  );
}

void main() {
  const sampler = TerrainAmbienceSampler();
  const everything = Rect.fromLTWH(0, 0, 200, 100);

  test('water and lava are heard only when they are in view', () {
    final map = _map(
      paint: (k) {
        for (var r = 0; r < 10; r++) {
          k[r][2] = ObstacleKind.river; // left edge of the map
          k[r][18] = ObstacleKind.lava; // right edge of the map
        }
      },
    );
    final left = sampler.sample(map, const Rect.fromLTWH(0, 0, 60, 100));
    final right = sampler.sample(map, const Rect.fromLTWH(140, 0, 60, 100));
    expect(left.waterShare, greaterThan(0));
    expect(left.lavaShare, 0);
    expect(right.lavaShare, greaterThan(0));
    expect(right.waterShare, 0);
  });

  test('an open map with no water is silent', () {
    final s = sampler.sample(_map(paint: (_) {}), everything);
    expect(s.waterShare + s.lavaShare + s.seaShare, 0);
  });

  test('hand-placed trees in view make the view wooded', () {
    final trees = [for (var i = 0; i < 14; i++) Point(i, 3)];
    final map = _map(paint: (_) {}, trees: trees);
    expect(sampler.sample(map, everything).treeDensity, 1);
    expect(
      sampler.sample(map, const Rect.fromLTWH(150, 0, 50, 100)).treeDensity,
      0,
    );
  });

  test('a sea map is all sea', () {
    final map = _map(paint: (_) {}, biome: Biome.sea);
    expect(sampler.sample(map, everything).seaShare, 1);
  });
}
