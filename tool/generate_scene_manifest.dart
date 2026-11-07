// Regenerates the scene manifest (bundled `assets/scenes/scenes.json` and
// the server copy). It imports Flutter-backed code, so `dart run` can't load
// it; regenerate via the test runner instead:
//
//   BOOMSPIRE_WRITE_SCENES=1 flutter test test/scene_manifest_test.dart
//
// The logic lives in lib/features/game_core/impl/scene_manifest_builder.dart.
// Bump the affected scene's `version` by hand before committing so clients
// with a cached copy pick the change up.
