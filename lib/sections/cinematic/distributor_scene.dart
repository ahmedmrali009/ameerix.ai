import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/text_blocks.dart';
import 'scene_parts.dart';

/// Ameerix Match as an AI filtering moment. Hundreds of candidate companies
/// float in a slowly turning 3D field (far nodes small and faint, near nodes
/// soft and out of focus). Each filter — category, geography, channel fit,
/// portfolio compatibility, competitive conflict, activity/verification —
/// sweeps the field with a violet scan; irrelevant nodes sink into darkness
/// and the survivors draw closer until three gold priority candidates remain
/// and become fictional, clearly labelled "Distributor A/B/C" dossiers.
class DistributorNetwork extends StatefulWidget {
  const DistributorNetwork({super.key});

  static const List<int> desktopCounts = [300, 240, 150, 96, 60, 34, 18, 9, 3];
  static const List<int> compactCounts = [130, 110, 74, 50, 32, 20, 11, 6, 3];

  @override
  State<DistributorNetwork> createState() => _DistributorNetworkState();
}

class _DistributorNetworkState extends State<DistributorNetwork> {
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [l.matchS0, l.matchS1, l.matchF1, l.matchF2, l.matchF3, l.matchF4, l.matchF5, l.matchF6, l.matchF7];
    return PinnedStorySection(
      heightFactor: 8.2,
      compactHeightFactor: 6.2,
      semanticLabel: '${l.matchEyebrow}. ${l.matchTitle} ${steps.join(', ')}. ${l.matchCountNote}.',
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        final counts = m.compact ? DistributorNetwork.compactCounts : DistributorNetwork.desktopCounts;
        final cardW = m.compact ? size.width - 40 : 300.0;
        final cardH = m.compact ? 118.0 : 178.0;
        return ExcludeSemantics(
          child: AmbientClock(
            visible: visible,
            builder: (context, clock) => MouseRegion(
              onHover: m.compact ? null : (e) => _pointer.value = e.localPosition,
              onExit: (_) => _pointer.value = null,
              child: LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth, h = c.maxHeight;
                final pad = stagePadding(context);
                final anchors = <Rect>[
                  for (var i = 0; i < 3; i++)
                    m.compact
                        ? Rect.fromLTWH(20, h - h * .03 - (3 - i) * (cardH + 8), cardW, cardH)
                        : Rect.fromLTWH(
                            m.rtl ? math.max(pad.left, (w - 1360) / 2 + pad.left) : w - math.max(pad.right, (w - 1360) / 2 + pad.right) - cardW,
                            h / 2 - (cardH * 3 + 28) / 2 + h * .04 + i * (cardH + 14),
                            cardW,
                            cardH),
                ];
                return Stack(children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.deepSpace,
                        gradient: RadialGradient(center: Alignment(.2, 0), radius: .9, colors: [Color(0x1A2563EB), Color(0x002563EB)]),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NetworkPainter(
                        progress: progress,
                        clock: clock,
                        pointer: _pointer,
                        motion: m,
                        counts: counts,
                        anchors: anchors,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) {
                      final f = progress.value * 9;
                      final si = math.min(8, f.floor());
                      final next = counts[math.min(8, si + 1)];
                      final shown = si == 8 ? 3 : Motion.lerp(counts[si].toDouble(), next.toDouble(), Motion.easeInOut(Motion.seg(f - si, .1, .7))).round();
                      return Stack(children: [
                        PositionedDirectional(
                          top: pad.top + h * (m.compact ? 0 : .01),
                          start: math.max(pad.left, (w - 1360) / 2 + pad.left),
                          end: m.compact ? pad.right : null,
                          width: m.compact ? null : math.min(360, w * .34),
                          child: _MatchCaption(steps: steps, current: si, remaining: shown, compact: m.compact),
                        ),
                        for (var i = 0; i < 3; i++)
                          Positioned(
                            left: anchors[i].left,
                            top: anchors[i].top,
                            width: anchors[i].width,
                            child: Builder(builder: (context) {
                              final on = Motion.easeOut(Motion.seg(f, 8.15 + i * .12, 8.6 + i * .12));
                              if (on <= 0) return const SizedBox.shrink();
                              return Opacity(
                                opacity: on,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - on) * 24),
                                  child: DemoDistributorCard(
                                    name: DemoData.distributors[i].$1,
                                    values: DemoData.distributors[i].$2,
                                    width: cardW,
                                    rows: m.compact ? 1 : 3,
                                  ),
                                ),
                              );
                            }),
                          ),
                      ]);
                    },
                  ),
                ]);
              }),
            ),
          ),
        );
      },
    );
  }
}

class _MatchCaption extends StatelessWidget {
  const _MatchCaption({required this.steps, required this.current, required this.remaining, required this.compact});
  final List<String> steps;
  final int current;
  final int remaining;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final remainingLabel = l.matchRemaining('').replaceAll(RegExp(r'[:：]\s*$'), '').trim();
    return Tone(
      palette: TonePalette.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(l.matchEyebrow),
          SizedBox(height: compact ? 8 : 18),
          Text(l.matchTitle, style: t.h2.copyWith(color: AppColors.white, fontSize: compact ? 22 : null)),
          SizedBox(height: compact ? 8 : 20),
          if (!compact)
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == current
                          ? (i == 8 ? AppColors.gold : AppColors.electric)
                          : (i < current ? AppColors.cyan.withValues(alpha: .6) : Colors.transparent),
                      border: Border.all(color: i <= current ? Colors.transparent : AppColors.grey500),
                      boxShadow: i == current ? [BoxShadow(color: i == 8 ? AppColors.gold : AppColors.electric, blurRadius: 10)] : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(steps[i],
                        style: t.bodySmall.copyWith(color: i == current ? AppColors.white : (i < current ? AppColors.grey400 : AppColors.grey500))),
                  ),
                ]),
              )
          else
            Text(steps[current], style: t.bodySmall.copyWith(color: AppColors.white)),
          SizedBox(height: compact ? 6 : 16),
          Text('$remaining',
              style: t.display.copyWith(
                color: AppColors.white,
                fontSize: compact ? 30 : 48,
                height: 1,
                letterSpacing: -1,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 6),
          Text(remainingLabel, style: t.caption.copyWith(color: AppColors.grey400)),
          Text(l.matchCountNote, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _Node {
  _Node(this.x, this.y, this.z, this.rank, this.elim, this.ph, this.sz);
  final double x, y, z, ph, sz;
  final int rank, elim;
}

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({
    required this.progress,
    required this.clock,
    required this.pointer,
    required this.motion,
    required this.counts,
    required this.anchors,
  }) : super(repaint: Listenable.merge([progress, clock, pointer])) {
    final n = counts.first;
    final r = SeededRandom(21);
    final ranks = List.generate(n, (i) => i);
    for (var i = n - 1; i > 0; i--) {
      final j = (r.next() * (i + 1)).floor();
      final tmp = ranks[i];
      ranks[i] = ranks[j];
      ranks[j] = tmp;
    }
    for (var i = 0; i < n; i++) {
      final rank = ranks[i];
      var elim = 9;
      for (var j = 1; j < 9; j++) {
        if (rank >= counts[j]) {
          elim = j;
          break;
        }
      }
      final a = r.next() * math.pi * 2, d = math.sqrt(r.next());
      _nodes.add(_Node(math.cos(a) * d, (r.next() - .5) * 1.7, math.sin(a) * d, rank, elim, r.next() * 6.28, .7 + r.next() * 1.2));
    }
    // Two nearest neighbours per node form the relationship mesh.
    for (var i = 0; i < n; i++) {
      final a = _nodes[i];
      var b1 = -1, b2 = -1;
      var d1 = 1e9, d2 = 1e9;
      for (var j = 0; j < n; j++) {
        if (j == i) continue;
        final b = _nodes[j];
        final d = (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z);
        if (d < d1) {
          d2 = d1;
          b2 = b1;
          d1 = d;
          b1 = j;
        } else if (d < d2) {
          d2 = d;
          b2 = j;
        }
      }
      for (final j in [b1, b2]) {
        if (j > i) _links.add((i, j, r.next()));
      }
    }
  }

  final ValueListenable<double> progress;
  final ValueListenable<double> clock;
  final ValueListenable<Offset?> pointer;
  final ResponsiveMotionController motion;
  final List<int> counts;
  final List<Rect> anchors;
  final List<_Node> _nodes = [];
  final List<(int, int, double)> _links = [];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final f = progress.value * 9;
    final tt = motion.reduced ? 0.0 : clock.value;
    final mob = motion.compact, rtl = motion.rtl;
    final cx = mob ? w * .5 : (rtl ? w * .42 : w * .57), cy = mob ? h * .5 : h * .52;
    final rx = mob ? w * .48 : w * .3, ry = mob ? h * .22 : h * .34;
    final gather = Motion.easeInOut(Motion.seg(f, 2, 8));
    final ptr = pointer.value;
    final th = tt * .04 + progress.value * .9;
    final ca = math.cos(th), sa = math.sin(th);

    final pos = List<Offset>.filled(_nodes.length, Offset.zero);
    final alpha = List<double>.filled(_nodes.length, 0);
    final depth = List<double>.filled(_nodes.length, 0);
    final pf = List<double>.filled(_nodes.length, 1);
    final gold = List<double>.filled(_nodes.length, 0);
    for (var i = 0; i < _nodes.length; i++) {
      final n = _nodes[i];
      var x = n.x * ca + n.z * sa, z = -n.x * sa + n.z * ca, y = n.y;
      final e = Motion.easeInOut(Motion.seg(f, n.elim.toDouble(), n.elim + .7));
      if (n.elim < 9 && e > 0) {
        z += e * 1.4;
        x *= 1 + e * .25;
        y *= 1 + e * .25;
      } else {
        final k = gather * .62;
        x *= 1 - k;
        y *= 1 - k;
        z *= 1 - k;
      }
      final pr = 1 / (1 + z * .45);
      var px = cx + x * rx * pr + math.sin(tt * .3 + n.ph) * 3;
      var py = cy + y * ry * pr + math.cos(tt * .25 + n.ph) * 3;
      var a = (n.elim < 9 && e > 0) ? Motion.lerp(.8, 0, e) : (f < 1 ? .35 + .45 * Motion.seg(f, 0, 1) : .85);
      a *= ((1 - (z + 1) / 2.4) * .65 + .35).clamp(.15, 1.0);
      if (n.elim == 9) {
        gold[i] = Motion.seg(f, 7.2, 8);
        if (n.rank < anchors.length) {
          final fin = Motion.easeInOut(Motion.seg(f, 8, 8.6));
          if (fin > 0) {
            final rc = anchors[n.rank];
            px = Motion.lerp(px, mob ? rc.center.dx : (rtl ? rc.right + 16 : rc.left - 16), fin);
            py = Motion.lerp(py, mob ? rc.top - 6 : rc.center.dy, fin);
          }
        }
      }
      if (ptr != null) {
        final d = (Offset(px, py) - ptr).distance;
        if (d < 110) a = math.min(1, a + .45 * (1 - d / 110));
      }
      pos[i] = Offset(px, py);
      alpha[i] = a;
      depth[i] = z;
      pf[i] = pr;
    }

    // Relationship mesh with occasional pulses (cyan = connections).
    final line = Paint()
      ..strokeWidth = 1
      ..blendMode = BlendMode.plus;
    for (final (i, j, k) in _links) {
      final a = math.min(alpha[i], alpha[j]) * .2;
      if (a < .02) continue;
      line.color = Sem.link.withValues(alpha: a);
      canvas.drawLine(pos[i], pos[j], line);
      final ph = (tt * .25 + k * 7) % 3;
      if (ph < 1 && a > .08) Glow.draw(canvas, Sem.link, Offset.lerp(pos[i], pos[j], ph)!, 6, a * 3);
    }

    // Each filter scans the field (violet = AI processing).
    if (f >= 2 && f < 8) {
      final sw = Motion.seg(f - f.floor(), .05, .75);
      if (sw > 0 && sw < 1) {
        final x0 = Motion.lerp(cx - rx * 1.15, cx + rx * 1.15, rtl ? 1 - sw : sw);
        final band = Rect.fromLTWH(x0 - 60, cy - ry * 1.3, 120, ry * 2.6);
        final a = math.sin(math.pi * sw);
        canvas.drawRect(
            band,
            Paint()
              ..blendMode = BlendMode.plus
              ..shader = LinearGradient(colors: [Sem.ai.withValues(alpha: 0), Sem.ai.withValues(alpha: .22 * a), Sem.ai.withValues(alpha: 0)])
                  .createShader(band));
        canvas.drawRect(Rect.fromLTWH(x0 - .5, band.top, 1, band.height), Paint()..color = Sem.aiSoft.withValues(alpha: .55 * a));
      }
    }

    // Nodes, far to near: far small and faint, near soft (depth of field).
    final order = List.generate(_nodes.length, (i) => i)..sort((a, b) => depth[b].compareTo(depth[a]));
    for (final i in order) {
      final a = alpha[i];
      if (a < .01) continue;
      final g = gold[i];
      final c = g > 0 ? Sem.mix(Sem.dataSoft, Sem.gold, g) : Sem.dataSoft;
      final sz = _nodes[i].sz * pf[i] * (g > 0 ? Motion.lerp(1, 2.2, g) : 1);
      if (depth[i] < -.55 && !mob) {
        Glow.draw(canvas, c, pos[i], sz * 7, a * .35);
        dotAt(canvas, pos[i], sz * .9, Sem.ink, a * .45);
      } else {
        Glow.draw(canvas, c, pos[i], sz * (g > 0 ? 9 : 4), a * (g > 0 ? .9 : .45));
        dotAt(canvas, pos[i], sz * .8, g > 0 ? Sem.gold : Sem.ink, a);
      }
    }

    // Priority candidates connect to their dossiers.
    final fin = Motion.seg(f, 8.1, 8.7);
    if (fin > 0) {
      final gl = Paint()
        ..strokeWidth = 1
        ..color = Sem.gold.withValues(alpha: .5 * fin);
      for (var i = 0; i < _nodes.length; i++) {
        final n = _nodes[i];
        if (n.elim != 9 || n.rank >= anchors.length) continue;
        final rc = anchors[n.rank];
        canvas.drawLine(pos[i], mob ? Offset(rc.center.dx, rc.top) : Offset(rtl ? rc.right : rc.left, rc.center.dy), gl);
      }
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.motion != motion || old.anchors != anchors;
}
