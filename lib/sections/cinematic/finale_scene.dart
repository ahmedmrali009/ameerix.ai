import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../core/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/magnetic.dart';

/// Final cinematic call to action: "From intelligence / to opportunity."
/// over a faint intelligence network on deep blue. One restrained gold
/// opportunity signal travels through the network. Then the invitation and
/// the two actions (request a demo, explore the platform) appear.
class FinaleCta extends StatelessWidget {
  const FinaleCta({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PinnedStorySection(
      heightFactor: 1.9,
      compactHeightFactor: 1.6,
      builder: (context, progress, visible, size) {
        final t = AppTypography.of(context);
        final m = ResponsiveMotionController.of(context);
        final fs = (size.width * (m.compact ? .12 : .08)).clamp(42.0, 132.0);
        final latin = t.usesUppercase;
        final style = t.display.copyWith(
          fontSize: fs,
          height: latin ? 1.0 : 1.3,
          letterSpacing: latin ? -fs * .045 : 0,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        );
        final zh = Localizations.localeOf(context).languageCode == 'zh';
        return Tone(
          palette: TonePalette.opportunity,
          child: Stack(fit: StackFit.expand, children: [
            const ColoredBox(color: Color(0xFF040C22)),
            const AmbientLighting(palette: TonePalette.opportunity),
            ExcludeSemantics(
              child: AmbientClock(
                visible: visible,
                builder: (context, clock) => CustomPaint(painter: _NetworkPainter(clock: clock, motion: m)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Breakpoints.gutter(context)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) {
                      final p = progress.value;
                      Widget reveal(double a, double b, Widget child) {
                        final q = Motion.easeOut(Motion.seg(p, a, b));
                        return Opacity(opacity: q, child: Transform.translate(offset: Offset(0, (1 - q) * 16), child: child));
                      }

                      Widget line(String text, int i) {
                        final words = zh ? [text] : text.split(' ');
                        Widget w = Wrap(alignment: WrapAlignment.center, children: [
                          for (var k = 0; k < words.length; k++)
                            Builder(builder: (context) {
                              final q = Motion.easeOut(Motion.seg(p, .05 + i * .16 + k * .03, .28 + i * .16 + k * .03));
                              Widget word = Text(k < words.length - 1 ? '${words[k]} ' : words[k], style: style);
                              if (q < .99) word = ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: (1 - q) * 8, sigmaY: (1 - q) * 8), child: word);
                              return Opacity(opacity: .06 + .94 * q, child: Transform.translate(offset: Offset(0, (1 - q) * fs * .4), child: word));
                            }),
                        ]);
                        if (i == 1) {
                          w = ShaderMask(blendMode: BlendMode.srcIn, shaderCallback: (r) => AppColors.opportunity.createShader(r), child: w);
                        }
                        return w;
                      }

                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        Semantics(
                          header: true,
                          headingLevel: 2,
                          label: '${l.stmtFinal1} ${l.stmtFinal2}',
                          child: ExcludeSemantics(child: Column(children: [line(l.stmtFinal1, 0), line(l.stmtFinal2, 1)])),
                        ),
                        SizedBox(height: m.compact ? 20 : 30),
                        reveal(
                          .42,
                          .6,
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Text(l.ctaBody, textAlign: TextAlign.center, style: t.lead.copyWith(color: AppColors.grey300)),
                          ),
                        ),
                        SizedBox(height: m.compact ? 22 : 34),
                        reveal(
                          .48,
                          .66,
                          Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 10, children: [
                            Magnetic(child: AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true)),
                            Magnetic(child: AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, variant: ButtonVariant.secondary)),
                          ]),
                        ),
                        const SizedBox(height: 22),
                        reveal(.54, .72, Text(l.footerDisclaimer, textAlign: TextAlign.center, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 12))),
                      ]);
                    },
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({required this.clock, required this.motion}) : super(repaint: clock) {
    final r = SeededRandom(31);
    final n = motion.compact ? 40 : 78;
    for (var i = 0; i < n; i++) {
      _nodes.add((r.next(), r.next(), r.next(), r.next() * 6.28));
    }
    _nodes[0] = (.04, .55, _nodes[0].$3, _nodes[0].$4);
    for (var i = 0; i < n; i++) {
      final d = <(int, double)>[];
      for (var j = 0; j < n; j++) {
        if (j == i) continue;
        final dx = _nodes[j].$1 - _nodes[i].$1, dy = _nodes[j].$2 - _nodes[i].$2;
        d.add((j, dx * dx + dy * dy));
      }
      d.sort((a, b) => a.$2.compareTo(b.$2));
      for (final (j, _) in d.take(2)) {
        if (i < j) _edges.add((i, j));
      }
    }
    // A left-to-right route for the gold opportunity signal.
    var cur = 0;
    _route.add(0);
    for (var k = 0; k < 7; k++) {
      var best = -1;
      var score = 1e9;
      for (final (a, b) in _edges) {
        final o = a == cur ? b : (b == cur ? a : -1);
        if (o < 0 || _route.contains(o)) continue;
        final sc = -(_nodes[o].$1 - _nodes[cur].$1) + (_nodes[o].$2 - .5).abs() * .3;
        if (sc < score) {
          score = sc;
          best = o;
        }
      }
      if (best < 0) break;
      _route.add(best);
      cur = best;
    }
  }

  final ValueListenable<double> clock;
  final ResponsiveMotionController motion;
  final List<(double, double, double, double)> _nodes = [];
  final List<(int, int)> _edges = [];
  final List<int> _route = [];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tt = motion.reduced ? 0.0 : clock.value;
    final pts = [for (final (x, y, _, ph) in _nodes) Offset(x * w + math.sin(tt * .2 + ph) * 6, y * h + math.cos(tt * .17 + ph) * 6)];
    final line = Paint()
      ..strokeWidth = 1
      ..blendMode = BlendMode.plus
      ..color = Sem.data.withValues(alpha: .07);
    for (final (a, b) in _edges) {
      canvas.drawLine(pts[a], pts[b], line);
    }
    for (var i = 0; i < pts.length; i++) {
      Glow.draw(canvas, Sem.dataSoft, pts[i], 5 + _nodes[i].$3 * 6, .18 + .25 * _nodes[i].$3);
    }
    // One restrained gold opportunity signal.
    final cyc = (tt * .12) % 1.25;
    if (cyc < 1 && _route.length > 1) {
      final segs = _route.length - 1;
      final f = cyc * segs;
      final k = math.min(segs - 1, f.floor());
      final u = f - k;
      final trail = Paint()
        ..strokeWidth = 1.4
        ..blendMode = BlendMode.plus
        ..color = Sem.gold.withValues(alpha: .35 * (1 - cyc));
      for (var j = 0; j <= k; j++) {
        final a = pts[_route[j]], b = pts[_route[j + 1]];
        canvas.drawLine(a, Offset.lerp(a, b, j < k ? 1 : u)!, trail);
      }
      final at = Offset.lerp(pts[_route[k]], pts[_route[k + 1]], u)!;
      Glow.draw(canvas, Sem.gold, at, 22, .9);
      dotAt(canvas, at, 2.4, const Color(0xFFFFF4DC), 1);
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.motion != motion;
}
