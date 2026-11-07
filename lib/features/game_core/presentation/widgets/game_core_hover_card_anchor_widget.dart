import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shows [cardBuilder]'s card in a floating overlay above [child] while the
/// mouse hovers it - the same behaviour the tower build buttons use, as a
/// reusable wrapper.
class GameCoreHoverCardAnchorWidget extends StatefulWidget {
  final Widget child;
  final WidgetBuilder cardBuilder;
  final double width;

  const GameCoreHoverCardAnchorWidget({
    super.key,
    required this.child,
    required this.cardBuilder,
    this.width = 210,
  });

  @override
  State<GameCoreHoverCardAnchorWidget> createState() =>
      _GameCoreHoverCardAnchorWidgetState();
}

class _GameCoreHoverCardAnchorWidgetState
    extends State<GameCoreHoverCardAnchorWidget> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  void _show() {
    _hide();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: widget.width,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -10),
          child: widget
              .cardBuilder(overlayContext)
              .animate()
              .fadeIn(duration: 140.ms, curve: Curves.easeOut)
              .scaleXY(begin: 0.92, duration: 140.ms, curve: Curves.easeOut)
              .slideY(begin: 0.06, duration: 140.ms, curve: Curves.easeOut),
        ),
      ),
    );
    overlay.insert(_entry!);
  }
}
