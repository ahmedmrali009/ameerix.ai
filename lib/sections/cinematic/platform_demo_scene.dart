import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/text_blocks.dart';
import '../../widgets/visuals/intelligence_core.dart';
import 'scene_parts.dart';

/// Pinned product-concept demo: one dark-navy application window that
/// transforms as the visitor scrolls — Overview → Export Readiness → Market
/// Score → Match → Trade Graph → Localise → Market CRM → Intelligence.
///
/// A single morph layer carries one visual idea into the next: the score
/// columns collapse onto a GCC map, partner nodes emerge around the priority
/// market, spread into a Trade Graph, and later fly into the CRM pipeline as
/// gold opportunities; finally the intelligence core produces next actions.
/// Every value is illustrative and labelled as such.
class PlatformDemo extends StatelessWidget {
  const PlatformDemo({super.key});

  static const icons = [
    Icons.space_dashboard_outlined,
    Icons.fact_check_outlined,
    Icons.leaderboard_outlined,
    Icons.join_inner,
    Icons.hub_outlined,
    Icons.translate,
    Icons.view_kanban_outlined,
    Icons.insights,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mods = [
      (l.demoOverview, l.demoWorkspace),
      (l.modReadinessName, l.modReadinessDesc),
      (l.modScoreName, l.modScoreDesc),
      (l.modMatchName, l.modMatchDesc),
      (l.modGraphName, l.modGraphDesc),
      (l.modLocaliseName, l.modLocaliseDesc),
      (l.modCrmName, l.modCrmDesc),
      (l.modIntelName, l.modIntelDesc),
    ];
    return PinnedStorySection(
      heightFactor: 9.6,
      compactHeightFactor: 7.6,
      semanticLabel: '${l.demoEyebrow}. ${l.demoTitle} ${mods.skip(1).map((m) => '${m.$1}: ${m.$2}').join('. ')}. ${l.demoNote}',
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        final t = AppTypography.of(context);
        final pad = stagePadding(context);
        return ExcludeSemantics(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.midnight,
              gradient: RadialGradient(center: Alignment(0, -1.1), radius: 1.1, colors: [Color(0x2E3B82F6), Color(0x003B82F6)]),
            ),
            child: Padding(
              padding: pad,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Tone(
                    palette: TonePalette.midnight,
                    child: AmbientClock(
                      visible: visible,
                      builder: (context, clock) => AnimatedBuilder(
                        animation: progress,
                        builder: (context, _) {
                          final p = progress.value;
                          final f = (p * mods.length).clamp(0.0, mods.length - .001);
                          final si = f.floor();
                          final intro = Motion.easeOut(Motion.seg(p, 0, .04));
                          final sc = Motion.lerp(.94, 1, intro);
                          return Column(
                            children: [
                              Eyebrow(l.demoEyebrow, center: true),
                              SizedBox(height: m.compact ? 6 : 10),
                              Text(l.demoTitle, textAlign: TextAlign.center, style: t.h2.copyWith(color: AppColors.white, fontSize: m.compact ? 22 : null)),
                              SizedBox(height: m.compact ? 12 : 20),
                              Expanded(
                                child: Transform(
                                  alignment: Alignment.topCenter,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, .0006)
                                    ..rotateX((1 - intro) * .17)
                                    ..multiply(Matrix4.diagonal3Values(sc, sc, 1)),
                                  child: _AppWindow(mods: mods, f: f, si: si, clock: clock, motion: m),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                for (var i = 0; i < mods.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 6),
                                  Container(
                                    width: 24,
                                    height: 3,
                                    decoration: BoxDecoration(color: AppColors.lineDarkStrong, borderRadius: BorderRadius.circular(3)),
                                    child: FractionallySizedBox(
                                      alignment: AlignmentDirectional.centerStart,
                                      widthFactor: Motion.clamp01(f - i),
                                      child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.electric, AppColors.violet]))),
                                    ),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: 8),
                              Text(l.demoNote, textAlign: TextAlign.center, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11.5)),
                            ],
                          );
                        },
                      ),
                    ),
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

class _AppWindow extends StatelessWidget {
  const _AppWindow({required this.mods, required this.f, required this.si, required this.clock, required this.motion});

  final List<(String, String)> mods;
  final double f;
  final int si;
  final ValueListenable<double> clock;
  final ResponsiveMotionController motion;

  /// Sequential visibility window of view [i] (no overlapping crossfades).
  double vis(int i) {
    final d = f - i;
    if (d < .1) return Motion.seg(d, -.03, .06);
    if (d < 1) return 1 - Motion.seg(d, .86, .97);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final compact = motion.compact;
    Widget empty(double _) => const SizedBox.shrink();
    final views = <Widget Function(double)>[
      (lp) => _OverviewView(lp: lp),
      (lp) => _ReadinessView(lp: lp),
      empty,
      (lp) => _MatchList(lp: lp),
      empty,
      (lp) => _LocaliseView(lp: lp),
      (lp) => _CrmView(lp: lp, compact: compact, rtl: motion.rtl),
      (lp) => _IntelView(lp: lp),
    ];
    final sideW = compact ? 52.0 : 206.0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xEB0C1A32), Color(0xF5060E1E)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x384F8CFF)),
        boxShadow: const [
          BoxShadow(color: Color(0xCC000000), blurRadius: 140, spreadRadius: -40, offset: Offset(0, 60)),
          BoxShadow(color: Color(0x804F8CFF), blurRadius: 90, spreadRadius: -40),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1F4F8CFF)))),
          child: Row(children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A3A7A), Color(0xFF0A1330)]),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0x7393B4FF)),
              ),
              child: const Icon(Icons.change_history, size: 11, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text('AMEERIX',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontFamily: AppTypography.latinFamily, color: Colors.white, letterSpacing: 2.4, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(width: 14),
            if (!compact) ...[
              Container(
                height: 28,
                constraints: const BoxConstraints(minWidth: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.lineDark), color: const Color(0x05FFFFFF)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search, size: 15, color: AppColors.grey500),
                  const SizedBox(width: 8),
                  Text(l.demoWorkspace, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 14),
              Flexible(child: Text(l.visualSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 12))),
            ],
            const Spacer(),
            SceneTag(l.labelIllustrative),
          ]),
        ),
        Expanded(
          child: Row(children: [
            Container(
              width: sideW,
              decoration: const BoxDecoration(
                color: Color(0x59030814),
                border: BorderDirectional(end: BorderSide(color: Color(0x1F4F8CFF))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: LayoutBuilder(builder: (context, c) {
                final rowH = math.min(40.0, c.maxHeight / (mods.length + (compact ? 0 : .8)));
                final group = compact ? 0.0 : rowH * .8;
                double yOf(int i) => i == 0 ? 0 : i * rowH + group;
                final pos = Motion.lerp(yOf(si), yOf(math.min(mods.length - 1, si + 1)), Motion.easeInOut(Motion.seg(f - si, .85, 1)));
                return Stack(children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: pos,
                    height: rowH - 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0x294F8CFF), Color(0x0A4F8CFF)]),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0x594F8CFF)),
                        boxShadow: const [BoxShadow(color: Color(0x994F8CFF), blurRadius: 24, spreadRadius: -8)],
                      ),
                    ),
                  ),
                  for (var i = 0; i < mods.length; i++) ...[
                    if (i == 1 && !compact)
                      Positioned(
                        top: rowH,
                        left: 10,
                        right: 6,
                        height: group,
                        child: Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(t.usesUppercase ? l.navPlatform.toUpperCase() : l.navPlatform,
                              style: t.caption.copyWith(color: AppColors.grey500, fontSize: 10.5, letterSpacing: t.usesUppercase ? 1.6 : 0)),
                        ),
                      ),
                    Positioned(
                      top: yOf(i),
                      left: 0,
                      right: 0,
                      height: rowH,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10, end: 8, bottom: 4),
                        child: Row(children: [
                          Icon(PlatformDemo.icons[i], size: math.min(18.0, rowH * .5), color: i == si ? AppColors.electric : AppColors.grey500),
                          if (!compact) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(mods[i].$1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.caption.copyWith(
                                      fontSize: 13, color: i == si ? AppColors.white : AppColors.grey500, fontWeight: i == si ? FontWeight.w600 : FontWeight.w400)),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ]);
              }),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(compact ? 14 : 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(
                    height: 58,
                    child: Stack(children: [
                      for (var i = 0; i < mods.length; i++)
                        if (vis(i) > .01)
                          Positioned.fill(
                            child: Opacity(
                              opacity: vis(i),
                              child: Transform.translate(
                                offset: Offset(0, (1 - vis(i)) * (f < i ? 12 : -12)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(mods[i].$1, style: t.h3.copyWith(color: AppColors.white, fontSize: compact ? 17 : 20)),
                                  const SizedBox(height: 4),
                                  Text(mods[i].$2,
                                      maxLines: 2, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey500, fontSize: compact ? 11.5 : 12.5)),
                                ]),
                              ),
                            ),
                          ),
                    ]),
                  ),
                  SizedBox(height: compact ? 10 : 16),
                  Expanded(
                    child: Stack(children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MorphPainter(
                            f: f,
                            clock: clock,
                            motion: motion,
                            labels: LabelCache(t.caption, Directionality.of(context)),
                            names: [for (final m in DemoData.markets(l)) m.$1],
                          ),
                        ),
                      ),
                      for (var i = 0; i < mods.length; i++)
                        if (vis(i) > .01)
                          Positioned.fill(
                            child: Opacity(
                              opacity: vis(i),
                              child: Transform.translate(
                                offset: Offset((motion.rtl ? -1 : 1) * (f < i ? 30 : -30) * (1 - vis(i)), 0),
                                child: views[i](Motion.clamp01(f - i)),
                              ),
                            ),
                          ),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Translucent product panel.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(14), this.gold = false});
  final Widget child;
  final EdgeInsets padding;
  final bool gold;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold ? const Color(0x8CF4C76B) : const Color(0x244F8CFF)),
          boxShadow: gold ? const [BoxShadow(color: Color(0x73F4C76B), blurRadius: 20, spreadRadius: -6)] : null,
        ),
        child: child,
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.fill, this.gold = false, this.labelWidth});
  final String label;
  final double value;
  final double fill;
  final bool gold;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final txt = Text(label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.caption.copyWith(fontSize: 13, color: gold ? AppColors.gold : AppColors.grey300, fontWeight: gold ? FontWeight.w600 : null));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        if (labelWidth != null) SizedBox(width: labelWidth, child: txt) else Expanded(flex: 5, child: txt),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Container(
            height: 6,
            decoration: BoxDecoration(color: const Color(0x1A4F8CFF), borderRadius: BorderRadius.circular(6)),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: Motion.clamp01(fill),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: gold ? AppColors.opportunity : const LinearGradient(colors: [AppColors.blue, AppColors.violet]),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text('${(value * 100).round()}',
              textAlign: TextAlign.end, style: t.caption.copyWith(color: AppColors.white, fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ]),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.lp});
  final double lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final ranked = [...DemoData.markets(l)]..sort((a, b) => b.$2.compareTo(a.$2));
    Widget kpi(String label, String value, String sub, Color dot, {bool gold = false, bool text = false}) => _Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11.5)),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 2,
                style: t.h3.copyWith(
                  color: gold ? AppColors.gold : AppColors.white,
                  fontSize: text ? 17 : 26,
                  height: 1.15,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
            const SizedBox(height: 6),
            Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
              const SizedBox(width: 6),
              Flexible(child: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 11))),
            ]),
          ]),
        );
    final tiles = [
      kpi(l.demoOverall, '63', l.modReadinessName, AppColors.electric),
      kpi(l.demoKpiMarket, l.countryUae, '${l.modScoreName} · 82', AppColors.gold, gold: true, text: true),
      kpi(l.demoKpiShortlist, '3', l.modMatchName, AppColors.cyan),
      kpi(l.demoKpiActions, '3', l.modIntelName, AppColors.violetSoft),
    ];
    return FitStage(
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 600;
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (narrow)
            Column(children: [
              Row(children: [Expanded(child: tiles[0]), const SizedBox(width: 8), Expanded(child: tiles[1])]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: tiles[2]), const SizedBox(width: 8), Expanded(child: tiles[3])]),
            ])
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < 4; i++) ...[if (i > 0) const SizedBox(width: 12), Expanded(child: tiles[i])],
            ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 16,
              child: _Panel(
                child: SizedBox(
                  height: narrow ? 120 : 160,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(l.demoSignals, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 12)),
                    const SizedBox(height: 8),
                    Expanded(child: CustomPaint(painter: _AreaPainter(Motion.easeOut(Motion.seg(lp, .05, .6))))),
                  ]),
                ),
              ),
            ),
            if (!narrow) ...[
              const SizedBox(width: 12),
              Expanded(
                flex: 10,
                child: _Panel(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(l.modScoreName, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 12)),
                    const SizedBox(height: 6),
                    for (var i = 0; i < 4; i++) _Bar(label: ranked[i].$1, value: ranked[i].$2 / 100, fill: ranked[i].$2 / 100, gold: i == 0),
                  ]),
                ),
              ),
            ],
          ]),
        ]);
      }),
    );
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter(this.t);
  final double t;
  static const _v = [.32, .36, .34, .42, .40, .48, .46, .55, .52, .6, .58, .66, .7, .68, .76];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final pts = [for (var i = 0; i < _v.length; i++) Offset(i / (_v.length - 1) * w, h - _v[i] * h)];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w * t, h));
    final area = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(area, Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, h), [const Color(0x734F8CFF), const Color(0x004F8CFF)]));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF6EA8FF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AreaPainter old) => old.t != t;
}

class _ReadinessView extends StatelessWidget {
  const _ReadinessView({required this.lp});
  final double lp;
  static const dv = [.78, .64, .52, .7, .46, .6];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final dims = [l.dim1Title, l.dim2Title, l.dim3Title, l.dim4Title, l.dim5Title, l.dim6Title];
    final g = Motion.easeOut(Motion.seg(lp, .05, .7)) * .63;
    final gauge = _Panel(
      child: SizedBox(
        width: 150,
        height: 150,
        child: CustomPaint(
          painter: _GaugePainter(g),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(g * 100).round()}', style: t.h2.copyWith(color: AppColors.white, fontSize: 36)),
              Text(l.demoOverall, textAlign: TextAlign.center, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
    final bars = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var k = 0; k < 6; k++) _Bar(label: dims[k], value: dv[k], fill: Motion.easeOut(Motion.seg(lp, .1 + k * .06, .45 + k * .06)) * dv[k]),
      const SizedBox(height: 10),
      Text(t.usesUppercase ? l.demoGaps.toUpperCase() : l.demoGaps,
          style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11, letterSpacing: t.usesUppercase ? 1.2 : 0, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final d in [dims[2], dims[4]])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0x59F4C76B))),
            child: Text(d, style: t.caption.copyWith(color: const Color(0xFFF7DDA6), fontSize: 12)),
          ),
      ]),
    ]);
    return FitStage(
      child: LayoutBuilder(
        builder: (context, c) => c.maxWidth < 520
            ? Column(mainAxisSize: MainAxisSize.min, children: [gauge, const SizedBox(height: 12), bars])
            : Row(children: [gauge, const SizedBox(width: 28), Expanded(child: bars)]),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - 8);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(0x1F4F8CFF);
    canvas.drawArc(r, 0, math.pi * 2, false, base);
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      base
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.sweep(r.center, [AppColors.electric, AppColors.violetSoft, AppColors.electric], const [0, .5, 1], TileMode.clamp, -math.pi / 2, math.pi * 1.5),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.lp});
  final double lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    return LayoutBuilder(builder: (context, c) {
      final narrow = c.maxWidth < 600;
      final list = Column(mainAxisSize: MainAxisSize.min, children: [
        for (var k = 0; k < 3; k++)
          Builder(builder: (context) {
            final on = Motion.easeOut(Motion.seg(lp, .45 + k * .08, .65 + k * .08));
            return Opacity(
              opacity: on,
              child: Transform.translate(
                offset: Offset(0, (1 - on) * 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _Panel(
                    gold: k == 0 && on > .5,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(children: [
                      Expanded(child: Text(l.demoDistributor(['A', 'B', 'C'][k]), style: t.caption.copyWith(color: AppColors.white, fontSize: 13))),
                      for (var d = 0; d < 4; d++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsetsDirectional.only(start: 5),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: k == 0 ? AppColors.gold : AppColors.cyan),
                        ),
                      if (!narrow) ...[
                        const SizedBox(width: 10),
                        Text(l.matchF7, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 11)),
                      ],
                    ]),
                  ),
                ),
              ),
            );
          }),
      ]);
      return Align(
        alignment: narrow ? Alignment.bottomCenter : AlignmentDirectional.topEnd,
        child: SizedBox(width: narrow ? c.maxWidth : c.maxWidth * .4, child: list),
      );
    });
  }
}

class _LocaliseView extends StatelessWidget {
  const _LocaliseView({required this.lp});
  final double lp;
  static const widths = [.9, .7, .85, .6, .75, .82, .66, .9, .5];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    Widget pane(String title, IconData icon, bool target) => Expanded(
          child: _Panel(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Text(title, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 12))),
                Icon(icon, size: 16, color: target ? AppColors.violetSoft : AppColors.grey400),
              ]),
              const SizedBox(height: 12),
              for (var k = 0; k < widths.length; k++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Align(
                    // The Arabic target pane fills from the right, as Arabic text does.
                    alignment: target ? Alignment.centerRight : Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: widths[k] * (target ? Motion.easeOut(Motion.seg(lp, .1 + k * .06, .4 + k * .06)) : 1),
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: target ? null : const Color(0x8CCBD5E1),
                          gradient: target ? const LinearGradient(colors: [AppColors.electric, AppColors.violetSoft]) : null,
                        ),
                      ),
                    ),
                  ),
                ),
              if (target) ...[
                const SizedBox(height: 10),
                Opacity(
                  opacity: Motion.seg(lp, .6, .75),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x99221646),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x808B5CF6)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person_search_outlined, size: 14, color: AppColors.white),
                      const SizedBox(width: 6),
                      Flexible(child: Text(l.demoReview, style: t.caption.copyWith(color: AppColors.white, fontSize: 11.5))),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
        );
    return FitStage(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pane('${l.demoSource} · EN', Icons.description_outlined, false),
        const SizedBox(width: 14),
        pane('${l.demoTarget} · AR', Icons.translate, true),
      ]),
    );
  }
}

/// Kanban geometry shared by the CRM view and the morph layer.
class _Kanban {
  const _Kanban._();
  static int cols(bool compact) => compact ? 3 : 5;
  static const stepEnd = [4, 3, 2];
  static double colW(double w, bool compact) => (w - (cols(compact) - 1) * 10) / cols(compact);
  static Offset card(int k, double progress, double w, bool compact, bool rtl) {
    final cw = colW(w, compact);
    final col = Motion.lerp(0, math.min(cols(compact) - 1, stepEnd[k]).toDouble(), progress);
    final x = col * (cw + 10) + 8;
    return Offset(rtl ? w - x - (cw - 16) : x, 40 + k * 54.0);
  }
}

class _CrmView extends StatelessWidget {
  const _CrmView({required this.lp, required this.compact, required this.rtl});
  final double lp;
  final bool compact, rtl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final stages = [l.stage3, l.stage4, l.stage5, l.stage6, l.stage7];
    final cols = _Kanban.cols(compact);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final cw = _Kanban.colW(w, compact);
      final pr = Motion.easeInOut(Motion.seg(lp, .3, .9));
      return Stack(children: [
        for (var i = 0; i < cols; i++)
          PositionedDirectional(
            start: i * (cw + 10),
            top: 0,
            bottom: 0,
            width: cw,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0x730A142D),
                border: Border.all(color: const Color(0x1F4F8CFF)),
              ),
              child: Text(stages[i], maxLines: 2, style: t.caption.copyWith(color: AppColors.grey300, fontSize: 11.5, fontWeight: FontWeight.w500)),
            ),
          ),
        for (var k = 0; k < 3; k++)
          Builder(builder: (context) {
            final at = _Kanban.card(k, pr, w, compact, rtl);
            final arrive = Motion.seg(lp, .12 + k * .05, .28 + k * .05);
            return Positioned(
              left: at.dx,
              top: at.dy,
              width: cw - 16,
              child: Opacity(
                opacity: arrive,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xF2182646), Color(0xF20C162C)]),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: k == 0 ? const Color(0x99F4C76B) : const Color(0x4D4F8CFF)),
                    boxShadow: k == 0 ? const [BoxShadow(color: Color(0x73F4C76B), blurRadius: 20, spreadRadius: -6)] : null,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(l.demoDistributor(['A', 'B', 'C'][k]), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.white, fontSize: 12)),
                    Text(l.visualSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 10.5)),
                  ]),
                ),
              ),
            );
          }),
      ]);
    });
  }
}

class _IntelView extends StatelessWidget {
  const _IntelView({required this.lp});
  final double lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final items = [(Icons.schedule, l.intelEx1, AppColors.electric), (Icons.sell_outlined, l.intelEx2, AppColors.violetSoft), (Icons.insights, l.intelEx3, AppColors.gold)];
    return FitStage(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(t.usesUppercase ? l.demoNextActions.toUpperCase() : l.demoNextActions,
            style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11, letterSpacing: t.usesUppercase ? 1.2 : 0, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        for (var k = 0; k < 3; k++)
          Builder(builder: (context) {
            final on = Motion.easeOut(Motion.seg(lp, .15 + k * .15, .4 + k * .15));
            return Opacity(
              opacity: on,
              child: Transform.translate(
                offset: Offset(0, (1 - on) * 16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Panel(
                    child: Row(children: [
                      Icon(items[k].$1, size: 18, color: items[k].$3),
                      const SizedBox(width: 12),
                      Expanded(child: Text(items[k].$2, style: t.bodySmall.copyWith(color: AppColors.grey300))),
                      const SizedBox(width: 8),
                      SceneTag(l.labelDemo),
                    ]),
                  ),
                ),
              ),
            );
          }),
      ]),
    );
  }
}

/// One continuous visual under the views: score columns → GCC map with the
/// priority market → partner nodes → Trade Graph → gold opportunities flying
/// into the CRM → the intelligence core producing next actions.
class _MorphPainter extends CustomPainter {
  _MorphPainter({required this.f, required this.clock, required this.motion, required this.labels, required this.names}) : super(repaint: clock);

  final double f;
  final ValueListenable<double> clock;
  final ResponsiveMotionController motion;
  final LabelCache labels;
  final List<String> names; // plan order: Bahrain, Kuwait, Oman, Qatar, KSA, UAE

  static const _scores = [51, 58, 54, 63, 74, 82];
  static const _keys = ['bahrain', 'kuwait', 'oman', 'qatar', 'ksa', 'uae'];
  static final _partners = () {
    final r = SeededRandom(3);
    return List.generate(9, (i) => (r.next() * math.pi * 2, .35 + r.next() * .65));
  }();
  static final _extra = () {
    final r = SeededRandom(33);
    return List.generate(16, (i) => (r.next(), r.next(), (r.next() * 4).floor()));
  }();
  static final _edges = () {
    final r = SeededRandom(34);
    final out = <(int, int, double)>[];
    for (var i = 0; i < 25; i++) {
      for (var j = i + 1; j < 25; j++) {
        if (r.next() < .1) out.add((i, j, r.next()));
      }
    }
    return out;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    if (f < 1.85 || f > 7.9) return;
    final w = size.width, h = size.height;
    final tt = motion.reduced ? 0.0 : clock.value;
    final mob = motion.compact, rtl = motion.rtl;
    final cA = Motion.seg(f, 1.9, 2.05) * (1 - Motion.seg(f, 2.86, 2.97));
    final morph = Motion.easeInOut(Motion.seg(f, 2.8, 3.1));
    final mapA = Motion.seg(f, 2.85, 3.05) * (1 - Motion.seg(f, 3.86, 3.97));
    final netA = Motion.easeInOut(Motion.seg(f, 3.8, 4.15)) * (1 - Motion.seg(f, 4.86, 4.97));

    // GCC map projection (equirectangular) in the start-side 56 %.
    final mw = mob ? w : w * .56, mh = mob ? h * .62 : h;
    final mx0 = rtl && !mob ? w - mw : 0.0;
    const lon0 = 34.0, lon1 = 60.5, la0 = 12.0, la1 = 32.5;
    final s = math.min(mw / (lon1 - lon0), mh / (la1 - la0) * 1.08);
    final ox = mx0 + (mw - (lon1 - lon0) * s) / 2, oy = (mh - (la1 - la0) * s) / 2;
    Offset mp((double, double) ll) => Offset(ox + (ll.$2 - lon0) * s, oy + (la1 - ll.$1) * s);
    final mapAlpha = math.max(mapA, morph * (1 - Motion.seg(f, 3.86, 3.97)));
    if (mapAlpha > 0) {
      final dot = Paint()..color = Sem.dataSoft.withValues(alpha: .34 * mapAlpha);
      for (final (la, lo) in GeoData.instance.gcc) {
        if (la < la0) continue;
        canvas.drawRect(Rect.fromCenter(center: mp((la, lo)), width: 1.6, height: 1.6), dot);
      }
    }

    final ranked = List.generate(6, (i) => i)..sort((a, b) => _scores[b].compareTo(_scores[a]));
    final slot = w / 6, base = h * .88, maxH = h * .72;
    final uae = mp(Places.markets['uae']!);
    for (var i = 0; i < 6; i++) {
      final rank = ranked.indexOf(i);
      final si = rtl ? 5 - rank : rank;
      final colX = (si + .5) * slot;
      final lead = rank == 0;
      final grow = Motion.easeOut(Motion.seg(f, 2.02 + rank * .03, 2.4 + rank * .03));
      final pt = mp(Places.markets[_keys[i]]!);
      final bh = maxH * _scores[i] / 100 * grow * (1 - morph);
      final x = Motion.lerp(colX, pt.dx, morph), yb = Motion.lerp(base, pt.dy, morph);
      final c = lead ? Sem.gold : Sem.link;
      final a = math.max(cA, morph * (1 - Motion.seg(f, 3.86, 3.97)));
      if (a <= 0) continue;
      if (bh > 1) {
        final bw = Motion.lerp(mob ? 14 : 26, 4, morph);
        final r = Rect.fromLTWH(x - bw / 2, yb - bh, bw, bh);
        canvas.drawRect(
            r,
            Paint()
              ..blendMode = BlendMode.plus
              ..shader = LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [(lead ? const Color(0xFFE0A84A) : AppColors.blue).withValues(alpha: .6 * a), c.withValues(alpha: .18 * a)],
              ).createShader(r));
        Glow.draw(canvas, c, Offset(x, yb - bh), bw * 1.6, .6 * a);
        final v = labels.get('${(_scores[i] * grow).round()}', (lead ? const Color(0xFFF8E0AA) : Sem.ink).withValues(alpha: a * (1 - morph * 2).clamp(0.0, 1.0)), mob ? 10.5 : 12, FontWeight.w600);
        v.paint(canvas, Offset(x - v.width / 2, yb - bh - v.height - 5));
      }
      Glow.draw(canvas, c, Offset(x, yb), lead ? 16 : 10, .8 * a);
      dotAt(canvas, Offset(x, yb), lead ? 3 : 2, Sem.ink, a);
      if (morph < .5) {
        final nm = labels.get(names[i], AppColors.grey400.withValues(alpha: a * (1 - morph * 2)), mob ? 10 : 11.5);
        final tw = math.min(nm.width, slot - 6);
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(x - tw / 2, base + 8, tw, nm.height));
        nm.paint(canvas, Offset(x - tw / 2, base + 8));
        canvas.restore();
      } else {
        final nm = labels.get(names[i], const Color(0xFFD2F0FA).withValues(alpha: a * (morph - .5) * 2), 11);
        nm.paint(canvas, Offset(x - nm.width / 2, yb - 12 - nm.height));
      }
    }

    // Partner nodes emerge around the priority market.
    final pe = Motion.seg(f, 3.2, 3.6);
    final r0 = mob ? 46.0 : 62.0;
    final pn = [for (final (a, d) in _partners) uae + Offset(math.cos(a) * r0 * d, math.sin(a) * r0 * d * .8)];
    final ex = [for (final (x, y, _) in _extra) Offset(w * (.14 + x * .72), h * (.12 + y * .76))];
    Offset nodePos(int i) {
      if (i >= 9) return ex[i - 9];
      final tx = w * (.3 + .4 * ((i * 37) % 9) / 9), ty = h * (.2 + .6 * ((i * 53) % 9) / 9);
      return Offset.lerp(pn[i], Offset(tx, ty), netA)!;
    }

    final ln = Paint()
      ..strokeWidth = 1
      ..blendMode = BlendMode.plus;
    if (pe > 0 && mapA > 0) {
      for (var i = 0; i < 9; i++) {
        final on = Motion.seg(pe, i * .08, .3 + i * .08);
        final gold = i < 3;
        ln.color = (gold ? Sem.gold : Sem.link).withValues(alpha: .3 * on * mapA);
        canvas.drawLine(uae, pn[i], ln);
        Glow.draw(canvas, gold ? Sem.gold : Sem.link, pn[i], gold ? 12 : 8, on * mapA * .8);
        dotAt(canvas, pn[i], gold ? 2.2 : 1.4, Sem.ink, on * mapA);
      }
    }
    // …which spread into a Trade Graph around the intelligence core.
    if (netA > 0) {
      final grow = Motion.seg(f, 4, 4.6);
      for (final (i, j, k) in _edges) {
        if (k > grow) continue;
        final imp = i < 3 || j < 3;
        ln
          ..color = (imp ? Sem.aiSoft : Sem.link).withValues(alpha: (imp ? .4 : .14) * netA)
          ..strokeWidth = imp ? 1.2 : .8;
        canvas.drawLine(nodePos(i), nodePos(j), ln);
      }
      const extraCols = [Sem.data, Sem.dataSoft, Sem.ai, Sem.aiSoft];
      for (var i = 0; i < 25; i++) {
        final gold = i < 3;
        final c = gold ? Sem.gold : (i < 9 ? Sem.link : extraCols[_extra[i - 9].$3]);
        Glow.draw(canvas, c, nodePos(i), gold ? 14 : 8, netA * (gold ? .9 : .6));
        dotAt(canvas, nodePos(i), gold ? 2.4 : 1.5, Sem.ink, netA);
      }
      final cc = Offset(w / 2, h / 2);
      ln
        ..color = Sem.gold.withValues(alpha: .35 * netA)
        ..strokeWidth = 1;
      for (var i = 0; i < 3; i++) {
        canvas.drawLine(cc, nodePos(i), ln);
      }
      paintIntelligenceCore(canvas, cc, mob ? 16 : 22, tt, energy: .8, alpha: netA);
    }

    // CRM: priority opportunities fly into the pipeline as gold signals.
    final crm = Motion.seg(f, 5.95, 6.35) * (1 - Motion.seg(f, 6.86, 6.97));
    if (crm > 0) {
      final pr = Motion.easeInOut(Motion.seg(f - 6, .3, .9));
      for (var k = 0; k < 3; k++) {
        final at = _Kanban.card(k, pr, w, mob, rtl) + const Offset(12, 22);
        final u = Motion.easeInOut(Motion.seg(f, 6.0 + k * .05, 6.25 + k * .05));
        final p = Offset.lerp(Offset(w * .5, -10), at, u)!;
        Glow.draw(canvas, Sem.gold, p, 12, crm * (1 - u * .6));
        dotAt(canvas, p, 2, Sem.ink, crm * (1 - u));
      }
    }

    // Intelligence: the engine produces the recommended next actions.
    final ia = Motion.seg(f, 6.95, 7.15);
    if (ia > 0) {
      final cc = Offset(rtl ? 40 : w - 40, 20);
      paintIntelligenceCore(canvas, cc, mob ? 9 : 12, tt, energy: .9, alpha: ia);
      const cols = [Sem.data, Sem.aiSoft, Sem.gold];
      for (var k = 0; k < 3; k++) {
        final on = Motion.easeOut(Motion.seg(f - 7, .15 + k * .15, .4 + k * .15));
        final ty = 30 + k * (h * .22) + h * .08;
        ln
          ..color = cols[k].withValues(alpha: .35 * on * ia)
          ..strokeWidth = 1;
        canvas.drawLine(cc + const Offset(0, 14), Offset(rtl ? 20 : w - 20, ty), ln);
      }
    }
  }

  @override
  bool shouldRepaint(_MorphPainter old) => old.f != f || old.motion != motion;
}
