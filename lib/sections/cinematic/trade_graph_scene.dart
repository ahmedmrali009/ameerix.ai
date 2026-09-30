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

enum GraphShape { dot, square, ring, diamond, triangle, star }

/// The Ameerix Trade Graph — the signature "commercial intelligence
/// universe". A luminous dotted world sits at the centre of three depth
/// shells of entities (companies, products, categories, markets, countries,
/// distributors, retailers, hotel groups, projects, opportunities, signals).
/// Scroll grows and rotates the graph, multiplies relationships, then traces
/// manufacturer → product → market → distributor → opportunity with glowing
/// light; the opportunity turns gold. Hover (desktop) illuminates a node's
/// relationships and dims the rest. Mobile: fewer nodes, no tilt.
class TradeGraphVisualization extends StatefulWidget {
  const TradeGraphVisualization({super.key});

  /// Semantic colour per entity type (blue data, cyan markets/connections,
  /// violet partners, gold opportunity, sparse magenta signals).
  static const colors = [
    AppColors.electric, // Spanish companies
    AppColors.blueSoft, // products
    Color(0xFF7084AC), // categories
    AppColors.cyan, // markets
    Color(0xFF60B0C8), // countries
    AppColors.violet, // distributors
    AppColors.violetSoft, // retailers
    Color(0xFFC4AAFF), // hotel groups
    AppColors.blue, // projects
    AppColors.gold, // opportunities
    AppColors.magenta, // signals
  ];
  static const shapes = [
    GraphShape.dot,
    GraphShape.dot,
    GraphShape.square,
    GraphShape.ring,
    GraphShape.dot,
    GraphShape.diamond,
    GraphShape.diamond,
    GraphShape.square,
    GraphShape.triangle,
    GraphShape.star,
    GraphShape.dot,
  ];

  @override
  State<TradeGraphVisualization> createState() => _TradeGraphVisualizationState();
}

class _TradeGraphVisualizationState extends State<TradeGraphVisualization> {
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final types = [l.gnCompany, l.gnProduct, l.gnCategory, l.gnMarket, l.gnCountry, l.gnDistributor, l.gnRetailer, l.gnHotel, l.gnProject, l.gnOpportunity, l.gnSignal];
    final stages = [l.graphS1, l.graphS2, l.graphS3, l.graphS4, l.graphS5, l.graphS6];
    return PinnedStorySection(
      heightFactor: 6.8,
      compactHeightFactor: 5.2,
      semanticLabel: '${l.graphEyebrow}. ${l.graphTitle} ${l.graphBody} ${types.join(', ')}.',
      builder: (context, progress, visible, size) {
        final m = ResponsiveMotionController.of(context);
        final t = AppTypography.of(context);
        final model = _GraphModel(m.compact);
        final pathLabels = [l.pathManufacturer, l.pathProduct, l.wordMarket, l.pathDistributor, l.wordOpportunity];
        return ExcludeSemantics(
          child: AmbientClock(
            visible: visible,
            builder: (context, clock) => MouseRegion(
              onHover: m.compact ? null : (e) => _pointer.value = e.localPosition,
              onExit: (_) => _pointer.value = null,
              child: LayoutBuilder(builder: (context, c) {
                final pad = stagePadding(context);
                final w = c.maxWidth;
                return Stack(children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.hazeBlack,
                        gradient: RadialGradient(
                          center: Alignment(m.compact ? 0 : (m.rtl ? -.3 : .3), m.compact ? .3 : .05),
                          radius: .8,
                          colors: const [Color(0x337C3AED), Color(0x007C3AED)],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GraphPainter(
                        progress: progress,
                        clock: clock,
                        pointer: _pointer,
                        motion: m,
                        model: model,
                        typeNames: types,
                        pathLabels: pathLabels,
                        labels: LabelCache(t.caption, Directionality.of(context)),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: pad.top + 8,
                    start: math.max(pad.left, (w - 1360) / 2 + pad.left),
                    end: m.compact ? pad.right : null,
                    width: m.compact ? null : math.min(380, w * .34),
                    child: IgnorePointer(
                      child: Tone(
                        palette: TonePalette.haze,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow(l.graphEyebrow),
                            SizedBox(height: m.compact ? 8 : 18),
                            Text(l.graphTitle, style: t.h2.copyWith(color: AppColors.white, fontSize: m.compact ? 22 : null)),
                            const SizedBox(height: 10),
                            Text(l.graphBody, style: t.bodySmall.copyWith(color: AppColors.grey400)),
                            const SizedBox(height: 14),
                            AnimatedBuilder(
                              animation: progress,
                              builder: (context, _) {
                                final p = progress.value;
                                final si = p < .2 ? 0 : p < .42 ? 1 : p < .62 ? 2 : p < .74 ? 3 : p < .86 ? 4 : 5;
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(stages[si], key: ValueKey(si), style: t.h3.copyWith(color: AppColors.white, fontSize: m.compact ? 18 : 22)),
                                );
                              },
                            ),
                            if (!m.compact) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 14,
                                runSpacing: 6,
                                children: [
                                  for (var i = 0; i < types.length; i++)
                                    SizedBox(
                                      width: 170,
                                      child: Row(children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CustomPaint(painter: _ShapeIcon(TradeGraphVisualization.shapes[i], TradeGraphVisualization.colors[i])),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(types[i], style: t.caption.copyWith(color: AppColors.grey400, fontSize: 12))),
                                      ]),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(l.graphHint, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                    ),
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

class _GNode {
  _GNode(this.type, this.x, this.y, this.z);
  final int type;
  final double x, y, z;
}

class _GEdge {
  _GEdge(this.a, this.b, this.threshold);
  final int a, b;
  double threshold;
  bool important = false;
}

class _GraphModel {
  _GraphModel(bool compact) {
    final r = SeededRandom(5);
    final counts = compact ? [6, 10, 4, 3, 6, 8, 4, 4, 3, 6, 6] : [14, 24, 8, 6, 6, 18, 10, 8, 8, 12, 18];
    const types = 11;
    for (var ti = 0; ti < types; ti++) {
      final y = 1 - (ti / (types - 1)) * 2;
      final rad = math.sqrt(math.max(0, 1 - y * y));
      final th = ti * 2.39996;
      final c = [math.cos(th) * rad, y * .9, math.sin(th) * rad];
      final shell = 1.45 + (ti % 3) * .24; // three depth layers around the world
      for (var j = 0; j < counts[ti]; j++) {
        final v = [c[0] + (r.next() - .5) * .55, c[1] + (r.next() - .5) * .55, c[2] + (r.next() - .5) * .55];
        final m = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
        final rr = shell + (r.next() - .5) * .3;
        nodes.add(_GNode(ti, v[0] / m * rr, v[1] / m * rr, v[2] / m * rr));
      }
    }
    List<int> of(int t) => [for (var i = 0; i < nodes.length; i++) if (nodes[i].type == t) i];
    int pick(List<int> a) => a[(r.next() * a.length).floor()];
    void add(int a, int b) => edges.add(_GEdge(a, b, .05 + r.next() * .4));
    final co = of(0), pr = of(1), ca = of(2), ma = of(3), ct = of(4), di = of(5), re = of(6), ho = of(7), pj = of(8), op = of(9), sg = of(10);
    for (final p in pr) {
      add(p, pick(co));
      add(p, pick(ca));
      add(p, pick(ma));
    }
    for (final x in ma) {
      add(x, pick(ct));
    }
    for (final d in di) {
      add(d, pick(ct));
      add(d, pick(ca));
      if (r.next() < .5) add(d, pick(ma));
    }
    for (final x in re) {
      add(x, pick(ct));
      add(x, pick(ca));
    }
    for (final x in ho) {
      add(x, pick(ct));
    }
    for (final x in pj) {
      add(x, pick(ho));
      add(x, pick(ct));
    }
    for (final o in op) {
      add(o, pick(pr));
      add(o, pick(di));
    }
    for (final s in sg) {
      add(s, pick([...ma, ...di, ...op]));
    }
    path = [co[0], pr[0], ma[0], di[0], op[0]];
    for (var k = 0; k < 4; k++) {
      final e = _GEdge(path[k], path[k + 1], 0);
      edges.add(e);
      pathEdges.add(e);
    }
    final onPath = path.toSet();
    for (final e in edges) {
      e.important = onPath.contains(e.a) || onPath.contains(e.b);
    }
    adjacency = List.generate(nodes.length, (_) => <int>[]);
    for (var i = 0; i < edges.length; i++) {
      adjacency[edges[i].a].add(i);
      adjacency[edges[i].b].add(i);
    }
  }

  final List<_GNode> nodes = [];
  final List<_GEdge> edges = [];
  final List<_GEdge> pathEdges = [];
  late final List<int> path;
  late final List<List<int>> adjacency;
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.progress,
    required this.clock,
    required this.pointer,
    required this.motion,
    required this.model,
    required this.typeNames,
    required this.pathLabels,
    required this.labels,
  }) : super(repaint: Listenable.merge([progress, clock, pointer]));

  final ValueListenable<double> progress;
  final ValueListenable<double> clock;
  final ValueListenable<Offset?> pointer;
  final ResponsiveMotionController motion;
  final _GraphModel model;
  final List<String> typeNames;
  final List<String> pathLabels;
  final LabelCache labels;

  static const _sizes = [3.6, 2.4, 3.0, 4.0, 3.0, 3.4, 2.8, 2.8, 3.0, 4.2, 1.3];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = progress.value;
    final tt = motion.reduced ? 0.0 : clock.value;
    final mob = motion.compact;
    final ptr = pointer.value;
    final grow = Motion.easeOut(Motion.seg(p, 0, .3));
    final sc = math.min(w, h) * .205 * Motion.lerp(.55, 1, grow);
    final cx = mob ? w * .5 : (motion.rtl ? w * .36 : w * .63), cy = mob ? h * .62 : h * .53;
    final reveal = Motion.lerp(.1, .5, Motion.seg(p, .1, .42));
    final focus = Motion.seg(p, .44, .5);
    final px = ptr == null ? 0.0 : ptr.dx / w - .5, py = ptr == null ? 0.0 : ptr.dy / h - .5;
    final ay = .4 + p * 1.4 + tt * .035 + (mob ? 0 : px * .5);
    final ax = mob ? -.18 : -.22 + py * .3;
    final ca = math.cos(ay), sa = math.sin(ay), cb = math.cos(ax), sb = math.sin(ax);

    // Projection; z > 0 faces the viewer (same convention as the globe).
    final proj = <(Offset, double, double)>[];
    for (final n in model.nodes) {
      final x = n.x * ca + n.z * sa;
      var z = -n.x * sa + n.z * ca;
      final y = n.y * cb - z * sb;
      z = n.y * sb + z * cb;
      final f = 1 / (1 - z * .16);
      proj.add((Offset(cx + x * sc * f, cy - y * sc * f), z, f));
    }

    var hover = -1;
    if (!mob && ptr != null) {
      var best = 16.0;
      for (var i = 0; i < proj.length; i++) {
        final d = (proj[i].$1 - ptr).distance;
        if (d < best) {
          best = d;
          hover = i;
        }
      }
    }
    final hl = <int>{};
    if (hover >= 0) {
      hl.add(hover);
      for (final ei in model.adjacency[hover]) {
        hl
          ..add(model.edges[ei].a)
          ..add(model.edges[ei].b);
      }
    }
    final ps = [Motion.seg(p, .44, .5), Motion.seg(p, .5, .58), Motion.seg(p, .62, .71), Motion.seg(p, .74, .83), Motion.seg(p, .86, .95)];
    final line = Paint()..blendMode = BlendMode.plus;

    void edge(_GEdge e, bool far) {
      final a = proj[e.a], b = proj[e.b];
      if (((a.$2 + b.$2) / 2 < 0) != far) return;
      if (model.pathEdges.contains(e) || e.threshold > reveal) return;
      var al = (e.important ? .2 : .07) * (.6 + .4 * ((a.$3 + b.$3) / 2)) * (1 - focus * (e.important ? .2 : .6));
      if (hover >= 0) al = (e.a == hover || e.b == hover) ? .8 : al * .35;
      line
        ..color = TradeGraphVisualization.colors[model.nodes[e.a].type].withValues(alpha: Motion.clamp01(al))
        ..strokeWidth = e.important || al > .5 ? 1.2 : .8;
      canvas.drawLine(a.$1, b.$1, line);
    }

    void node(int i) {
      final n = model.nodes[i];
      final (o, z, f) = proj[i];
      final ip = model.path.indexOf(i);
      var a = (.25 + .75 * ((z + 2) / 4)).clamp(.25, 1.0) * (1 - focus * .62);
      if (ip >= 0 && ps[ip] > 0) a = 1;
      if (hover >= 0) a = hl.contains(i) ? 1 : a * .3;
      final c = TradeGraphVisualization.colors[n.type];
      final sz = _sizes[n.type] * f * (ip >= 0 ? Motion.lerp(1, 2, ps[ip]) : 1);
      Glow.draw(canvas, c, o, sz * (n.type == 9 ? 7 : 4.5), a * (n.type == 9 ? .8 : .5));
      _ShapeIcon.draw(canvas, TradeGraphVisualization.shapes[n.type], o, sz, c.withValues(alpha: a));
      if (ip >= 0 && ps[ip] > 0) {
        final u = ps[ip];
        canvas.drawCircle(
            o,
            sz + 9 + math.sin(tt * 2) * 1.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = (ip == 4 ? Sem.gold : Sem.aiSoft).withValues(alpha: .5 * u));
        labels.pill(canvas, pathLabels[ip], o - Offset(0, sz + 26), ip == 4 ? Sem.gold : Sem.aiSoft, u, mob ? 11.5 : 12.5);
      }
    }

    final order = List.generate(proj.length, (i) => i)..sort((a, b) => proj[a].$2.compareTo(proj[b].$2));
    final onPath = model.path.toSet();

    // Far layer → luminous world → near layer.
    for (final e in model.edges) {
      edge(e, true);
    }
    for (final i in order) {
      if (proj[i].$2 <= 0 && !onPath.contains(i)) node(i);
    }
    paintGlobe(canvas, GlobeView(center: Offset(cx, cy), radius: sc * .98, lon0: -ay * 180 / math.pi, lat0: ax * 180 / math.pi),
        alpha: .95, sparse: mob, dot: 1.1, highlightSpain: .6, highlightGcc: .6);
    for (final e in model.edges) {
      edge(e, false);
    }

    // The traced path: glowing, with travelling light; the last leg is gold.
    final glowLine = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < model.pathEdges.length; k++) {
      final u = ps[k + 1];
      if (u <= 0) continue;
      final e = model.pathEdges[k];
      final a = proj[e.a].$1, b = proj[e.b].$1;
      final c = k == 3 ? Sem.gold : Sem.aiSoft;
      final end = Offset.lerp(a, b, u)!;
      canvas.drawLine(a, end, glowLine
        ..strokeWidth = 6
        ..color = c.withValues(alpha: .22));
      canvas.drawLine(a, end, glowLine
        ..strokeWidth = 1.8
        ..color = c.withValues(alpha: .95));
      Glow.draw(canvas, c, Offset.lerp(a, b, ((tt * .6 + k * .25) % 1) * u)!, 10, .9);
    }
    for (final i in order) {
      if (proj[i].$2 > 0 || onPath.contains(i)) node(i);
    }

    if (hover >= 0) {
      final tp = labels.get(typeNames[model.nodes[hover].type], Colors.white, 12);
      final at = proj[hover].$1 + const Offset(12, -34);
      final box = RRect.fromRectAndRadius(Rect.fromLTWH(at.dx, at.dy, tp.width + 18, tp.height + 10), const Radius.circular(8));
      canvas.drawRRect(box, Paint()..color = const Color(0xF20E0B1F));
      canvas.drawRRect(
          box,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = AppColors.violetSoft.withValues(alpha: .45));
      tp.paint(canvas, at + const Offset(9, 5));
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) => old.model != model || old.motion != motion;
}

class _ShapeIcon extends CustomPainter {
  _ShapeIcon(this.shape, this.color);
  final GraphShape shape;
  final Color color;

  static void draw(Canvas canvas, GraphShape s, Offset c, double sz, Color color) {
    final fill = Paint()..color = color;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;
    switch (s) {
      case GraphShape.dot:
        canvas.drawCircle(c, sz, fill);
      case GraphShape.square:
        canvas.drawRect(Rect.fromCenter(center: c, width: sz * 1.6, height: sz * 1.6), fill);
      case GraphShape.ring:
        canvas.drawCircle(c, sz, ring);
      case GraphShape.diamond:
        canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy - sz)
              ..lineTo(c.dx + sz, c.dy)
              ..lineTo(c.dx, c.dy + sz)
              ..lineTo(c.dx - sz, c.dy)
              ..close(),
            fill);
      case GraphShape.triangle:
        canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy - sz)
              ..lineTo(c.dx + sz, c.dy + sz * .8)
              ..lineTo(c.dx - sz, c.dy + sz * .8)
              ..close(),
            ring);
      case GraphShape.star:
        canvas.drawCircle(c, sz, fill);
        canvas.drawCircle(c, sz * 1.8, ring);
    }
  }

  @override
  void paint(Canvas canvas, Size size) => draw(canvas, shape, size.center(Offset.zero), 3.6, color);

  @override
  bool shouldRepaint(_ShapeIcon old) => old.shape != shape || old.color != color;
}
