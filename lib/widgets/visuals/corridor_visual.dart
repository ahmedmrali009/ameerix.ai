import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Abstract (not to scale) diagram of the Spain → GCC corridor.
/// Geography is kept left→right in every language (maps are not mirrored).
class CorridorVisual extends StatefulWidget {
  const CorridorVisual({super.key});

  @override
  State<CorridorVisual> createState() => _CorridorVisualState();
}

class _CorridorVisualState extends State<CorridorVisual> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _pulse.stop();
      _pulse.value = 0.6;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // Normalised positions (x, y).
  static const Offset spain = Offset(0.14, 0.42);
  static const Offset uae = Offset(0.76, 0.52);
  static const Offset ksa = Offset(0.58, 0.62);
  static const List<Offset> later = [
    Offset(0.60, 0.26), // Kuwait
    Offset(0.665, 0.38), // Bahrain
    Offset(0.695, 0.45), // Qatar
    Offset(0.83, 0.68), // Oman
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final labelStyle = t.caption.copyWith(color: AppColors.grey300, fontWeight: FontWeight.w600);

    return Semantics(
      container: true,
      label: l.a11yCorridorVisual,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lineDark),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Directionality(
                // Keep geographic orientation in RTL layouts.
                textDirection: TextDirection.ltr,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    Offset p(Offset n) => Offset(n.dx * w, n.dy * h);
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: _CorridorPainter(
                                animation: _pulse,
                                spain: spain,
                                targets: const [uae, ksa],
                                later: later,
                              ),
                            ),
                          ),
                        ),
                        // Barcelona label above the Spain node.
                        Positioned(
                          left: math.max(0.0, p(spain).dx - 70),
                          top: p(spain).dy - 40,
                          width: 140,
                          child: Text(
                            l.cityBarcelona,
                            textAlign: TextAlign.center,
                            textDirection: Directionality.of(context),
                            style: labelStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // UAE label to the right of its node.
                        Positioned(
                          left: p(uae).dx + 14,
                          top: p(uae).dy - 9,
                          width: math.max(40.0, w - p(uae).dx - 18),
                          child: Text(l.mapUae, style: labelStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        // KSA label below its node.
                        Positioned(
                          left: p(ksa).dx - 70,
                          top: p(ksa).dy + 14,
                          width: 140,
                          child: Text(
                            l.mapKsa,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _Legend(filled: true, label: l.intlPhase1Title),
              _Legend(filled: true, label: l.intlPhase2Title),
              _Legend(filled: false, label: l.intlPhase3Title),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.filled, required this.label});
  final bool filled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.white : Colors.transparent,
            border: Border.all(color: filled ? AppColors.white : AppColors.grey500, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: t.caption.copyWith(color: AppColors.grey400))),
      ],
    );
  }
}

class _CorridorPainter extends CustomPainter {
  _CorridorPainter({required this.animation, required this.spain, required this.targets, required this.later})
      : super(repaint: animation);

  final Animation<double> animation;
  final Offset spain;
  final List<Offset> targets;
  final List<Offset> later;

  Offset _p(Offset n, Size s) => Offset(n.dx * s.width, n.dy * s.height);

  Path _arc(Offset a, Offset b, Size s) {
    final mid = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - s.height * 0.32);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Faint "latitude" guides.
    final guide = Paint()
      ..color = AppColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }

    final origin = _p(spain, size);
    final dash = Paint()
      ..color = AppColors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < targets.length; i++) {
      final path = _arc(origin, _p(targets[i], size), size);
      for (final metric in path.computeMetrics()) {
        const on = 5.0;
        const off = 6.0;
        var d = 0.0;
        while (d < metric.length) {
          canvas.drawPath(metric.extractPath(d, math.min(d + on, metric.length)), dash);
          d += on + off;
        }
        // Travelling pulse.
        final phase = (animation.value + i * 0.45) % 1.0;
        final tangent = metric.getTangentForOffset(metric.length * phase);
        if (tangent != null) {
          final fade = math.sin(phase * math.pi);
          canvas.drawCircle(
            tangent.position,
            6,
            Paint()
              ..color = AppColors.white.withValues(alpha: 0.18 * fade)
              ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
          );
          canvas.drawCircle(tangent.position, 2.2, Paint()..color = AppColors.white.withValues(alpha: 0.9 * fade));
        }
      }
    }

    // Later-phase markets: hollow nodes.
    final hollow = Paint()
      ..color = AppColors.grey500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final n in later) {
      canvas.drawCircle(_p(n, size), 4.5, hollow);
    }

    // Active nodes.
    void node(Offset c) {
      canvas.drawCircle(c, 15, Paint()..color = AppColors.white.withValues(alpha: 0.06));
      canvas.drawCircle(
        c,
        10,
        Paint()
          ..color = AppColors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawCircle(c, 5, Paint()..color = AppColors.white);
    }

    node(origin);
    for (final target in targets) {
      node(_p(target, size));
    }
  }

  @override
  bool shouldRepaint(_CorridorPainter old) => false;
}
