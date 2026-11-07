import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import 'ambient_clip_player.dart';

/// Plays ambient parts with `audioplayers` (the engine behind flame_audio):
/// one short-lived player per part, started at the requested offset.
class AudioPlayersAmbientClipPlayer implements AmbientClipPlayer {
  const AudioPlayersAmbientClipPlayer();

  @override
  AmbientClip start(String file, {required double startSeconds}) =>
      _AudioPlayersClip(file, startSeconds);
}

class _AudioPlayersClip implements AmbientClip {
  /// Volume changes smaller than this are not worth a platform call.
  static const _volumeStep = 0.01;

  final AudioPlayer _player = AudioPlayer();
  double _volume = 0;
  double _appliedVolume = -1;
  bool _ready = false;
  bool _stopped = false;

  _AudioPlayersClip(String file, double startSeconds) {
    unawaited(_begin(file, startSeconds));
  }

  Future<void> _begin(String file, double startSeconds) async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(AssetSource('audio/$file'));
      if (_stopped) return _dispose();
      await _player.seek(Duration(milliseconds: (startSeconds * 1000).round()));
      await _player.setVolume(_volume);
      _appliedVolume = _volume;
      await _player.resume();
      _ready = true;
      if (_stopped) _dispose();
    } on Object {
      // A missing/undecodable file just means this part stays silent.
      _dispose();
    }
  }

  @override
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    if (!_ready || _stopped) return;
    if ((_volume - _appliedVolume).abs() < _volumeStep) return;
    _appliedVolume = _volume;
    unawaited(_player.setVolume(_volume));
  }

  @override
  void stop() {
    if (_stopped) return;
    _stopped = true;
    if (_ready) _dispose();
  }

  void _dispose() {
    _stopped = true;
    unawaited(_player.dispose());
  }
}
