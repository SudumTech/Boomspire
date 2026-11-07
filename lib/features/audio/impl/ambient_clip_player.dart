/// One part of a recording that is currently playing.
abstract class AmbientClip {
  /// Sets the playback volume (0..1).
  void setVolume(double volume);

  /// Stops and releases it.
  void stop();
}

/// Starts parts of recordings - the only thing the ambient engine needs
/// from a real audio backend, so the engine itself can be tested with a
/// fake.
abstract class AmbientClipPlayer {
  /// Starts playing [file] from [startSeconds] at volume 0 (the engine fades
  /// it in with [AmbientClip.setVolume]).
  AmbientClip start(String file, {required double startSeconds});
}
