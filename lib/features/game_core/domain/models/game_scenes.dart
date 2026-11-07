import '../../../terrain/domain/models/biome.dart';
import '../../../map_editor/domain/models/ambience_settings.dart';
import '../../../map_editor/domain/models/environment_settings.dart';
import '../../../map_editor/domain/models/weather_keyframe.dart';
import 'game_config.dart';
import 'game_scene.dart';

/// The full campaign catalog shown on the level-select screen. Every scene
/// pairs a biome with its own wave count, opening strategy bias, and base
/// placement/attack-direction layout.
///
/// [all]/[skirmishes] start out as the built-in [_defaultAll]/
/// [_defaultSkirmishes] literals below (so the game has a full catalog
/// offline and in tests, with zero network) and can be layered with
/// server-synced scenes via [applyOverrides] - see `SceneSyncService`,
/// called once at boot the same way `GameContentSyncService` overrides
/// tower/unit stats.
class GameScenes {
  static const List<GameScene> _defaultAll = [
    GameScene(
      id: 'green-line',
      name: 'Green Line',
      briefing:
          'Open fields, a single dirt road in from the west. A clean, '
          'standard defense to learn the ropes.',
      biome: Biome.grassPlains,
      environment: _meadow,
      waveCount: 6,
      aggressionBias: 0.0,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
    GameScene(
      id: 'frozen-pincer',
      name: 'Frozen Pincer',
      briefing:
          'Your base sits exposed in the open tundra - the enemy splits '
          'its assault across two fronts at once.',
      biome: Biome.snowTundra,
      environment: _tundra,
      waveCount: 7,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'dune-siege',
      name: 'Dune Siege',
      briefing:
          'A dug-in corner outpost under siege from every direction '
          'across the dunes. No safe side.',
      biome: Biome.desertDunes,
      environment: _desert,
      waveCount: 8,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.northEastCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'forest-gauntlet',
      name: 'Forest Gauntlet',
      briefing:
          'The longest campaign - full encirclement through dense '
          'mountain forest, escalating wave after wave.',
      biome: Biome.mountainForest,
      environment: _woods,
      waveCount: 9,
      aggressionBias: 0.15,
      homeLayout: HomeLayout.southWestCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'ruined-downtown',
      name: 'Ruined Downtown',
      briefing:
          'A collapsed skyline hems in your outpost - the enemy pushes '
          'in from two shattered avenues at once.',
      biome: Biome.cityRuins,
      environment: _ruins,
      waveCount: 7,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'savanna-crossing',
      name: 'Savanna Crossing',
      briefing:
          'Wide open grassland with nowhere to hide - a single dusty '
          'trail carries every assault straight for the base.',
      biome: Biome.savanna,
      environment: _savanna,
      waveCount: 6,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
    GameScene(
      id: 'frozen-summit',
      name: 'Frozen Summit',
      briefing:
          'A dug-in summit outpost above the ice line, besieged from '
          'every ridge line around it.',
      biome: Biome.frozenPeaks,
      environment: _peaks,
      waveCount: 8,
      aggressionBias: 0.12,
      homeLayout: HomeLayout.northEastCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'coastal-blockade',
      name: 'Coastal Blockade',
      briefing:
          'A sea platform under blockade - armored landing forces shell the '
          'base from both open flanks across the water.',
      biome: Biome.sea,
      environment: _coast,
      waveCount: 8,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'windy-lowlands',
      name: 'Windy Lowlands',
      briefing:
          'Gusts never stop rolling across this open grassland, bending '
          'the fields sideways in long green waves.',
      biome: Biome.grassPlains,
      environment: _gusts,
      waveCount: 6,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
    GameScene(
      id: 'howling-icefield',
      name: 'Howling Icefield',
      briefing:
          'A relentless polar wind drives sheets of snow sideways across '
          'the ice - visibility is the enemy as much as the assault.',
      biome: Biome.snowTundra,
      environment: _blizzard,
      waveCount: 7,
      aggressionBias: 0.08,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'dust-devil-flats',
      name: 'Dust Devil Flats',
      briefing:
          'Hot desert wind whips loose sand into stinging clouds across '
          'the flats, surrounding a lone dug-in outpost.',
      biome: Biome.desertDunes,
      environment: _dustStorm,
      waveCount: 7,
      aggressionBias: 0.08,
      homeLayout: HomeLayout.southWestCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'amber-canopy',
      name: 'Amber Canopy',
      briefing:
          'A steady wind strips the mountain canopy bare, filling the air '
          'with a constant fall of gold, red and brown leaves.',
      biome: Biome.mountainForest,
      environment: _canopy,
      waveCount: 6,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
  ];

  /// Skirmish scenes: home-vs-home matches where every seat in
  /// [GameScene.homeSites] builds up and fights to destroy the others'
  /// homes, instead of surviving scripted waves. Only one seat is AI-owned
  /// for now (see the multiplayer/team-select plan for more seats).
  static const List<GameScene> _defaultSkirmishes = [
    GameScene(
      id: 'twin-outposts',
      name: 'Twin Outposts',
      briefing:
          'Home against home across open grassland - build up and strike '
          'before the AI commander finishes theirs.',
      biome: Biome.grassPlains,
      environment: _meadow,
      mode: GameMode.skirmish,
      startingGold: GameConfig.startingSkirmishGold,
      homeSites: [
        HomeSite(
          layout: HomeLayout.southWestCorner,
          owner: HomeSiteOwner.player,
        ),
        HomeSite(layout: HomeLayout.northEastCorner, owner: HomeSiteOwner.ai),
      ],
      // One contested node dead-center, plus one tucked closer to each
      // base - fought over by whichever side gets a vehicle there first.
      resourceNodeSites: [
        ResourceNodeSite(dx: 0.5, dy: 0.5),
        ResourceNodeSite(dx: 0.25, dy: 0.7),
        ResourceNodeSite(dx: 0.75, dy: 0.3),
      ],
    ),
    GameScene(
      id: 'frostbite-duel',
      name: 'Frostbite Duel',
      briefing:
          'Home against home in a snow-blind tundra whiteout - the wind '
          'never lets either commander see far past their own walls.',
      biome: Biome.snowTundra,
      environment: _tundra,
      mode: GameMode.skirmish,
      startingGold: GameConfig.startingSkirmishGold,
      homeSites: [
        HomeSite(
          layout: HomeLayout.southWestCorner,
          owner: HomeSiteOwner.player,
        ),
        HomeSite(layout: HomeLayout.northEastCorner, owner: HomeSiteOwner.ai),
      ],
      resourceNodeSites: [
        ResourceNodeSite(dx: 0.5, dy: 0.5),
        ResourceNodeSite(dx: 0.25, dy: 0.7),
        ResourceNodeSite(dx: 0.75, dy: 0.3),
      ],
    ),
    GameScene(
      id: 'dust-bowl-duel',
      name: 'Dust Bowl Duel',
      briefing:
          'Home against home across a wind-scoured dune field - stinging '
          'blown sand covers whichever side pushes out first.',
      biome: Biome.desertDunes,
      environment: _desert,
      mode: GameMode.skirmish,
      startingGold: GameConfig.startingSkirmishGold,
      homeSites: [
        HomeSite(
          layout: HomeLayout.southWestCorner,
          owner: HomeSiteOwner.player,
        ),
        HomeSite(layout: HomeLayout.northEastCorner, owner: HomeSiteOwner.ai),
      ],
      resourceNodeSites: [
        ResourceNodeSite(dx: 0.5, dy: 0.5),
        ResourceNodeSite(dx: 0.25, dy: 0.7),
        ResourceNodeSite(dx: 0.75, dy: 0.3),
      ],
    ),
    GameScene(
      id: 'russet-woods-duel',
      name: 'Russet Woods Duel',
      briefing:
          'Home against home in a windblown mountain forest - drifting '
          'autumn leaves cover the ground between the two camps.',
      biome: Biome.mountainForest,
      environment: _woods,
      mode: GameMode.skirmish,
      startingGold: GameConfig.startingSkirmishGold,
      homeSites: [
        HomeSite(
          layout: HomeLayout.southWestCorner,
          owner: HomeSiteOwner.player,
        ),
        HomeSite(layout: HomeLayout.northEastCorner, owner: HomeSiteOwner.ai),
      ],
      resourceNodeSites: [
        ResourceNodeSite(dx: 0.5, dy: 0.5),
        ResourceNodeSite(dx: 0.25, dy: 0.7),
        ResourceNodeSite(dx: 0.75, dy: 0.3),
      ],
    ),
  ];

  // --- environments: each map's weather over a match and its sound mix ----
  // (the weather drifts between these keyframes; the sound follows the
  // weather and the terrain in view, scaled by the map's AmbienceSettings).

  static const _meadow = EnvironmentSettings(
    sunAngle: 0.45,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.25,
        cloudCover: 0.3,
        birdActivity: 0.8,
      ),
      WeatherKeyframe(
        atProgress: 0.5,
        windStrength: 0.35,
        cloudCover: 0.5,
        birdActivity: 0.6,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.2,
        cloudCover: 0.2,
        birdActivity: 0.9,
      ),
    ],
  );

  static const _gusts = EnvironmentSettings(
    sunAngle: 0.5,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.8,
        cloudCover: 0.5,
        birdActivity: 0.3,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.9,
        cloudCover: 0.6,
        birdActivity: 0.2,
      ),
    ],
    ambience: AmbienceSettings(wind: 1.3, birds: 0.7),
  );

  static const _tundra = EnvironmentSettings(
    sunAngle: 0.35,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.4,
        snowIntensity: 0.3,
        fogDensity: 0.2,
        cloudCover: 0.6,
      ),
      WeatherKeyframe(
        atProgress: 0.5,
        windStrength: 0.5,
        snowIntensity: 0.6,
        fogDensity: 0.3,
        cloudCover: 0.7,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.3,
        snowIntensity: 0.2,
        fogDensity: 0.15,
        cloudCover: 0.5,
      ),
    ],
    ambience: AmbienceSettings(birds: 0.2),
  );

  static const _blizzard = EnvironmentSettings(
    sunAngle: 0.3,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.9,
        snowIntensity: 0.7,
        fogDensity: 0.3,
        cloudCover: 0.8,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.7,
        snowIntensity: 0.5,
        fogDensity: 0.25,
        cloudCover: 0.7,
      ),
    ],
    ambience: AmbienceSettings(wind: 1.4, snow: 1.2, birds: 0),
  );

  static const _desert = EnvironmentSettings(
    sunAngle: 0.55,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.3,
        dustIntensity: 0.25,
        birdActivity: 0.15,
      ),
      WeatherKeyframe(
        atProgress: 0.6,
        windStrength: 0.45,
        dustIntensity: 0.4,
        birdActivity: 0.1,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.25,
        dustIntensity: 0.2,
        birdActivity: 0.15,
      ),
    ],
    ambience: AmbienceSettings(birds: 0.3),
  );

  static const _dustStorm = EnvironmentSettings(
    sunAngle: 0.6,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.8,
        dustIntensity: 0.8,
        cloudCover: 0.3,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.6,
        dustIntensity: 0.6,
        cloudCover: 0.2,
      ),
    ],
    ambience: AmbienceSettings(wind: 1.2, dust: 1.3, birds: 0),
  );

  static const _woods = EnvironmentSettings(
    sunAngle: 0.4,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.3,
        cloudCover: 0.4,
        birdActivity: 0.8,
      ),
      WeatherKeyframe(
        atProgress: 0.55,
        windStrength: 0.4,
        rainIntensity: 0.4,
        cloudCover: 0.75,
        birdActivity: 0.3,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.25,
        cloudCover: 0.4,
        birdActivity: 0.8,
      ),
    ],
    ambience: AmbienceSettings(birds: 1.1, leaves: 1.2),
  );

  static const _canopy = EnvironmentSettings(
    sunAngle: 0.35,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.6,
        cloudCover: 0.4,
        birdActivity: 0.5,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.5,
        cloudCover: 0.5,
        birdActivity: 0.4,
      ),
    ],
    ambience: AmbienceSettings(leaves: 1.4),
  );

  static const _ruins = EnvironmentSettings(
    sunAngle: 0.5,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.3,
        dustIntensity: 0.25,
        fogDensity: 0.25,
        cloudCover: 0.6,
        birdActivity: 0.1,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.4,
        dustIntensity: 0.3,
        fogDensity: 0.3,
        cloudCover: 0.7,
        birdActivity: 0.05,
      ),
    ],
    ambience: AmbienceSettings(birds: 0.3),
  );

  static const _savanna = EnvironmentSettings(
    sunAngle: 0.6,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.3,
        dustIntensity: 0.15,
        cloudCover: 0.2,
        birdActivity: 0.8,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.35,
        dustIntensity: 0.2,
        cloudCover: 0.3,
        birdActivity: 0.7,
      ),
    ],
    ambience: AmbienceSettings(birds: 1.1),
  );

  static const _peaks = EnvironmentSettings(
    sunAngle: 0.4,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.8,
        snowIntensity: 0.5,
        fogDensity: 0.3,
        cloudCover: 0.7,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.6,
        snowIntensity: 0.3,
        fogDensity: 0.2,
        cloudCover: 0.6,
      ),
    ],
    ambience: AmbienceSettings(wind: 1.3, birds: 0),
  );

  static const _coast = EnvironmentSettings(
    sunAngle: 0.5,
    timeline: [
      WeatherKeyframe(
        atProgress: 0,
        windStrength: 0.6,
        cloudCover: 0.5,
        birdActivity: 0.6,
      ),
      WeatherKeyframe(
        atProgress: 0.6,
        windStrength: 0.75,
        rainIntensity: 0.3,
        cloudCover: 0.75,
        birdActivity: 0.3,
      ),
      WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.5,
        cloudCover: 0.5,
        birdActivity: 0.6,
      ),
    ],
    ambience: AmbienceSettings(sea: 1.3, water: 1.2, birds: 0.9),
  );

  static List<GameScene> _all = _defaultAll;
  static List<GameScene> _skirmishes = _defaultSkirmishes;

  static List<GameScene> get all => _all;

  static List<GameScene> get skirmishes => _skirmishes;

  const GameScenes._();

  /// Layers server/cache-synced scenes (see `SceneSyncService`) on top of
  /// the built-in defaults - called once at boot, mirroring how
  /// `setupServiceLocator(gameContentOverrides:)` overrides tower/unit
  /// stats. [scenes] is split back into wave-defense/skirmish by
  /// [GameScene.mode]; a scene whose [GameScene.id] matches a default
  /// replaces it, any other id is appended - so the server can both patch
  /// an existing map and ship a brand new one without a client release.
  static void applyOverrides(List<GameScene> scenes) {
    _all = _mergeById(
      _defaultAll,
      scenes.where((s) => s.mode == GameMode.waveDefense),
    );
    _skirmishes = _mergeById(
      _defaultSkirmishes,
      scenes.where((s) => s.mode == GameMode.skirmish),
    );
  }

  /// Test-only hook to undo [applyOverrides] between tests that don't share
  /// process state cleanly otherwise.
  static void resetOverridesForTest() {
    _all = _defaultAll;
    _skirmishes = _defaultSkirmishes;
  }

  static List<GameScene> _mergeById(
    List<GameScene> base,
    Iterable<GameScene> incoming,
  ) {
    final byId = {for (final s in base) s.id: s};
    for (final s in incoming) {
      byId[s.id] = s;
    }
    return byId.values.toList(growable: false);
  }
}
