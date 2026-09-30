import 'package:flutter/material.dart';

/// Subtle "magnetic" pull toward the pointer on desktop. Disabled for touch
/// input and when the OS requests reduced motion.
class Magnetic extends StatefulWidget {
  const Magnetic({super.key, required this.child, this.strength = .18});

  final Widget child;
  final double strength;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) return widget.child;
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final c = box.size.center(Offset.zero);
        final d = e.localPosition - c;
        setState(() => _offset = Offset(d.dx * widget.strength, d.dy * widget.strength * 1.4));
      },
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _offset),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, o, child) => Transform.translate(offset: o, child: child),
        child: widget.child,
      ),
    );
  }
}
