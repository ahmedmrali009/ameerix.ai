import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/navigation.dart';

/// Shared maths for scroll-driven choreography.
///
/// Every cinematic scene maps a single progress value `p` (0 → 1) to its
/// visual state, so the visitor's scroll position *is* the timeline.
class Motion {
  const Motion._();

  static double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  /// Local progress of [p] inside the window [a, b].
  static double seg(double p, double a, double b) => clamp01((p - a) / (b - a));

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double easeOut(double x) => 1 - math.pow(1 - x, 3).toDouble();

  static double easeInOut(double x) =>
      x < .5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3).toDouble() / 2;
}

/// Motion preferences for the current viewport and platform.
///
/// * [reduced]: the OS asks for reduced motion. Scenes still respond to the
///   visitor's own scrolling (which is user-controlled), but ambient,
///   self-running animation is switched off.
/// * [compact]: phone-sized screen. Scenes use lighter, mobile-specific
///   compositions (fewer nodes, no 3D tilt, vertical layouts).
@immutable
class ResponsiveMotionController {
  const ResponsiveMotionController({required this.reduced, required this.compact, required this.rtl});

  final bool reduced;
  final bool compact;
  final bool rtl;

  static ResponsiveMotionController of(BuildContext context) => ResponsiveMotionController(
        reduced: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
        compact: MediaQuery.sizeOf(context).width < 960,
        rtl: Directionality.of(context) == TextDirection.rtl,
      );

  /// Mirrors a horizontal fraction for right-to-left process flows.
  double x(double fraction) => rtl ? 1 - fraction : fraction;
}

/// Deterministic pseudo-random numbers so visuals are identical on every
/// visit and every rebuild.
class SeededRandom {
  SeededRandom(int seed) : _s = seed & 0xFFFFFFFF;
  int _s;
  double next() {
    _s = (_s * 1664525 + 1013904223) & 0xFFFFFFFF;
    return _s / 4294967296.0;
  }
}

typedef ScrollProgressBuilder = Widget Function(
  BuildContext context,
  ValueListenable<double> progress,
  ValueListenable<bool> visible,
  Size viewport,
);

/// A full-viewport stage that stays pinned while the visitor scrolls
/// through [heightFactor] × viewport height. The builder receives a
/// progress notifier (0 at pin start, 1 at pin end) — only listeners of that
/// notifier rebuild/repaint while scrolling, never the whole page.
///
/// Implemented without slivers so it works inside the site's lazy
/// `SliverList`: the section's scroll-space offset is cached after layout
/// and progress is derived from the controller offset in the same frame,
/// which keeps pinning jitter-free.
class PinnedStorySection extends StatefulWidget {
  const PinnedStorySection({
    super.key,
    required this.heightFactor,
    this.compactHeightFactor,
    required this.builder,
    this.semanticLabel,
  });

  final double heightFactor;
  final double? compactHeightFactor;
  final ScrollProgressBuilder builder;
  final String? semanticLabel;

  @override
  State<PinnedStorySection> createState() => _PinnedStorySectionState();
}

class _PinnedStorySectionState extends State<PinnedStorySection> {
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  final ValueNotifier<double> _pinOffset = ValueNotifier<double>(0);
  final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);
  ScrollController? _controller;
  double? _sectionTop; // in scroll coordinates
  double _total = 0;
  double _viewport = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = PrimaryScrollHelper.maybeControllerOf(context);
    if (!identical(c, _controller)) {
      _controller?.removeListener(_onScroll);
      _controller = c;
      _controller?.addListener(_onScroll);
    }
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject();
      final c = _controller;
      if (box is RenderBox && box.attached && box.hasSize) {
        final offset = (c != null && c.hasClients) ? c.offset : 0.0;
        _sectionTop = offset + box.localToGlobal(Offset.zero).dy;
        _apply();
      }
    });
  }

  void _onScroll() {
    _apply();
    // Content above can settle (lazy lists, fonts); keep the cache honest.
    _scheduleMeasure();
  }

  void _apply() {
    final c = _controller;
    final top = _sectionTop;
    if (top == null || _total <= 0) return;
    final offset = (c != null && c.hasClients) ? c.offset : 0.0;
    final rel = top - offset; // section top relative to the viewport
    final travel = _total - _viewport;
    _pinOffset.value = (-rel).clamp(0.0, travel <= 0 ? 0.0 : travel);
    _progress.value = travel <= 0 ? 0 : Motion.clamp01(-rel / travel);
    _visible.value = rel < _viewport && rel + _total > 0;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onScroll);
    _progress.dispose();
    _pinOffset.dispose();
    _visible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 960;
    // Mobile browsers have a much shorter usable viewport and their address /
    // navigation bars change height while scrolling. The old compact factors
    // (often 1.6–1.8) left less than one viewport of actual scroll travel,
    // which compressed the whole cinematic timeline so later animation beats
    // could pass before they were clearly visible. Give compact scenes enough
    // scroll runway to show every stage while keeping desktop choreography
    // unchanged.
    final requestedFactor = compact ? (widget.compactHeightFactor ?? widget.heightFactor) : widget.heightFactor;
    final factor = compact ? math.max(requestedFactor, 2.25) : requestedFactor;
    _viewport = size.height;
    _total = size.height * factor;
    _scheduleMeasure();

    final stage = SizedBox(
      width: double.infinity,
      height: size.height,
      child: ClipRect(child: RepaintBoundary(child: widget.builder(context, _progress, _visible, size))),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: SizedBox(
        height: _total,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _pinOffset,
            child: stage,
            builder: (context, child) => Transform.translate(offset: Offset(0, _pinOffset.value), child: child),
          ),
        ),
      ),
    );
  }
}

/// Non-pinned variant: reports how far a normal section has travelled
/// through the viewport (0 when its top reaches the bottom of the screen,
/// 1 when its bottom leaves the top). Useful for parallax.
class ScrollProgressSection extends StatefulWidget {
  const ScrollProgressSection({super.key, required this.builder});

  final Widget Function(BuildContext context, ValueListenable<double> progress) builder;

  @override
  State<ScrollProgressSection> createState() => _ScrollProgressSectionState();
}

class _ScrollProgressSectionState extends State<ScrollProgressSection> {
  final ValueNotifier<double> _p = ValueNotifier<double>(0);
  ScrollController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = PrimaryScrollHelper.maybeControllerOf(context);
    if (!identical(c, _c)) {
      _c?.removeListener(_update);
      _c = c;
      _c?.addListener(_update);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => _update());
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final vh = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    _p.value = Motion.clamp01((vh - top) / (vh + box.size.height));
  }

  @override
  void dispose() {
    _c?.removeListener(_update);
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _p);
}

/// A repeating clock for ambient motion that only ticks while [visible] is
/// true and reduced motion is off — off-screen scenes cost nothing.
class AmbientClock extends StatefulWidget {
  const AmbientClock({super.key, required this.visible, required this.builder});

  final ValueListenable<bool> visible;
  final Widget Function(BuildContext context, ValueListenable<double> seconds) builder;

  @override
  State<AmbientClock> createState() => _AmbientClockState();
}

class _AmbientClockState extends State<AmbientClock> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<double> _seconds = ValueNotifier<double>(0);
  Duration _base = Duration.zero;
  Duration _last = Duration.zero;
  bool _reduced = false;

  void _tick(Duration elapsed) {
    _last = elapsed;
    _seconds.value = (_base + elapsed).inMicroseconds / 1e6;
  }

  @override
  void initState() {
    super.initState();
    widget.visible.addListener(_sync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _sync();
  }

  @override
  void didUpdateWidget(covariant AmbientClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      oldWidget.visible.removeListener(_sync);
      widget.visible.addListener(_sync);
      _sync();
    }
  }

  void _sync() {
    final run = widget.visible.value && !_reduced;
    if (run && !_ticker.isActive) {
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _base += _last;
      _last = Duration.zero;
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    widget.visible.removeListener(_sync);
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _seconds);
}

/// Lays out a label with the page's current text style for use in painters.
TextPainter paintLabel(String text, TextStyle style, {TextDirection? direction, double maxWidth = 400}) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction ?? TextDirection.ltr,
    maxLines: 2,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);
}
