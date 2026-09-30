import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../motion/light.dart';
import '../../motion/motion.dart';

/// The Ameerix intelligence core — the brand's signature visual object.
///
/// A translucent data cube inside a rotating lattice, two orbital rings with
/// travelling data points, a counter-rotating inner "processing" cube and the
/// Ameerix mark at its heart. Blue edges carry information entering; violet
/// energy rises with [energy] while the engine is analysing; an optional
/// [gold] trace marks the moment intelligence becomes opportunity.
///
/// It appears in the hero (floating over the Spain → GCC corridor), at the
/// centre of the Spain → GCC story, inside the product demo and in the final
/// call to action, so visitors learn to associate it with Ameerix.
void paintIntelligenceCore(Canvas canvas, Offset c, double s, double t, {double energy = .4, double alpha = 1, double gold = 0}) {
  if (alpha <= .01 || s < 2) return;
  final e = Motion.clamp01(energy);
  Glow.draw(canvas, Sem.ai, c, s * 5.2, (.14 + .34 * e) * alpha);
  Glow.draw(canvas, Sem.data, c, s * 3.2, (.2 + .08 * e) * alpha);
  if (gold > 0) Glow.draw(canvas, Sem.gold, c, s * 3, .22 * gold * alpha);

  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..blendMode = BlendMode.plus;

  // Orbital rings with travelling data points.
  const rings = [(2.25, .3, .38, Sem.data, 1.0), (1.85, .26, -.62, Sem.aiSoft, -1.3)];
  for (var k = 0; k < rings.length; k++) {
    final (rr, sq, ro, col, sp) = rings[k];
    final rx = s * rr, ry = s * rr * sq;
    stroke.color = col.withValues(alpha: Motion.clamp01((.2 + .22 * e) * alpha));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(ro);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), stroke);
    canvas.restore();
    for (var j = 0; j < 3; j++) {
      final th = t * .6 * sp + j * 2.094 + k;
      final p = c +
          Offset(rx * math.cos(th) * math.cos(ro) - ry * math.sin(th) * math.sin(ro),
              rx * math.cos(th) * math.sin(ro) + ry * math.sin(th) * math.cos(ro));
      Glow.draw(canvas, col, p, s * .32, .7 * alpha);
      dotAt(canvas, p, math.max(1, s * .045), Sem.ink, .9 * alpha);
    }
  }

  // Outer lattice cube.
  final ay = t * .32, ax = .52 + math.sin(t * .21) * .12;
  final outer = _cube(c, s, ay, ax);
  final faces = [
    for (final f in _faces) (f, f.fold<double>(0, (m, i) => m + outer[i].$2) / 4),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  for (final (f, z) in faces) {
    final path = Path()..moveTo(outer[f[0]].$1.dx, outer[f[0]].$1.dy);
    for (final i in f.skip(1)) {
      path.lineTo(outer[i].$1.dx, outer[i].$1.dy);
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = z > 0 ? Sem.ai.withValues(alpha: .05 * alpha) : AppBlue.face.withValues(alpha: Motion.clamp01((.06 + .05 * e) * alpha)));
  }
  for (final (a, b) in _edges) {
    final z = (outer[a].$2 + outer[b].$2) / 2;
    stroke
      ..strokeWidth = z > 0 ? 1 : 1.3
      ..color = z > 0 ? Sem.aiSoft.withValues(alpha: .28 * alpha) : Sem.dataSoft.withValues(alpha: Motion.clamp01((.62 + .3 * e) * alpha));
    canvas.drawLine(outer[a].$1, outer[b].$1, stroke);
  }
  for (final (p, z) in outer) {
    Glow.draw(canvas, z > 0 ? Sem.aiSoft : Sem.dataSoft, p, s * .22, (z > 0 ? .35 : .8) * alpha);
  }

  // Inner processing cube (counter-rotating, violet).
  final inner = _cube(c, s * .46, -ay * 1.5, ax + .4);
  stroke
    ..strokeWidth = 1
    ..color = Sem.aiSoft.withValues(alpha: Motion.clamp01((.35 + .45 * e) * alpha));
  for (final (a, b) in _edges) {
    canvas.drawLine(inner[a].$1, inner[b].$1, stroke);
  }
  Glow.draw(canvas, Sem.ai, c, s * 1.3, (.25 + .45 * e) * alpha);

  // The Ameerix mark.
  final m = s * .44;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - .36 * m, c.dy + .42 * m)
      ..lineTo(c.dx, c.dy - .42 * m)
      ..lineTo(c.dx + .36 * m, c.dy + .42 * m),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, s * .085)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: .95 * alpha),
  );
  dotAt(canvas, c + Offset(0, .2 * m), math.max(1.4, s * .06), Colors.white, .95 * alpha);
}

class AppBlue {
  const AppBlue._();
  static const Color face = Color(0xFF3B82F6);
}

const _cubeV = [(-1.0, -1.0, -1.0), (1.0, -1.0, -1.0), (1.0, 1.0, -1.0), (-1.0, 1.0, -1.0), (-1.0, -1.0, 1.0), (1.0, -1.0, 1.0), (1.0, 1.0, 1.0), (-1.0, 1.0, 1.0)];
const _edges = [(0, 1), (1, 2), (2, 3), (3, 0), (4, 5), (5, 6), (6, 7), (7, 4), (0, 4), (1, 5), (2, 6), (3, 7)];
const _faces = [
  [0, 1, 2, 3],
  [4, 5, 6, 7],
  [0, 1, 5, 4],
  [2, 3, 7, 6],
  [1, 2, 6, 5],
  [0, 3, 7, 4],
];

List<(Offset, double)> _cube(Offset c, double s, double ay, double ax) {
  final ca = math.cos(ay), sa = math.sin(ay), cb = math.cos(ax), sb = math.sin(ax);
  return [
    for (final (a, b, cc) in _cubeV)
      () {
        final x = a * ca + cc * sa, z = -a * sa + cc * ca;
        final y = b * cb - z * sb, z2 = b * sb + z * cb;
        final f = 1 / (1 + z2 * .18);
        return (c + Offset(x * s * f, y * s * f), z2);
      }(),
  ];
}

/// Stand-alone animated core (ticks only while [visible] and motion allowed).
class IntelligenceCore extends StatelessWidget {
  const IntelligenceCore({super.key, required this.size, required this.visible, this.energy = .5});

  final double size;
  final ValueListenable<bool> visible;
  final double energy;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AmbientClock(
        visible: visible,
        builder: (context, clock) => CustomPaint(
          size: Size.square(size),
          painter: _CorePainter(clock, energy),
        ),
      ),
    );
  }
}

class _CorePainter extends CustomPainter {
  _CorePainter(this.clock, this.energy) : super(repaint: clock);
  final ValueListenable<double> clock;
  final double energy;

  @override
  void paint(Canvas canvas, Size size) =>
      paintIntelligenceCore(canvas, size.center(Offset.zero), size.shortestSide * .18, clock.value, energy: energy);

  @override
  bool shouldRepaint(_CorePainter old) => old.energy != energy;
}
