import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/visuals/intelligence_core.dart';
import 'scene_parts.dart';

/// Signature pinned sequence: Spanish company → Ameerix intelligence layer →
/// analysis → six GCC markets → ranking → priority market → partner shortlist
/// → "Market. Partner. Opportunity."
///
/// The scroll position drives eight stages. Raw business information is
/// blue; it flows into the Ameerix intelligence core where violet processing
/// energy rises; structured intelligence exits in cyan toward six GCC
/// markets; priority candidates turn gold. Process flow follows the reading
/// direction (mirrored in Arabic). All scores are illustrative and tagged.
class SpainGccStory extends StatelessWidget {
  const SpainGccStory({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stages = <(String, String?)>[
      (l.storyStage1, l.storyStage1Body),
      (l.storyStage2, l.storyStage2Body),
      (l.storyStage3, l.storyStage3Body),
      (l.storyStage4, l.storyStage4Body),
      (l.storyStage5, l.storyStage5Body),
      (l.storyStage6, l.storyStage6Body),
      (l.storyStage7, l.storyStage7Body),
      (l.storyStage8, l.storyStage8Body),
    ];
    return PinnedStorySection(
      heightFactor: 10,
      compactHeightFactor: 8,
      semanticLabel: '${l.storyEyebrow}. ${l.storyTitle} ${stages.map((s) => s.$1).join('. ')}',
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        final pad = stagePadding(context);
        final usableHeight = math.max(0.0, size.height - pad.top - pad.bottom);
        return ColoredBox(
          color: AppColors.deepSpace,
          child: Padding(
            padding: pad,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: SizedBox(
                  height: usableHeight,
                  child: AmbientClock(
                  visible: visible,
                  builder: (context, clock) {
                    final caption = AnimatedBuilder(
                      animation: progress,
                      builder: (context, _) {
                        final f = progress.value * 8;
                        final si = math.min(7, f.floor());
                        final pos = si + Motion.easeInOut(Motion.seg(f - si, .88, 1));
                        return StageCaption(eyebrow: l.storyEyebrow, stages: stages, position: pos);
                      },
                    );
                    final vis = ExcludeSemantics(child: _StoryVisual(progress: progress, clock: clock, motion: m));
                    if (m.compact) {
                      return Column(children: [Expanded(child: SizedBox.expand(child: vis)), const SizedBox(height: 12), caption]);
                    }
                    return Row(
                      children: [
                        Expanded(flex: 4, child: Align(alignment: AlignmentDirectional.centerStart, child: caption)),
                        const SizedBox(width: 40),
                        Expanded(flex: 8, child: SizedBox.expand(child: vis)),
                      ],
                    );
                  },
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoryVisual extends StatelessWidget {
  const _StoryVisual({required this.progress, required this.clock, required this.motion});

  final ValueListenable<double> progress;
  final ValueListenable<double> clock;
  final ResponsiveMotionController motion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final markets = DemoData.markets(l);
    final ranked = List.generate(6, (i) => i)..sort((a, b) => markets[b].$2.compareTo(markets[a].$2));
    final fields = [l.storyF1, l.storyF2, l.storyF3, l.storyF4, l.storyF5, l.storyF6];
    final analysis = [l.modReadinessName, l.storyA2, l.var5Title, l.var3Title, l.var4Title, l.var6Title];
    final mob = motion.compact;
    final cardW = mob ? 210.0 : 250.0, cardH = mob ? 290.0 : 318.0;
    final chipW = mob ? 180.0 : 214.0;
    final mkW = mob ? 210.0 : 280.0;
    final slW = mob ? 236.0 : 300.0;
    final slH = mob ? 112.0 : 176.0;

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = c.maxHeight;
      double X(double f) => motion.x(f) * w;
      final dir = motion.rtl ? -1.0 : 1.0;
      return AnimatedBuilder(
        animation: Listenable.merge([progress, clock]),
        builder: (context, _) {
          final p = progress.value;
          final cy = h / 2;
          final kids = <Widget>[];

          // S1 — company card and its structured data.
          final cardX = X(mob ? .5 : .22);
          final cardO = 1 - Motion.seg(p, .15, .23);
          kids.add(CenteredAt(
            x: cardX,
            y: cy,
            scale: 1 - .1 * Motion.seg(p, .15, .23),
            opacity: cardO,
            child: _Box(
              width: cardW,
              height: cardH,
              radius: 18,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.factory_outlined, size: 18, color: AppColors.electric),
                  const SizedBox(width: 8),
                  Flexible(child: Text(l.storyStage1, style: t.label.copyWith(color: AppColors.white, fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
          ));
          final coreX = X(.5);
          for (var i = 0; i < 6; i++) {
            final appear = Motion.easeOut(Motion.seg(p, .005 + i * .016, .035 + i * .016));
            final by = cy - cardH / 2 + 62 + i * 40;
            final fly = Motion.easeInOut(Motion.seg(p, .13 + i * .012, .2 + i * .012));
            final x = Motion.lerp(cardX, coreX, fly);
            final y = Motion.lerp(by, cy, fly) - math.sin(fly * math.pi) * h * .12;
            kids.add(CenteredAt(
              x: x,
              y: y,
              scale: Motion.lerp(1, .35, fly),
              opacity: appear * (1 - Motion.seg(fly, .75, 1)),
              child: _Chip(width: chipW, label: fields[i]),
            ));
          }

          // S2/S3 — intelligence layer and analysis.
          final coreIn = Motion.easeOut(Motion.seg(p, .12, .2));
          final s4 = Motion.easeInOut(Motion.seg(p, .375, .45));
          final coreGX = X(mob ? .5 : .2), coreGY = mob ? h * .1 : cy;
          final coreCX = Motion.lerp(coreX, coreGX, s4), coreCY = Motion.lerp(cy, coreGY, s4);
          final coreScale = Motion.lerp(.6, 1, coreIn) * Motion.lerp(1, mob ? .55 : .66, s4);
          final coreAlpha = coreIn * (1 - Motion.seg(p, .6, .66));
          final coreSize = (mob ? 30.0 : 44.0) * coreScale;
          // The core itself is painted (see _StoryLinesPainter); its label sits below.
          kids.add(CenteredAt(
            x: coreCX,
            y: coreCY + coreSize * 2.4 + 18,
            opacity: coreAlpha * (1 - s4 * .6),
            child: Text(l.heroLabelLayer,
                textAlign: TextAlign.center,
                style: t.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: mob ? 11 : 12.5,
                  shadows: const [Shadow(color: Color(0xCC8B5CF6), blurRadius: 18)],
                )),
          ));
          final rc = math.min(w, h) * (mob ? .36 : .33);
          for (var i = 0; i < 6; i++) {
            final ang = -math.pi / 2 + i * math.pi / 3;
            final on = Motion.easeOut(Motion.seg(p, .25 + i * .018, .29 + i * .018));
            final out = Motion.seg(p, .38, .44);
            final rr = rc * Motion.lerp(.7, 1, on);
            kids.add(CenteredAt(
              x: coreX + math.cos(ang) * rr,
              y: cy + math.sin(ang) * rr * (mob ? .9 : .85),
              opacity: on * (1 - out),
              child: _Pill(label: analysis[i], checked: Motion.seg(p, .29 + i * .018, .31 + i * .018)),
            ));
          }

          // S4/S5/S6 — markets appear, rank, the leader expands.
          final s5 = Motion.easeInOut(Motion.seg(p, .52, .6));
          final s6 = Motion.easeInOut(Motion.seg(p, .625, .7));
          final s7 = Motion.easeInOut(Motion.seg(p, .75, .82));
          final mx = X(mob ? .5 : .66);
          final gap = mob ? 46.0 : 56.0;
          final top = mob ? h * .14 : cy - 3.35 * gap;
          final endFade = 1 - Motion.seg(p, .88, .93);
          for (var i = 0; i < 6; i++) {
            final rank = ranked.indexOf(i);
            final app = Motion.easeOut(Motion.seg(p, .39 + i * .015, .43 + i * .015));
            var x = mx, y = Motion.lerp(top + i * gap, top + rank * gap, s5), sc = 1.0, o = app;
            final lead = rank == 0;
            if (lead) {
              x = Motion.lerp(mx, X(mob ? .5 : .56), s6);
              y = Motion.lerp(y, mob ? h * .14 : cy, s6);
              sc = Motion.lerp(1, mob ? 1.05 : 1.25, s6);
              x = Motion.lerp(x, X(mob ? .5 : .26), s7);
              y = Motion.lerp(y, mob ? h * .12 : cy, s7);
            } else {
              o *= 1 - s6;
              x += dir * s6 * 60;
            }
            kids.add(CenteredAt(
              x: x,
              y: y,
              scale: sc,
              opacity: o * endFade,
              child: _MarketPill(
                width: mkW,
                name: markets[i].$1,
                score: markets[i].$2,
                bar: Motion.easeOut(Motion.seg(p, .5 + rank * .01, .58)),
                highlight: lead ? s6 : 0,
              ),
            ));
          }

          // S7 — shortlist.
          for (var i = 0; i < 3; i++) {
            final on = Motion.easeOut(Motion.seg(p, .79 + i * .02, .83 + i * .02));
            final y = mob ? h * .3 + i * (slH + 8) + slH / 2 - 10 : cy + (i - 1) * (slH + 12);
            kids.add(CenteredAt(
              x: X(mob ? .5 : .7) + dir * (1 - on) * 30,
              y: y,
              opacity: on * endFade,
              child: DemoDistributorCard(
                name: DemoData.distributors[i].$1,
                values: DemoData.distributors[i].$2,
                width: slW,
                rows: mob ? 1 : 3,
              ),
            ));
          }

          // S8 — Market → Partner → Opportunity.
          final fo = Motion.easeOut(Motion.seg(p, .9, .97));
          if (fo > 0) {
            final fs = (w * (mob ? .09 : .062)).clamp(28.0, 64.0);
            final ws = t.display.copyWith(fontSize: fs, color: AppColors.white, letterSpacing: t.usesUppercase ? -fs * .04 : 0, height: 1.1);
            Widget word(String s, int k) => Opacity(
                  opacity: Motion.seg(p, .9 + k * .012, .94 + k * .012),
                  child: k == 2
                      ? ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (r) => AppColors.opportunity.createShader(r),
                          child: Text(s, style: ws),
                        )
                      : Text(s, style: ws),
                );
            final arrow = Icon(Icons.arrow_forward, color: AppColors.violetSoft, size: fs * .7);
            kids.add(Positioned.fill(
              child: Opacity(
                opacity: fo,
                child: Transform.scale(
                  scale: Motion.lerp(.94, 1, fo),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 18,
                      runSpacing: 8,
                      children: [word(l.wordMarket, 0), arrow, word(l.wordPartner, 1), arrow, word(l.wordOpportunity, 2)],
                    ),
                  ),
                ),
              ),
            ));
          }

          final illus = Motion.seg(p, .49, .52) * (1 - Motion.seg(p, .86, .9));
          // Stages 02–04 need to sit higher on laptop-height viewports.
          // Lift the complete visual composition (core, factor pills, market
          // links and painter) as one unit, then smoothly return to the normal
          // centre before the later stages.
          final earlyLift = mob
              ? 0.0
              : Motion.easeInOut(Motion.seg(p, .10, .16)) *
                  (1 - Motion.easeInOut(Motion.seg(p, .86, .90)));
          final liftY = h * .18 * earlyLift;
          return Transform.translate(
            offset: Offset(0, -liftY),
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StoryLinesPainter(
                    p: p,
                    time: motion.reduced ? 0 : clock.value,
                    motion: motion,
                    core: Offset(coreCX, coreCY),
                    coreStart: Offset(coreX, cy),
                    cardAt: Offset(cardX, cy),
                    coreSize: coreSize,
                    coreAlpha: coreAlpha * (1 - s4 * .35),
                    analysisRadius: rc,
                    marketX: mx,
                    top: top,
                    gap: gap,
                    ranked: ranked,
                    s5: s5,
                    s7: s7,
                    marketHalfWidth: mkW / 2,
                    shortlistWidth: slW,
                    shortlistHeight: slH,
                  ),
                ),
              ),
              ...kids,
              if (illus > 0)
                PositionedDirectional(top: 0, end: 0, child: Opacity(opacity: illus, child: SceneTag(l.labelIllustrative))),
            ],
            ),
          );
        },
      );
    });
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.child, this.radius = 12});
  final double width, height, radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCC111D35), Color(0xCC081020)],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x474F8CFF)),
          boxShadow: const [BoxShadow(color: Color(0x592563EB), blurRadius: 80, spreadRadius: -30, offset: Offset(0, 30))],
        ),
        child: child,
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.width, required this.label});
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Container(
      width: width,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xEB0B1528),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0x594F8CFF)),
        boxShadow: const [BoxShadow(color: Color(0x734F8CFF), blurRadius: 18, spreadRadius: -6)],
      ),
      child: Row(children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.electric,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.electric, blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey300))),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.checked});
  final String label;
  final double checked;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xE0160E30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x738B5CF6)),
        boxShadow: const [BoxShadow(color: Color(0xB38B5CF6), blurRadius: 20, spreadRadius: -8)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Opacity(opacity: checked, child: const Icon(Icons.check, size: 14, color: AppColors.violetSoft)),
        const SizedBox(width: 6),
        Text(label, style: t.caption.copyWith(color: const Color(0xFFE4DCFF), fontSize: 12.5)),
      ]),
    );
  }
}

class _MarketPill extends StatelessWidget {
  const _MarketPill({required this.width, required this.name, required this.score, required this.bar, required this.highlight});
  final double width;
  final String name;
  final int score;
  final double bar;
  final double highlight;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Container(
      width: width,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xE6091428),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.lerp(const Color(0x3822D3EE), AppColors.gold.withValues(alpha: .8), highlight)!),
        boxShadow: highlight > 0 ? [BoxShadow(color: AppColors.gold.withValues(alpha: .45 * highlight), blurRadius: 36, spreadRadius: -8)] : null,
      ),
      child: Row(children: [
        Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.label.copyWith(color: AppColors.white, fontSize: 14))),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          height: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.lineDarkStrong, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: Motion.clamp01(bar * score / 100),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: highlight > .05 ? AppColors.opportunity : const LinearGradient(colors: [AppColors.blue, AppColors.cyan]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 26,
          child: Text('$score',
              textAlign: TextAlign.end,
              style: t.label.copyWith(
                  color: Color.lerp(AppColors.white, AppColors.gold, highlight),
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ]),
    );
  }
}

class _StoryLinesPainter extends CustomPainter {
  _StoryLinesPainter({
    required this.p,
    required this.time,
    required this.motion,
    required this.core,
    required this.coreStart,
    required this.cardAt,
    required this.coreSize,
    required this.coreAlpha,
    required this.analysisRadius,
    required this.marketX,
    required this.top,
    required this.gap,
    required this.ranked,
    required this.s5,
    required this.s7,
    required this.marketHalfWidth,
    required this.shortlistWidth,
    required this.shortlistHeight,
  });

  final double p, time, marketX, top, gap, s5, s7, marketHalfWidth, shortlistWidth, shortlistHeight;
  final double coreSize, coreAlpha, analysisRadius;
  final ResponsiveMotionController motion;
  final Offset core, coreStart, cardAt;
  final List<int> ranked;

  static final List<List<double>> _dots = () {
    final r = SeededRandom(11);
    return List.generate(64, (_) => [r.next() * math.pi * 2, .45 + r.next() * .55, r.next()]);
  }();
  static final List<List<double>> _flow = () {
    final r = SeededRandom(12);
    return List.generate(36, (_) => [r.next(), r.next() - .5, .6 + r.next() * .8]);
  }();

  static double _bz(double a, double b, double c, double d, double u) =>
      (1 - u) * (1 - u) * (1 - u) * a + 3 * (1 - u) * (1 - u) * u * b + 3 * (1 - u) * u * u * c + u * u * u * d;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final mob = motion.compact;
    final dir = motion.rtl ? -1.0 : 1.0;
    double X(double f) => motion.x(f) * w;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..blendMode = BlendMode.plus;

    // Raw business information streams into the engine (blue).
    final inA = Motion.seg(p, .1, .16) * (1 - Motion.seg(p, .26, .3));
    if (inA > 0) {
      for (final q in _flow) {
        final u = (time * .25 * q[2] + q[0]) % 1;
        final pt = Offset(
          Motion.lerp(cardAt.dx, coreStart.dx, u),
          Motion.lerp(cardAt.dy + q[1] * 140, coreStart.dy, Motion.easeInOut(u)) - math.sin(u * math.pi) * h * .06,
        );
        final a = inA * math.sin(math.pi * u);
        Glow.draw(canvas, Sem.data, pt, 9, a * .8);
        dotAt(canvas, pt, 1.2, Sem.ink, a);
      }
    }

    // Analysis: violet links to the six evaluated factors.
    final an = Motion.seg(p, .25, .3) * (1 - Motion.seg(p, .38, .44));
    if (an > 0) {
      for (var i = 0; i < 6; i++) {
        final ang = -math.pi / 2 + i * math.pi / 3;
        final end = coreStart + Offset(math.cos(ang) * analysisRadius, math.sin(ang) * analysisRadius * (mob ? .9 : .85));
        line.shader = LinearGradient(colors: [Sem.ai.withValues(alpha: .7 * an), Sem.aiSoft.withValues(alpha: .08 * an)])
            .createShader(Rect.fromPoints(coreStart, end));
        canvas.drawLine(coreStart, end, line);
        final u = (time * .6 + i / 6) % 1;
        Glow.draw(canvas, Sem.aiSoft, Offset.lerp(coreStart, end, u)!, 8, an * .9);
      }
      line.shader = null;
    }

    // Structured intelligence exits toward the six markets (violet → cyan).
    final la = Motion.seg(p, .4, .46) * (1 - Motion.seg(p, .6, .66));
    if (la > 0) {
      for (var i = 0; i < 6; i++) {
        final y = Motion.lerp(top + i * gap, top + ranked.indexOf(i) * gap, s5);
        final end = Offset(marketX - dir * marketHalfWidth, y);
        final mid = (core.dx + end.dx) / 2;
        line.shader = LinearGradient(colors: [Sem.ai.withValues(alpha: .55 * la), Sem.link.withValues(alpha: .35 * la)])
            .createShader(Rect.fromPoints(core, end).inflate(1));
        canvas.drawPath(Path()
          ..moveTo(core.dx, core.dy)
          ..cubicTo(mid, core.dy, mid, y, end.dx, end.dy), line);
        final u = (time * .35 + i * .17) % 1;
        Glow.draw(canvas, Sem.link, Offset(_bz(core.dx, mid, mid, end.dx, u), _bz(core.dy, core.dy, y, y, u)), 8, la * .9);
      }
      line.shader = null;
    }

    // Distributor field around the priority market (cyan); the three priority
    // candidates turn gold and travel to the shortlist.
    final dA = Motion.seg(p, .64, .7) * (1 - Motion.seg(p, .86, .9));
    if (dA > 0) {
      final cx = X(mob ? .5 : .56), cy = mob ? h * .14 : h / 2;
      final ux = Motion.lerp(cx, X(mob ? .5 : .26), s7), uy = Motion.lerp(cy, mob ? h * .12 : h / 2, s7);
      final rd = math.min(w, h) * (mob ? .34 : .36);
      final col = Motion.seg(p, .74, .8);
      for (var i = 0; i < _dots.length; i++) {
        final d = _dots[i];
        final keep = i < 3;
        final ang = d[0] + time * .03;
        var x = ux + math.cos(ang) * rd * d[1];
        var y = uy + math.sin(ang) * rd * d[1] * (mob ? .6 : .8);
        var a = dA * (.3 + .45 * d[2]);
        if (!keep) {
          a *= 1 - col * .9;
        } else {
          a = dA;
          final on = Motion.seg(p, .79 + i * .02, .83 + i * .02);
          final tx = X(mob ? .5 : .72) - dir * shortlistWidth / 2;
          final ty = mob ? h * .3 + i * (shortlistHeight + 8) + shortlistHeight / 2 - 10 : h / 2 + (i - 1) * (shortlistHeight + 12);
          x = Motion.lerp(x, tx, Motion.easeInOut(col));
          y = Motion.lerp(y, ty, Motion.easeInOut(col));
          a *= 1 - on * .5;
        }
        final c = keep && col > 0 ? Sem.mix(Sem.link, Sem.gold, col) : Sem.link;
        line.color = c.withValues(alpha: Motion.clamp01(a * .22));
        canvas.drawLine(Offset(ux, uy), Offset(x, y), line);
        Glow.draw(canvas, c, Offset(x, y), keep ? 14 : 7, a * .7);
        dotAt(canvas, Offset(x, y), keep ? 2.4 : 1.3, Sem.ink, a);
      }
    }

    // The Ameerix intelligence core — violet energy peaks during analysis.
    if (coreAlpha > .01) {
      final e = .25 + .75 * Motion.seg(p, .2, .3) * (1 - Motion.seg(p, .44, .5));
      paintIntelligenceCore(canvas, core, coreSize, time, energy: e, alpha: coreAlpha);
    }
  }

  @override
  bool shouldRepaint(_StoryLinesPainter old) => true;
}
