import 'package:boomspire/core/di/service_locator.dart';
import 'package:boomspire/features/account/domain/models/account.dart';
import 'package:boomspire/features/account/domain/models/account_profile.dart';
import 'package:boomspire/features/account/domain/repos/account_repository.dart';
import 'package:boomspire/features/account/presentation/state/account_profile_state.dart';
import 'package:boomspire/features/game_core/domain/enums/game_mode.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/domain/repos/scene_catalog_repository.dart';
import 'package:boomspire/features/game_core/extensions/game_mode_extensions.dart';
import 'package:boomspire/features/game_core/impl/scene_catalog_repository_impl.dart';
import 'package:boomspire/features/level_select/presentation/scene_select_page.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/repos/map_draft_repository.dart';
import 'package:boomspire/features/progress/domain/models/progress_snapshot.dart';
import 'package:boomspire/features/progress/domain/repos/progress_repository.dart';
import 'package:boomspire/features/terrain/domain/repos/terrain_repository.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Drafts implements MapDraftRepository {
  final List<MapDraft> drafts;
  _Drafts(this.drafts);
  @override
  Future<void> deleteDraft(String id) async {}
  @override
  Future<List<MapDraft>> listDrafts() async => drafts;
  @override
  Future<MapDraft?> loadDraft(String id) async => null;
  @override
  Future<void> saveDraft(MapDraft draft) async {}
}

class _Progress implements ProgressRepository {
  @override
  Future<ProgressSnapshot> load() async => ProgressSnapshot.empty;
  @override
  Future<void> recordRun({
    required String sceneId,
    required int waveReached,
    required bool completed,
    int score = 0,
  }) async {}
}

class _Accounts implements AccountRepository {
  @override
  Future<Account> createAccount({required String name, String? avatarUrl}) =>
      throw UnimplementedError();
  @override
  Future<Account?> currentAccount() async => null;
  @override
  Future<AccountProfile?> loadProfile() async => null;
  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await S.load(const Locale('en'));
    await getIt.reset();
    getIt
      ..registerSingleton<AccountProfileState>(AccountProfileState(_Accounts()))
      ..registerSingleton<SceneCatalogRepository>(SceneCatalogRepositoryImpl())
      ..registerSingleton<MapDraftRepository>(
        _Drafts([
          const MapDraft(id: 'a', name: 'My TD', mode: GameMode.waveDefense),
          const MapDraft(id: 'b', name: 'My Skirmish', mode: GameMode.skirmish),
        ]),
      )
      ..registerSingleton<ProgressRepository>(_Progress())
      ..registerSingleton<TerrainRepository>(TerrainRepositoryImpl());
  });

  tearDown(() => getIt.reset());

  for (final mode in GameMode.values) {
    testWidgets('${mode.name}: one page shows that mode\'s scenes and maps, '
        'and scrolls without a scrollbar error', (tester) async {
      tester.view.physicalSize = const Size(900, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: SceneSelectPage(mode: mode)));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text(mode.selectTitle), findsOneWidget);
      final mine = GameScenes.all
          .followedBy(GameScenes.skirmishes)
          .where((s) => s.mode == mode)
          .toList();
      final others = GameScenes.all
          .followedBy(GameScenes.skirmishes)
          .where((s) => s.mode != mode);
      expect(mine, isNotEmpty);
      expect(find.text(mine.first.name, skipOffstage: false), findsOneWidget);
      for (final scene in others) {
        expect(find.text(scene.name, skipOffstage: false), findsNothing);
      }
      // Only this mode's saved map is offered.
      final own = mode == GameMode.skirmish ? 'My Skirmish' : 'My TD';
      final other = mode == GameMode.skirmish ? 'My TD' : 'My Skirmish';
      expect(find.text(own, skipOffstage: false), findsOneWidget);
      expect(find.text(other, skipOffstage: false), findsNothing);

      // Dragging used to throw "Scrollbar's ScrollController has no
      // ScrollPosition attached".
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  }
}
