import 'package:flutter/material.dart';

import '../core/navigation.dart';

typedef PressableBuilder = Widget Function(BuildContext context, PressableState state);

@immutable
class PressableState {
  const PressableState({required this.hovered, required this.focused});
  final bool hovered;
  final bool focused;
  bool get active => hovered || focused;
}

/// Base interactive element used by links, buttons and cards.
///
/// * Mouse: pointer cursor + hover state.
/// * Keyboard: focusable, activates with Enter/Space, exposes focus state.
/// * Semantics: rendered as a real `<a href>` on the web when [route] is set
///   (crawlable, supports "open in new tab" via assistive tech), otherwise as
///   a button.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    this.route,
    this.onTap,
    required this.builder,
    this.semanticLabel,
    this.excludeChildSemantics = false,
  }) : assert(route != null || onTap != null, 'Provide a route or an onTap callback');

  final String? route;
  final VoidCallback? onTap;
  final PressableBuilder builder;
  final String? semanticLabel;
  final bool excludeChildSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;

  void _activate() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.route != null) {
      AppNavigator.go(context, widget.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLink = widget.route != null;
    Widget child = widget.builder(context, PressableState(hovered: _hovered, focused: _focused));
    if (widget.excludeChildSemantics) child = ExcludeSemantics(child: child);

    return Semantics(
      container: true,
      link: isLink,
      linkUrl: isLink ? Uri.parse(widget.route!) : null,
      button: !isLink,
      label: widget.semanticLabel,
      onTap: _activate,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _activate();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          excludeFromSemantics: true,
          child: child,
        ),
      ),
    );
  }
}

/// Visible keyboard-focus ring drawn around interactive elements.
class FocusRing extends StatelessWidget {
  const FocusRing({super.key, required this.visible, required this.child, this.radius = 999, this.color});

  final bool visible;
  final Widget child;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 2),
        border: Border.all(
          color: visible ? (color ?? const Color(0xFF737373)) : const Color(0x00000000),
          width: 2,
        ),
      ),
      child: child,
    );
  }
}
