import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../motion/light.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/magnetic.dart';
import '../../widgets/visuals/intelligence_core.dart';

/// Cinematic opening: "From market complexity to commercial clarity." beside
/// a procedural dotted earth. Spain emits blue data signals that travel into
/// the floating Amhilo intelligence core; as the visitor scrolls, the camera
/// moves in, violet processing energy rises, paths illuminate the six GCC
/// markets (UAE and Saudi Arabia first, per the rollout strategy) and finally
/// two restrained gold opportunity paths reach the UAE and Saudi Arabia.
class HeroScene extends StatelessWidget {
  const HeroScene({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PinnedStorySection(
      heightFactor: 2.2,
      compactHeightFactor: 1.7,
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        final t = AppTypography.of(context);
        final labels = LabelCache(t.caption, Directionality.of(context));
        final names = {
          'uae': l.countryUae,
          'ksa': l.countryKsa,
          'qatar': l.countryQatar,
          'kuwait': l.countryKuwait,
          'oman': l.countryOman,
          'bahrain': l.countryBahrain,
        };
        final pointer = ValueNotifier<Offset>(Offset.zero);
        return AmbientClock(
          visible: visible,
          builder: (context, clock) => MouseRegion(
            onHover: m.compact ? null : (e) => pointer.value = Offset(e.localPosition.dx / size.width - .5, e.localPosition.dy / size.height - .5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.deepSpace),
                ExcludeSemantics(
                  child: CustomPaint(
                    painter: _HeroPainter(
                      progress: progress,
                      clock: clock,
                      pointer: pointer,
                      motion: m,
                      labels: labels,
                      spain: l.heroLabelSpain,
                      layer: l.heroLabelLayer,
                      names: names,
                    ),
                  ),
                ),
                // Vignette for depth.
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(radius: 1.1, colors: [Color(0x00020510), Color(0x00020510), Color(0xA602050E)], stops: [0, .55, 1]),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) {
                    final a = Motion.seg(progress.value, .03, .3);
                    return IgnorePointer(
                      ignoring: a > .6,
                      child: Opacity(opacity: 1 - a, child: Transform.translate(offset: Offset(0, -a * 70), child: child)),
                    );
                  },
                  child: _HeroCopy(compact: m.compact),
                ),
                if (!m.compact)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 22,
                    child: AnimatedBuilder(
                      animation: progress,
                      builder: (context, _) => Opacity(
                        opacity: 1 - Motion.seg(progress.value, 0, .07),
                        child: ExcludeSemantics(
                          child: Column(
                            children: [
                              Text(
                                t.usesUppercase ? l.heroScrollHint.toUpperCase() : l.heroScrollHint,
                                style: t.caption.copyWith(color: AppColors.grey500, letterSpacing: t.usesUppercase ? 2.4 : 0, fontSize: 11.5),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 1,
                                height: 36,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [AppColors.electric, Color(0x004F8CFF)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final size = MediaQuery.sizeOf(context);
    final latinLong = t.usesUppercase && Localizations.localeOf(context).languageCode != 'en';
    final titleSize = compact
        ? (size.width * (latinLong ? .096 : .115)).clamp(34.0, 64.0)
        : (size.width * (latinLong ? .046 : .053)).clamp(40.0, latinLong ? 78.0 : 88.0);
    final titleStyle = t.display.copyWith(
      color: AppColors.white,
      fontSize: titleSize,
      height: t.usesUppercase ? 1.0 : 1.25,
      letterSpacing: t.usesUppercase ? -titleSize * .045 : 0,
      fontWeight: FontWeight.w600,
    );
    final kicker = t.caption.copyWith(color: AppColors.grey400, fontSize: compact ? 10.5 : 12, letterSpacing: t.usesUppercase ? 3.8 : .6, fontWeight: FontWeight.w500);
    String up(String s) => t.usesUppercase ? s.toUpperCase() : s;

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.electric,
                  boxShadow: [BoxShadow(color: Color(0xCC4F8CFF), blurRadius: 12, spreadRadius: 2)],
                ),
              ),
              Text(up(l.heroKicker), style: kicker),
              Container(width: 1, height: 14, color: AppColors.lineDarkStrong),
              Text(up(l.storyEyebrow), style: kicker),
            ],
          ),
        ),
        SizedBox(height: compact ? 18 : 28),
        Semantics(
          header: true,
          headingLevel: 1,
          label: '${l.heroLine1} ${l.heroLine2}',
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: t.usesUppercase ? titleSize * 7.2 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmphasisLine(text: l.heroLine1, emphasis: l.heroEmphasis, style: titleStyle),
                  _EmphasisLine(text: l.heroLine2, emphasis: l.heroEmphasis, style: titleStyle),
                ],
              ),
            ),
          ),
        ),
        if (!compact || size.height > 760) ...[
          SizedBox(height: compact ? 16 : 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(l.homeHeroBody, style: t.body.copyWith(color: AppColors.grey400, fontSize: compact ? 15 : 17)),
          ),
        ],
        SizedBox(height: compact ? 22 : 34),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            Magnetic(child: AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true, compact: compact)),
            Magnetic(child: AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, variant: ButtonVariant.secondary, compact: compact)),
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: 40),
          ExcludeSemantics(
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _Legend(color: AppColors.electric, text: l.heroLabelSpain),
                _Legend(color: AppColors.violet, text: l.heroLabelLayer),
                _Legend(color: AppColors.cyan, text: l.heroLabelGcc),
              ],
            ),
          ),
        ],
      ],
    );

    return Tone(
      palette: TonePalette.dark,
      child: compact
          ? Padding(
              padding: EdgeInsets.fromLTRB(20, 64 + size.height * .035, 20, 0),
              child: Align(alignment: AlignmentDirectional.topStart, child: copy),
            )
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: math.max(48, (size.width - 1320) / 2 + 48), top: 60),
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: math.min(660, size.width * .5)), child: copy),
              ),
            ),
    );
  }
}

/// One headline line; [emphasis] (if it occurs in [text]) gets the subtle
/// blue→violet intelligence treatment — never the whole headline.
class _EmphasisLine extends StatelessWidget {
  const _EmphasisLine({required this.text, required this.emphasis, required this.style});
  final String text;
  final String emphasis;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final i = emphasis.isEmpty ? -1 : text.indexOf(emphasis);
    if (i < 0) return Text(text, style: style);
    final size = style.fontSize ?? 60;
    final shader = ui.Gradient.linear(Offset.zero, Offset(size * 4.5, size * .2), const [Color(0xFF6EA8FF), Color(0xFF8B7CF8), Color(0xFFB79CFF)], const [0, .55, 1]);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text.substring(0, i)),
        TextSpan(
          text: emphasis,
          // Only foreground here: a span style may not carry both a colour
          // and a foreground paint.
          style: TextStyle(
            foreground: Paint()..shader = shader,
            shadows: const [Shadow(color: Color(0x596E8CFF), blurRadius: 28)],
          ),
        ),
        TextSpan(text: text.substring(i + emphasis.length)),
      ]),
      style: style,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 8)]),
      ),
      const SizedBox(width: 8),
      Text(text, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 12)),
    ]);
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter({
    required this.progress,
    required this.clock,
    required this.pointer,
    required this.motion,
    required this.labels,
    required this.spain,
    required this.layer,
    required this.names,
  }) : super(repaint: Listenable.merge([progress, clock, pointer])) {
    final r = SeededRandom(7);
    final mob = motion.compact;
    for (var i = 0; i < (mob ? 20 : 34); i++) {
      _ps.add((r.next(), .7 + r.next() * .6));
    }
    for (var i = 0; i < (mob ? 24 : 42); i++) {
      final a = r.next(), b = r.next(), c = r.next(), d = r.next();
      _pg.add((a, b < .55 ? (c < .5 ? 'uae' : 'ksa') : _order[(d * 6).floor().clamp(0, 5)], .6 + r.next() * .7));
    }
    for (var i = 0; i < (mob ? 40 : 90); i++) {
      _dust.add((r.next(), r.next(), r.next(), r.next() * 6.28));
    }
    final vs = latLon(Places.spain.$1, Places.spain.$2);
    _core = latLon(Places.coreAnchor.$1, Places.coreAnchor.$2);
    _spainArc = arc3(vs, _core, 1, _alt, .18, 56);
    for (final k in _order) {
      final (la, lo) = Places.markets[k]!;
      _mk[k] = latLon(la, lo);
      _arcs[k] = arc3(_core, _mk[k]!, _alt, 1, .16, 56);
    }
    _spain = vs;
  }

  static const _alt = 1.52;
  static const _order = ['kuwait', 'bahrain', 'qatar', 'uae', 'oman', 'ksa'];
  // Label side and vertical offset per market (avoids collisions).
  static const _lo = {'ksa': (-1.0, 10.0), 'bahrain': (-1.0, -4.0), 'kuwait': (-1.0, -12.0), 'qatar': (1.0, -12.0), 'uae': (1.0, 2.0), 'oman': (1.0, 14.0)};

  final ValueListenable<double> progress;
  final ValueListenable<double> clock;
  final ValueListenable<Offset> pointer;
  final ResponsiveMotionController motion;
  final LabelCache labels;
  final String spain, layer;
  final Map<String, String> names;

  final List<(double, double)> _ps = [];
  final List<(double, String, double)> _pg = [];
  final List<(double, double, double, double)> _dust = [];
  final Map<String, Vec3> _mk = {};
  final Map<String, List<Vec3>> _arcs = {};
  late final Vec3 _core, _spain;
  late final List<Vec3> _spainArc;
  Offset _ptr = Offset.zero;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = progress.value;
    final tt = motion.reduced ? 0.0 : clock.value;
    final mob = motion.compact, rtl = motion.rtl;
    _ptr = Offset.lerp(_ptr, pointer.value, .05)!;

    // Atmospheric particles.
    for (final (x, y, z, ph) in _dust) {
      final dx = ((x * w + math.sin(tt * .05 + ph) * 12 - _ptr.dx * 20 * z) % w + w) % w;
      final dy = y * h + math.cos(tt * .04 + ph) * 10 - _ptr.dy * 14 * z;
      dotAt(canvas, Offset(dx, dy), .6 + z * .9, Sem.dataSoft, .1 + .25 * z * (.6 + .4 * math.sin(tt * .8 + ph)));
    }

    final lift = Motion.easeInOut(Motion.seg(p, .04, .5));
    final cx = mob ? Motion.lerp(w * .5, rtl ? w * .62 : w * .4, lift) : Motion.lerp(rtl ? w * .3 : w * .69, w * .5, lift) - _ptr.dx * 18;
    final cy = mob ? Motion.lerp(h * 1.1, h * .6, lift) : Motion.lerp(h * .56, h * .6, lift) - _ptr.dy * 12;
    final radius = mob
        ? Motion.lerp(w * .85, math.min(w * .6, h * .34), lift)
        : Motion.lerp(math.min(h * .42, w * .29), math.min(h * .64, w * .4), lift);
    final lon0 = Motion.lerp(16, mob ? 30 : 24, lift) + math.sin(tt * .07) * (5 - 3 * lift) + _ptr.dx * 8;
    final lat0 = Motion.lerp(26, 31, lift) + math.cos(tt * .05) * 2 - _ptr.dy * 5;
    final v = GlobeView(center: Offset(cx, cy), radius: radius, lon0: lon0, lat0: lat0);

    final act = .35 + .65 * Motion.seg(p, .08, .34);
    final proc = Motion.seg(p, .26, .5);
    final emerge = Motion.seg(p, .36, .7);
    final gold = Motion.seg(p, .7, .93);

    paintGlobe(canvas, v, highlightSpain: .55 + .45 * act, highlightGcc: .25 + .75 * emerge, sparse: mob);

    // Spain → intelligence layer (blue data).
    drawArc(canvas, v, _spainArc, Sem.data, .22 + .5 * act, width: 1.3);
    for (final (o, s) in _ps) {
      final u = (tt * .09 * s + o) % 1;
      final (pt, _, hid) = arcAt(v, _spainArc, u);
      final a = (s > 1 ? .9 : .7) * act * math.sin(math.pi * u) * (hid ? .2 : 1);
      Glow.draw(canvas, Sem.data, pt, 7, a * .8);
      dotAt(canvas, pt, 1.3, Sem.ink, a);
    }

    // Intelligence layer → six GCC markets.
    for (var i = 0; i < _order.length; i++) {
      final k = _order[i];
      final prim = k == 'uae' || k == 'ksa';
      final dr = Motion.seg(emerge, i * .08, .55 + i * .08);
      final a = (prim ? .16 : .08) + (prim ? .55 : .32) * dr;
      drawArc(canvas, v, _arcs[k]!, Sem.mix(Sem.ai, Sem.link, .55 + .45 * dr), a, u1: prim ? 1 : dr, width: 1.1);
      if (gold > 0 && prim) drawArc(canvas, v, _arcs[k]!, Sem.gold, .75 * gold, u1: Motion.easeInOut(gold), width: 1.6);
    }
    for (final (o, k, s) in _pg) {
      final prim = k == 'uae' || k == 'ksa';
      final vis = prim ? .35 + .65 * emerge : emerge;
      if (vis <= .02) continue;
      final u = (tt * .07 * s + o) % 1;
      final (pt, _, hid) = arcAt(v, _arcs[k]!, u);
      final a = vis * math.sin(math.pi * u) * (hid ? .2 : 1);
      Glow.draw(canvas, prim && gold > .2 ? Sem.gold : Sem.link, pt, 6, a * .8);
      dotAt(canvas, pt, 1.1, Sem.ink, a);
    }

    // Spain node with a slow pulse.
    final (ps, _, _) = v.project(_spain);
    Glow.draw(canvas, Sem.data, ps, 26 + 6 * math.sin(tt * 1.6), .55 * act + .2);
    dotAt(canvas, ps, 3.2, Sem.ink, .95);
    final k0 = (tt * .5) % 1;
    canvas.drawCircle(
        ps,
        6 + k0 * 22,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Sem.data.withValues(alpha: .35 * (1 - k0)));

    // Markets.
    for (var i = 0; i < _order.length; i++) {
      final k = _order[i];
      final (pt, _, hid) = v.project(_mk[k]!);
      if (hid) continue;
      final prim = k == 'uae' || k == 'ksa';
      final dr = Motion.seg(emerge, i * .08, .55 + i * .08);
      final a = prim ? .45 + .55 * math.max(dr, .3) : .15 + .85 * dr;
      final c = prim && gold > 0 ? Sem.mix(Sem.link, Sem.gold, gold) : Sem.link;
      Glow.draw(canvas, c, pt, (prim ? 20 : 12) * (1 + .2 * math.sin(tt * 2 + i)), a * .7);
      dotAt(canvas, pt, prim ? 2.8 : 1.8, Sem.ink, a);
      if (prim) {
        final kk = (tt * .45 + i * .3) % 1;
        canvas.drawCircle(
            pt,
            5 + kk * 20,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = c.withValues(alpha: Motion.clamp01(.5 * a * (1 - kk))));
      }
    }

    // The Amhilo core floating over the corridor.
    final (pc, _, _) = v.project((_core.$1 * _alt, _core.$2 * _alt, _core.$3 * _alt));
    final cs = radius * (mob ? .1 : .085);
    paintIntelligenceCore(canvas, pc, cs, tt, energy: .35 + .65 * proc, gold: gold * .6);

    // Labels (localised).
    final la = mob ? Motion.seg(p, .2, .34) : .55 + .45 * Motion.seg(p, .1, .3);
    if (la > 0) {
      final sp = labels.get(spain, const Color(0xFFBFD3FF).withValues(alpha: la * .95), mob ? 11 : 12.5);
      sp.paint(canvas, ps + Offset(-sp.width / 2, 14));
      final ly = labels.get(layer, const Color(0xFFD6C8FF).withValues(alpha: la), mob ? 11 : 12.5);
      ly.paint(canvas, pc + Offset(-ly.width / 2, cs * 2.2 + 8));
    }
    for (var i = 0; i < _order.length; i++) {
      final k = _order[i];
      final (pt, _, hid) = v.project(_mk[k]!);
      if (hid) continue;
      final prim = k == 'uae' || k == 'ksa';
      final dr = Motion.seg(emerge, i * .08, .55 + i * .08);
      final a = prim ? math.max(dr, mob ? 0.0 : .4) : dr * (1 - .5 * gold);
      if (a < .02) continue;
      final (side, dy) = _lo[k]!;
      final col = prim && gold > 0 ? const Color(0xFFF8E0AA) : const Color(0xFFD2F0FA);
      final tp = labels.get(names[k]!, col.withValues(alpha: prim ? a : a * .9), prim ? (mob ? 12 : 13.5) : 11.5, prim ? FontWeight.w600 : FontWeight.w500);
      tp.paint(canvas, pt + Offset(side < 0 ? -12 - tp.width : 12, dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_HeroPainter old) => old.motion != motion || old.names != names;
}
