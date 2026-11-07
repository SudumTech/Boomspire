// Regenerates the content manifest (server copy + bundled seed asset).
// It imports Flutter-backed code, so `dart run` can't load it; regenerate via
// the test runner instead:
//
//   BOOMSPIRE_WRITE_MANIFEST=1 flutter test test/content_manifest_test.dart
//
// The logic lives in lib/features/game_content/impl/content_manifest_builder.dart.
// Bump the affected entries' `version` by hand before committing so clients
// with a cached copy pick the change up.
