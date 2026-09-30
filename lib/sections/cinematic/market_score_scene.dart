import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/text_blocks.dart';
import 'scene_parts.dart';

/// Explainable Market Score: six GCC markets × six documented factor
/// families. Scrolling brings in the countries, the market signals, the
/// factor analysis, the scores, the re-ordering and finally the reasons the
/// leader ranks first. Six luminous score beams stand on a perspective data
/// floor: cyan signals rise, violet processing flows in, beams grow, reorder,
/// and the leader turns gold. All values are illustrative and labelled.
class MarketScoreVisualization extends StatelessWidget {
  const MarketScoreVisualization({super.key});

  /// Illustrative factor effects (+1 raises, −1 lowers, 0 neutral) in plan
  /// market order: Bahrain, Kuwait, Oman, Qatar, KSA, UAE.
  static const List<List<int>> effects = [
    [-1, 0, 0, 1, -1, -1],
    [0, 0, 0, 0, -1, 0],
    [-1, 1, 0, 0, 0, -1],
    [0, 0, 1, 0, 0, -1],
    [1, 0, 0, -1, 1, 0],
    [1, 0, 1, -1, 1, 1],
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PinnedStorySection(
      heightFactor: 7,
      compactHeightFactor: 5.6,
      semanticLabel: '${l.scoreEyebrow}. ${l.scoreTitle} ${l.scoreBody} ${l.scoreIllustrativeNote}',
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.deepSpace,
            gradient: RadialGradient(center: Alignment(.4, 1.1), radius: .9, colors: [Color(0x262563EB), Color(0x002563EB)]),
          ),
          child: Padding(
            padding: stagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: ExcludeSemantics(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) {
                      final p = progress.value;
                      final caption = _Caption(p: p, compact: m.compact);
                      final matrix = _Matrix(p: p, compact: m.compact);
                      if (m.compact) {
                        return FitStage(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [caption, const SizedBox(height: 16), matrix],
                          ),
                        );
                      }
                      return FitStage(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 4, child: caption),
                            const SizedBox(width: 48),
                            Expanded(flex: 8, child: matrix),
                          ],
                        ),
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

class _Caption extends StatelessWidget {
  const _Caption({required this.p, required this.compact});
  final double p;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final stages = [l.scoreStage1, l.scoreStage2, l.scoreStage3, l.scoreStage4, l.scoreStage5, l.scoreStage6];
    final si = math.min(5, (p * 6).floor());
    final s6 = Motion.easeInOut(Motion.seg(p, 5 / 6, 5.5 / 6));
    final factors = [
      (Icons.north, l.var1Title),
      (Icons.north, l.var5Title),
      (Icons.north, l.var6Title),
      (Icons.north, l.var3Title),
      (Icons.south, l.var4Title),
      (Icons.east, l.var2Title),
    ];
    return Tone(
      palette: TonePalette.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(l.scoreEyebrow),
          SizedBox(height: compact ? 8 : 18),
          Text(l.scoreTitle, style: t.h2.copyWith(color: AppColors.white, fontSize: compact ? 24 : null)),
          if (!compact && s6 <= 0) ...[
            const SizedBox(height: 12),
            Text(l.scoreBody, style: t.bodySmall.copyWith(color: AppColors.grey400)),
            const SizedBox(height: 20),
            for (var i = 0; i < 6; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  SizedBox(
                    width: 26,
                    child: Text('${i + 1}'.padLeft(2, '0'),
                        style: t.caption.copyWith(color: i == si ? AppColors.electric : AppColors.grey500, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(stages[i],
                        style: t.bodySmall.copyWith(color: i == si ? AppColors.white : (i < si ? AppColors.grey400 : AppColors.grey500))),
                  ),
                ]),
              ),
          ] else if (compact) ...[
            const SizedBox(height: 6),
            Text(stages[si], style: t.bodySmall.copyWith(color: AppColors.white)),
          ],
          if (s6 > 0) ...[
            SizedBox(height: compact ? 10 : 18),
            Opacity(
              opacity: s6,
              child: Transform.translate(
                offset: Offset(0, (1 - s6) * 20),
                child: Container(
                  padding: EdgeInsets.all(compact ? 12 : 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xEB181234), Color(0xEB0A0E20)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x598B5CF6)),
                    boxShadow: const [BoxShadow(color: Color(0x808B5CF6), blurRadius: 50, spreadRadius: -20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WhyTitle(text: l.scoreWhyTitle(l.countryUae), market: l.countryUae, style: t.h4.copyWith(color: AppColors.white, fontSize: compact ? 14 : 16)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: [
                          for (final f in factors)
                            SizedBox(
                              width: compact ? 130 : 150,
                              child: Row(children: [
                                Icon(f.$1, size: 14, color: f.$1 == Icons.north ? AppColors.cyan : (f.$1 == Icons.south ? AppColors.violetSoft : AppColors.grey500)),
                                const SizedBox(width: 6),
                                Expanded(child: Text(f.$2, style: t.caption.copyWith(color: AppColors.grey300, fontSize: 12.5))),
                              ]),
                            ),
                        ],
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 10),
                        Text(l.scoreWhyBody, style: t.caption.copyWith(color: AppColors.grey400)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Matrix extends StatelessWidget {
  const _Matrix({required this.p, required this.compact});
  final double p;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final markets = DemoData.markets(l);
    final ranked = List.generate(6, (i) => i)..sort((a, b) => markets[b].$2.compareTo(markets[a].$2));
    final factors = [l.var1Title, l.var2Title, l.var3Title, l.var4Title, l.var5Title, l.var6Title];
    final shortScreen = MediaQuery.sizeOf(context).height < 820;
    final rh = compact ? 46.0 : (shortScreen ? 46.0 : 56.0);
    final beamsH = compact ? (MediaQuery.sizeOf(context).height < 800 ? 0.0 : 96.0) : (shortScreen ? 112.0 : 180.0);
    final nameW = compact ? 82.0 : 140.0;
    final scoreW = compact ? 34.0 : 120.0;
    final s5 = Motion.easeInOut(Motion.seg(p, 4 / 6, 4.7 / 6));
    final s6 = Motion.easeInOut(Motion.seg(p, 5 / 6, 5.5 / 6));

    Widget header() => Padding(
          padding: EdgeInsets.fromLTRB(compact ? 6 : 12, 0, compact ? 6 : 12, 10),
          child: Row(children: [
            SizedBox(width: nameW),
            for (var j = 0; j < 6; j++)
              Expanded(
                child: Text(compact ? '${j + 1}' : factors[j],
                    textAlign: TextAlign.center,
                    style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11.5, height: 1.2)),
              ),
            SizedBox(width: scoreW),
          ]),
        );

    Widget row(int i) {
      final rank = ranked.indexOf(i);
      final app = Motion.easeOut(Motion.seg(p, i * .018, .06 + i * .018));
      final y = Motion.lerp(i.toDouble(), rank.toDouble(), s5) * rh;
      final lead = rank == 0;
      final fx = MarketScoreVisualization.effects[i];
      final sc = Motion.easeOut(Motion.seg(p, 3 / 6 + i * .01, 3.6 / 6));
      return Positioned(
        left: 0,
        right: 0,
        top: y + (1 - app) * 16,
        height: rh - 6,
        child: Opacity(
          opacity: app * (lead ? 1 : Motion.lerp(1, .32, s6)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
            decoration: BoxDecoration(
              color: lead ? AppColors.gold.withValues(alpha: .05 * s6) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lead ? AppColors.gold.withValues(alpha: .45 * s6) : Colors.transparent),
            ),
            child: Row(children: [
              SizedBox(
                width: nameW,
                child: Text(markets[i].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.label.copyWith(color: AppColors.white, fontSize: compact ? 12.5 : 14.5)),
              ),
              for (var j = 0; j < 6; j++) Expanded(child: _Cell(p: p, i: i, j: j, effect: fx[j], compact: compact)),
              SizedBox(
                width: scoreW,
                child: Row(children: [
                  if (!compact) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.lineDarkStrong, borderRadius: BorderRadius.circular(4)),
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: sc * markets[i].$2 / 100,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: lead && s6 > .05 ? AppColors.opportunity : const LinearGradient(colors: [AppColors.blue, AppColors.cyan]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ] else
                    const Spacer(),
                  Text('${(sc * markets[i].$2).round()}',
                      style: t.label.copyWith(
                          color: lead && s6 > .05 ? AppColors.gold : AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ]),
              ),
            ]),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(compact ? 8 : 18, 18, compact ? 8 : 18, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xD90B1528), Color(0xD9050A16)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lineDark),
            boxShadow: const [BoxShadow(color: Color(0x592563EB), blurRadius: 100, spreadRadius: -40, offset: Offset(0, 40))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (beamsH > 0) ...[
                SizedBox(
                  height: beamsH,
                  child: CustomPaint(
                    painter: _BeamsPainter(
                      p: p,
                      scores: [for (final m in markets) m.$2],
                      names: [for (final m in markets) m.$1],
                      ranked: ranked,
                      rtl: Directionality.of(context) == TextDirection.rtl,
                      compact: compact,
                      labels: LabelCache(t.caption, Directionality.of(context)),
                    ),
                  ),
                ),
                Container(height: 1, color: AppColors.lineDark),
                const SizedBox(height: 12),
              ],
              header(),
              Container(height: 1, color: AppColors.lineDark),
              const SizedBox(height: 10),
              SizedBox(height: rh * 6, child: Stack(children: [for (var i = 0; i < 6; i++) row(i)])),
              if (compact)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(spacing: 12, runSpacing: 2, children: [
                    for (var j = 0; j < 6; j++) Text('${j + 1} · ${factors[j]}', style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11)),
                  ]),
                ),
              const SizedBox(height: 10),
              Text(l.scoreIllustrativeNote, style: t.caption.copyWith(color: AppColors.grey500)),
            ],
          ),
        ),
        PositionedDirectional(top: -12, end: 18, child: SceneTag(l.labelIllustrative)),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.p, required this.i, required this.j, required this.effect, required this.compact});
  final double p;
  final int i, j, effect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sig = Motion.seg(p, 1 / 6 + j * .012 + i * .006, 1.4 / 6 + j * .012 + i * .006);
    final an = Motion.easeOut(Motion.seg(p, 2 / 6 + j * .018, 2.35 / 6 + j * .018));
    final icon = effect > 0 ? Icons.north : (effect < 0 ? Icons.south : Icons.east);
    // Cyan raises, violet lowers, neutral stays blue-grey.
    final tint = effect > 0 ? AppColors.cyan : (effect < 0 ? AppColors.violet : AppColors.electric);
    final bg = .04 + an * (effect > 0 ? .09 : (effect < 0 ? .1 : .03));
    final iconColor = effect > 0 ? AppColors.cyan : (effect < 0 ? AppColors.violetSoft : AppColors.grey500);
    return Container(
      height: compact ? 26 : 32,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: (an > 0 ? tint : AppColors.electric).withValues(alpha: bg), borderRadius: BorderRadius.circular(8)),
      child: Stack(alignment: Alignment.center, children: [
        Transform.translate(
          offset: Offset(math.sin(j * 3.0 + i) * 8, math.cos(j * 2.0 + i) * 6),
          child: Opacity(
            opacity: Motion.clamp01(sig * (1 - an)),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.cyan, blurRadius: 8)]),
            ),
          ),
        ),
        Opacity(
          opacity: an * (effect == 0 ? .6 : 1),
          child: Transform.scale(scale: .6 + .4 * an, child: Icon(icon, size: compact ? 14 : 17, color: iconColor)),
        ),
      ]),
    );
  }
}

/// "Why {market} leads…" with the market name picked out in gold.
class _WhyTitle extends StatelessWidget {
  const _WhyTitle({required this.text, required this.market, required this.style});
  final String text, market;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final i = text.indexOf(market);
    if (i < 0) return Text(text, style: style);
    return Text.rich(TextSpan(style: style, children: [
      TextSpan(text: text.substring(0, i)),
      TextSpan(text: market, style: const TextStyle(color: AppColors.gold)),
      TextSpan(text: text.substring(i + market.length)),
    ]));
  }
}

/// Six luminous score beams on a perspective data floor. Scroll drives
/// everything (no ambient clock): signals rise, processing flows in, beams
/// grow, reorder by score and the leader turns gold.
class _BeamsPainter extends CustomPainter {
  _BeamsPainter({required this.p, required this.scores, required this.names, required this.ranked, required this.rtl, required this.compact, required this.labels});

  final double p;
  final List<int> scores;
  final List<String> names;
  final List<int> ranked;
  final bool rtl, compact;
  final LabelCache labels;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fy = h * .84, top = h * .12;
    final grid = Paint()..strokeWidth = 1;
    for (var k = 0; k <= 6; k++) {
      final y = Motion.lerp(fy, h, math.pow(k / 6, 1.4).toDouble());
      grid.color = Sem.data.withValues(alpha: .12 * (1 - k / 7));
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
    grid.color = Sem.data.withValues(alpha: .07);
    for (var k = -8; k <= 8; k++) {
      canvas.drawLine(Offset(w / 2 + k * w * .02, fy), Offset(w / 2 + k * w * .16, h), grid);
    }
    final s5 = Motion.easeInOut(Motion.seg(p, 4 / 6, 4.7 / 6)), s6 = Motion.easeInOut(Motion.seg(p, 5 / 6, 5.5 / 6));
    final slot = w / 6, bw = compact ? 10.0 : 18.0, maxH = fy - top - 14;
    final sigA = Motion.seg(p, 1 / 6, 1.3 / 6) * (1 - Motion.seg(p, 3 / 6, 3.4 / 6));
    final facA = Motion.seg(p, 2 / 6, 2.3 / 6) * (1 - Motion.seg(p, 3.7 / 6, 4 / 6));
    for (var i = 0; i < 6; i++) {
      final rank = ranked.indexOf(i);
      var slotI = Motion.lerp(i.toDouble(), rank.toDouble(), s5);
      if (rtl) slotI = 5 - slotI;
      final x = (slotI + .5) * slot;
      final grow = Motion.easeOut(Motion.seg(p, 3 / 6 + i * .012, 3.7 / 6));
      final app = Motion.easeOut(Motion.seg(p, i * .02, .08 + i * .02));
      final lead = rank == 0;
      final dim = lead ? 1.0 : Motion.lerp(1, .35, s6);
      final c = lead ? Sem.mix(Sem.link, Sem.gold, s6) : Sem.link;
      final c2 = lead ? Sem.mix(AppColors.blue, const Color(0xFFE0A84A), s6) : AppColors.blue;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, fy), width: bw * 2.8, height: bw * .7), Paint()..color = c.withValues(alpha: .18 * app * dim));
      Glow.draw(canvas, c, Offset(x, fy), bw * 2.2, .35 * app * dim);
      // Market signals rise (stage 2) — driven by scroll, not a clock.
      if (sigA > 0) {
        for (var k = 0; k < 5; k++) {
          final u = (p * 9 + k / 5 + i * .13) % 1;
          Glow.draw(canvas, Sem.link, Offset(x + math.sin(k * 2.1 + i) * bw * 1.2, fy - u * maxH * .7), 5, sigA * (1 - u) * .9);
        }
      }
      // Factor inputs flow in (stage 3, violet processing).
      if (facA > 0) {
        for (var k = 0; k < 3; k++) {
          final u = (p * 7 + k / 3 + i * .13) % 1;
          final sx = rtl ? w : 0.0;
          Glow.draw(canvas, Sem.ai, Offset(Motion.lerp(sx, x, u), fy - maxH * (.35 + .2 * math.sin(k + i.toDouble())) * u), 6, facA * math.sin(math.pi * u));
        }
      }
      final bh = maxH * scores[i] / 100 * grow;
      if (bh > 1) {
        final r = Rect.fromLTWH(x - bw / 2, fy - bh, bw, bh);
        canvas.drawRect(
            r,
            Paint()
              ..blendMode = BlendMode.plus
              ..shader = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [c2.withValues(alpha: .55 * dim), c.withValues(alpha: .2 * dim)])
                  .createShader(r));
        canvas.drawRect(Rect.fromLTWH(x - bw / 2, fy - bh, bw, 2), Paint()..color = c.withValues(alpha: .9 * dim));
        Glow.draw(canvas, c, Offset(x, fy - bh), bw * 1.8, .7 * dim);
        final v = labels.get('${(scores[i] * grow).round()}', (lead && s6 > 0 ? const Color(0xFFF8E0AA) : Sem.ink).withValues(alpha: dim), compact ? 11 : 13, FontWeight.w600);
        v.paint(canvas, Offset(x - v.width / 2, fy - bh - v.height - 6));
      }
      if (!compact) {
        final nm = labels.get(names[i], AppColors.grey400.withValues(alpha: app * dim), 11);
        final tw = math.min(nm.width, slot - 8);
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(x - tw / 2, h - nm.height - 2, tw, nm.height + 2));
        nm.paint(canvas, Offset(x - tw / 2, h - nm.height - 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_BeamsPainter old) => old.p != p || old.rtl != rtl;
}
