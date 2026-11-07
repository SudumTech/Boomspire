import 'dart:convert';
import 'dart:io';

import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/game_content/domain/models/game_object_definition.dart';
import 'package:boomspire/features/game_content/impl/bundled_game_content_seed.dart';
import 'package:boomspire/features/game_content/impl/content_manifest_builder.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoBuiltIn = MobileUnitRepositoryImpl();
  // `BOOMSPIRE_WRITE_MANIFEST=1 flutter test test/content_manifest_test.dart`
  // rewrites both copies from the hardcoded blueprints.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await S.load(const Locale('en'));
    if (Platform.environment['BOOMSPIRE_WRITE_MANIFEST'] == '1') {
      final json = buildContentManifestJson();
      File('server/content_manifest.json').writeAsStringSync(json);
      File('assets/game_content/manifest.json').writeAsStringSync(json);
    }
  });

  test(
    'generated content_manifest.json parses into valid GameObjectDefinitions',
    () {
      final raw = File('server/content_manifest.json').readAsStringSync();
      final decoded = jsonDecode(raw) as List<dynamic>;

      final definitions = decoded
          .map((e) => GameObjectDefinition.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(definitions, isNotEmpty);
      expect(
        definitions.map((d) => d.id).toSet(),
        hasLength(definitions.length),
      );
      for (final d in definitions) {
        expect(d.version, greaterThan(0));
      }
    },
  );

  test('server and client manifest copies are identical', () {
    final server = File('server/content_manifest.json').readAsStringSync();
    final client = File('assets/game_content/manifest.json').readAsStringSync();
    expect(client, server);
  });
  test('manifest is up to date with the hardcoded blueprints', () {
    expect(
      File('assets/game_content/manifest.json').readAsStringSync(),
      buildContentManifestJson(),
      reason: 'run BOOMSPIRE_WRITE_MANIFEST=1 flutter test test/content_manifest_test.dart',
    );
  });

  group('every unit has a friendly and an enemy form', () {
    final repo = MobileUnitRepositoryImpl();

    test('both rosters cover every UnitKind', () {
      for (final team in [Team.invaders, Team.defaultPlayer]) {
        expect(
          repo.kindsFor(team).toSet(),
          UnitKind.values.toSet(),
          reason: team.label,
        );
      }
    });

    test('each form has a model file and combat stats in the manifest', () {
      final defs = {
        for (final e in jsonDecode(
          File('assets/game_content/manifest.json').readAsStringSync(),
        ) as List<dynamic>)
          (e as Map<String, dynamic>)['id'] as String: e,
      };
      for (final kind in UnitKind.values) {
        for (final side in ['ally', 'enemy']) {
          expect(
            File('assets/models/${side}_${kind.name}.json').existsSync(),
            isTrue,
            reason: 'missing model ${side}_${kind.name}.json',
          );
          final id =
              'unit.${side == 'ally' ? 'buildable' : 'invader'}.${kind.name}';
          final def = defs[id];
          expect(def, isNotNull, reason: 'manifest lacks $id');
          expect(def!['modelView']['path'], '${side}_${kind.name}');
          expect(def['maxHp'] as num, greaterThan(0), reason: id);
          expect(def['speed'] as num, greaterThan(0), reason: id);
          expect(def['range'] as num, greaterThan(0), reason: id);
          expect(def['damage'] as num, greaterThan(0), reason: id);
        }
        // Friendly units are bought, so they must carry a price.
        expect(
          repo.blueprintFor(Team.defaultPlayer, kind).cost,
          greaterThan(0),
          reason: '$kind',
        );
      }
    });
  });

  test(
    'the bundled seed drives unit stats: editing the JSON changes a unit',
    () async {
      final seed = await loadBundledGameContentSeed();
      expect(seed.where((d) => d.id.startsWith('unit.')).length, 28);
      final tank = seed.firstWhere((d) => d.id == 'unit.buildable.tank');
      final edited = [
        for (final d in seed)
          d.id == tank.id ? d.copyWith(cost: 999, range: 321) : d,
      ];
      final blueprint = MobileUnitRepositoryImpl(overrides: edited)
          .blueprintFor(Team.defaultPlayer, UnitKind.tank);
      expect(blueprint.cost, 999);
      expect(blueprint.attackRange, 321);
      // Unedited, the seed reproduces the built-in numbers exactly.
      final same = MobileUnitRepositoryImpl(overrides: seed);
      for (final team in [Team.invaders, Team.defaultPlayer]) {
        for (final kind in UnitKind.values) {
          final a = same.blueprintFor(team, kind);
          final b = repoBuiltIn.blueprintFor(team, kind);
          expect(a.totalDps, closeTo(b.totalDps, 1e-9), reason: '$team $kind');
          expect(a.cost, b.cost);
          expect(a.maxHealth, b.maxHealth);
          expect(a.isStealth, b.isStealth);
        }
      }
    },
  );
}
