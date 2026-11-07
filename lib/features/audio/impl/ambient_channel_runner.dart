import 'dart:math';

import '../domain/models/ambient_profile.dart';
import '../domain/models/ambient_source.dart';
import '../domain/models/ambient_target.dart';
import 'ambient_clip_player.dart';

/// Runs one channel: keeps its own smoothed level, cuts random parts out of
/// its recordings, fades each part in and out, and decides when the next
/// part starts.
///
/// - A **bed** channel always has a part playing while audible, starting the
///   next one just as the previous begins to fade so they crossfade.
/// - A **sporadic** channel plays one part now and then, at the rate the
///   planner asks for.
class AmbientChannelRunner {
  /// Below this level the channel counts as silent and starts nothing new.
  static const _audibleLevel = 0.02;

  /// Parts are released once the channel has faded below this.
  static const _inaudibleLevel = 0.004;

  /// Per-part loudness varies a little so repeats never sound identical.
  static const _minPartGain = 0.7;

  final AmbientProfile profile;
  final AmbientClipPlayer _player;
  final Random _random;

  final List<_Part> _parts = [];
  double _level = 0;
  double _secondsUntilNextPart = 0;

  AmbientChannelRunner(this.profile, this._player, this._random);

  /// How many parts are playing right now (for tests/diagnostics).
  int get activeParts => _parts.length;

  /// The channel's current smoothed level, 0..1.
  double get level => _level;

  void update(AmbientTarget target, double dt) {
    _followLevel(target.level, dt);
    _advanceParts(dt);
    _startPartIfDue(target, dt);
    _releaseIfInaudible(target);
  }

  void stopAll() {
    for (final part in _parts) {
      part.clip.stop();
    }
    _parts.clear();
  }

  /// Eases the level toward [target] with the profile's fade time as the
  /// time constant, so changes feed in and out instead of jumping.
  void _followLevel(double target, double dt) {
    final k = 1 - exp(-dt / profile.fadeSeconds);
    _level += (target - _level) * k;
  }

  void _advanceParts(double dt) {
    for (final part in _parts) {
      part.age += dt;
      part.clip.setVolume(
        part.envelope(profile.fadeSeconds) *
            _level *
            profile.maxVolume *
            part.gain,
      );
    }
    _parts.removeWhere((part) {
      final done = part.age >= part.length;
      if (done) part.clip.stop();
      return done;
    });
  }

  void _startPartIfDue(AmbientTarget target, double dt) {
    if (target.level < _audibleLevel) {
      _secondsUntilNextPart = 0;
      return;
    }
    final due = switch (profile.style) {
      AmbientStyle.bed => _bedNeedsNextPart(),
      AmbientStyle.sporadic => _sporadicIsDue(target, dt),
    };
    if (due) _startPart();
  }

  /// Start the next bed part once none is left, or the current one has
  /// reached its fade-out.
  bool _bedNeedsNextPart() =>
      _parts.isEmpty ||
      (_parts.length < 2 && _parts.last.remaining <= profile.fadeSeconds);

  bool _sporadicIsDue(AmbientTarget target, double dt) {
    if (target.partsPerMinute <= 0 || _parts.isNotEmpty) return false;
    _secondsUntilNextPart -= dt;
    if (_secondsUntilNextPart > 0) return false;
    final average = 60 / target.partsPerMinute;
    _secondsUntilNextPart = average * (0.6 + 0.8 * _random.nextDouble());
    return true;
  }

  void _startPart() {
    final source = _pickSource();
    final length =
        (profile.minPart +
                (profile.maxPart - profile.minPart) * _random.nextDouble())
            .clamp(0.5, source.seconds);
    final start = (source.seconds - length) * _random.nextDouble();
    _parts.add(
      _Part(
        clip: _player.start(source.file, startSeconds: start),
        length: length,
        gain: _minPartGain + (1 - _minPartGain) * _random.nextDouble(),
      ),
    );
  }

  AmbientSource _pickSource() {
    final suited = profile.sourcesFor(_level);
    return suited[_random.nextInt(suited.length)];
  }

  /// Once the environment has gone quiet and the fade has finished, stop and
  /// release everything.
  void _releaseIfInaudible(AmbientTarget target) {
    if (target.level == 0 && _level < _inaudibleLevel) stopAll();
  }
}

class _Part {
  final AmbientClip clip;
  final double length;
  final double gain;
  double age = 0;

  _Part({required this.clip, required this.length, required this.gain});

  double get remaining => length - age;

  /// 0..1 fade-in at the start and fade-out at the end of the part.
  double envelope(double fade) {
    final fadeIn = (age / fade).clamp(0.0, 1.0);
    final fadeOut = (remaining / fade).clamp(0.0, 1.0);
    return min(fadeIn, fadeOut);
  }
}
