import 'dart:math';

/// Fades one discrete visual style out and the next one in when the wanted
/// style changes, so a switch (e.g. blowing leaves -> blowing snow as the
/// weather drifts) never pops: [opacity] eases to 0 over [fadeSeconds], the
/// shown [style] is swapped while nothing is visible, then [opacity] eases
/// back to 1.
class StyleCrossfade<T> {
  final double fadeSeconds;

  T _style;
  double _opacity = 1;

  StyleCrossfade(T initial, {this.fadeSeconds = 2.5}) : _style = initial;

  /// The style to draw right now.
  T get style => _style;

  /// How visible it should be (0..1).
  double get opacity => _opacity;

  /// Advances by [dt] seconds toward [wanted].
  void update(T wanted, double dt) {
    final step = dt / fadeSeconds;
    if (wanted != _style) {
      _opacity = max(0.0, _opacity - step);
      if (_opacity <= 0) _style = wanted;
    } else if (_opacity < 1) {
      _opacity = min(1.0, _opacity + step);
    }
  }
}
