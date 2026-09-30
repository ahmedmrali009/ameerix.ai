import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calls [builder] with `visible = true` once the widget first scrolls into
/// the viewport. Uses the nearest [Scrollable]; no extra packages needed.
/// Respects the OS "reduce motion" setting (visible immediately).
class OnVisible extends StatefulWidget {
  const OnVisible({super.key, required this.builder, this.viewportFraction = 0.9});

  final Widget Function(BuildContext context, bool visible) builder;

  /// Trigger when the top edge passes this fraction of the viewport height.
  final double viewportFraction;

  @override
  State<OnVisible> createState() => _OnVisibleState();
}

class _OnVisibleState extends State<OnVisible> {
  bool _visible = false;
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _visible = true;
    }
    if (_visible) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_check);
      _position = position;
      _position?.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_visible || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;
    if (top < viewport * widget.viewportFraction) {
      _position?.removeListener(_check);
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _visible);
}

/// Fade + short upward slide when scrolled into view.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero, this.offset = 24});

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return OnVisible(
      builder: (context, visible) => _RevealAnimation(visible: visible, delay: delay, offset: offset, child: child),
    );
  }
}

class _RevealAnimation extends StatefulWidget {
  const _RevealAnimation({required this.visible, required this.delay, required this.offset, required this.child});

  final bool visible;
  final Duration delay;
  final double offset;
  final Widget child;

  @override
  State<_RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<_RevealAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.visible) _start();
  }

  @override
  void didUpdateWidget(covariant _RevealAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) _start();
  }

  void _start() {
    final reduce = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduce) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final v = _curve.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * widget.offset), child: child),
        );
      },
    );
  }
}

/// Counts up to [value] when first visible, formatted for the active locale.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.decimals,
    required this.format,
    required this.style,
    this.duration = const Duration(milliseconds: 1600),
  });

  final double value;
  final int decimals;
  final String Function(String number) format;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    NumberFormat formatter;
    try {
      formatter = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals);
    } catch (_) {
      formatter = NumberFormat.decimalPatternDigits(locale: 'en', decimalDigits: decimals);
    }
    // Final value for screen readers (announced once, not every frame).
    final finalText = format(formatter.format(value));

    return Semantics(
      label: finalText,
      excludeSemantics: true,
      child: OnVisible(
        builder: (context, visible) => TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: visible ? value : 0),
          duration: visible ? duration : Duration.zero,
          curve: Curves.easeOutExpo,
          builder: (context, v, _) {
            final text = format(formatter.format(v));
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Stack(
                children: [
                  // Reserve the final width so the layout never jumps.
                  Opacity(opacity: 0, child: Text(finalText, style: style, maxLines: 1, softWrap: false)),
                  Text(text, style: style, maxLines: 1, softWrap: false),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
