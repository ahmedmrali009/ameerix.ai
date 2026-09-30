import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../theme/app_colors.dart';
import 'geo_data.dart';
import 'motion.dart';

/// Light, colour and geometry helpers shared by the cinematic painters.
///
/// Semantic colour (see [AppColors]): blue = data, violet = AI processing,
/// cyan = connections, gold = commercial opportunity.
class Sem {
  const Sem._();
  static const Color data = AppColors.electric;
  static const Color dataSoft = AppColors.blueSoft;
  static const Color ai = AppColors.violet;
  static const Color aiSoft = AppColors.violetSoft;
  static const Color link = AppColors.cyan;
  static const Color gold = AppColors.gold;
  static const Color energy = AppColors.magenta;
  static const Color ink = Color(0xFFECF2FF);
  static const Color greyBlue = Color(0xFF7084AC);

  static Color mix(Color a, Color b, double t) => Color.lerp(a, b, Motion.clamp01(t))!;
}

/// Soft additive light (bloom). Cheap radial gradient; used sparingly.
class Glow {
  const Glow._();
  static final Paint _p = Paint()..blendMode = BlendMode.plus;

  static void draw(Canvas canvas, Color c, Offset at, double radius, double alpha) {
    if (alpha <= .004 || radius <= .5) return;
    final a = Motion.clamp01(alpha);
    _p.shader = ui.Gradient.radial(at, radius, [
      c.withValues(alpha: a),
      c.withValues(alpha: .6 * a),
      c.withValues(alpha: .16 * a),
      c.withValues(alpha: 0),
    ], const [0, .16, .42, 1]);
    canvas.drawCircle(at, radius, _p);
  }
}

void dotAt(Canvas canvas, Offset at, double r, Color c, double alpha) {
  if (alpha <= .004) return;
  canvas.drawCircle(at, r, Paint()..color = c.withValues(alpha: Motion.clamp01(alpha)));
}

/// TextPainter cache for painters (alpha quantised to keep it small).
class LabelCache {
  LabelCache(this.style, this.direction);
  final TextStyle style;
  final TextDirection direction;
  final Map<String, TextPainter> _cache = {};

  TextPainter get(String text, Color color, double size, [FontWeight weight = FontWeight.w500]) {
    final a = (color.a * 20).round() / 20;
    final key = '$text|$a|${color.toARGB32() & 0xFFFFFF}|$size|${weight.value}';
    if (_cache.length > 400) _cache.clear();
    return _cache.putIfAbsent(
      key,
      () => paintLabel(text, style.copyWith(color: color.withValues(alpha: a), fontSize: size, fontWeight: weight), direction: direction),
    );
  }

  /// A small dark pill with a coloured edge — used for path labels.
  void pill(Canvas canvas, String text, Offset center, Color edge, double alpha, [double size = 12.5]) {
    if (alpha <= .01) return;
    final tp = get(text, const Color(0xFFFFFFFF).withValues(alpha: alpha), size, FontWeight.w600);
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: tp.width + 20, height: 24), const Radius.circular(12));
    canvas.drawRRect(r, Paint()..color = const Color(0xFF050A18).withValues(alpha: .86 * alpha));
    canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = edge.withValues(alpha: .6 * alpha));
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}

// ---------------------------------------------------------------------------
// Procedural dotted earth
// ---------------------------------------------------------------------------

typedef Vec3 = (double, double, double);

Vec3 latLon(double lat, double lon) {
  final a = lat * math.pi / 180, b = lon * math.pi / 180;
  return (math.cos(a) * math.sin(b), math.sin(a), math.cos(a) * math.cos(b));
}

/// Land points decoded once. `flags`: 1 = Spain, 2 = GCC.
class GeoData {
  GeoData._(this.xyz, this.flags, this.gcc);
  final Float32List xyz;
  final Uint8List flags;
  final List<(double, double)> gcc;

  static GeoData? _i;
  static GeoData get instance => _i ??= _load();

  static List<(double, double)> _decode(String s) {
    final out = <(double, double)>[];
    for (final row in s.split(';')) {
      final i = row.indexOf(':');
      if (i < 0) continue;
      final lat = double.parse(row.substring(0, i));
      for (final lon in row.substring(i + 1).split(',')) {
        out.add((lat, double.parse(lon)));
      }
    }
    return out;
  }

  static GeoData _load() {
    final w = _decode(kWorldLand);
    final xyz = Float32List(w.length * 3);
    final flags = Uint8List(w.length);
    for (var i = 0; i < w.length; i++) {
      final (la, lo) = w[i];
      final v = latLon(la, lo);
      xyz[i * 3] = v.$1;
      xyz[i * 3 + 1] = v.$2;
      xyz[i * 3 + 2] = v.$3;
      if (la > 35.8 && la < 43.9 && lo > -9.6 && lo < 3.4) flags[i] = 1;
      if (la > 16 && la < 30.6 && lo > 36.5 && lo < 60 && !(lo < 40 && la > 27.5)) flags[i] = 2;
    }
    return GeoData._(xyz, flags, _decode(kGccLand));
  }
}

/// Places used by the corridor visuals (lat, lon).
class Places {
  const Places._();
  static const spain = (40.2, -3.7);
  static const coreAnchor = (50.0, 22.0);
  static const markets = <String, (double, double)>{
    'uae': (24.4, 54.4),
    'ksa': (24.7, 46.7),
    'qatar': (25.3, 51.5),
    'kuwait': (29.4, 47.9),
    'oman': (21.8, 57.5),
    'bahrain': (26.1, 50.55),
  };
}

/// Orthographic view of the globe: centre (lon0, lat0), screen centre, radius.
class GlobeView {
  GlobeView({required this.center, required this.radius, required double lon0, required double lat0})
      : _cl = math.cos(lon0 * math.pi / 180),
        _sl = math.sin(lon0 * math.pi / 180),
        _ct = math.cos(lat0 * math.pi / 180),
        _st = math.sin(lat0 * math.pi / 180);

  final Offset center;
  final double radius;
  final double _cl, _sl, _ct, _st;

  /// Rotated coordinates; z > 0 faces the viewer.
  Vec3 rotate(double x, double y, double z) {
    final x1 = x * _cl - z * _sl, z1 = x * _sl + z * _cl;
    return (x1, y * _ct - z1 * _st, y * _st + z1 * _ct);
  }

  /// Screen position, depth and whether the point is hidden behind the globe.
  (Offset, double, bool) project(Vec3 v) {
    final (x, y, z) = rotate(v.$1, v.$2, v.$3);
    final hidden = z < 0 && math.sqrt(x * x + y * y) < .995;
    return (center + Offset(radius * x, -radius * y), z, hidden);
  }
}

/// Samples a lifted great-circle arc (a → b) in 3D.
List<Vec3> arc3(Vec3 a, Vec3 b, double altA, double altB, double lift, [int n = 48]) {
  final out = <Vec3>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    var x = Motion.lerp(a.$1, b.$1, t), y = Motion.lerp(a.$2, b.$2, t), z = Motion.lerp(a.$3, b.$3, t);
    final m = math.sqrt(x * x + y * y + z * z);
    final r = Motion.lerp(altA, altB, t) + lift * math.sin(math.pi * t);
    x = x / m * r;
    y = y / m * r;
    z = z / m * r;
    out.add((x, y, z));
  }
  return out;
}

/// Draws [pts] from u0 to u1 as a glowing line; segments behind the globe dim.
void drawArc(Canvas canvas, GlobeView v, List<Vec3> pts, Color c, double alpha, {double u0 = 0, double u1 = 1, double width = 1.2}) {
  if (alpha <= .004 || u1 <= u0) return;
  final n = pts.length - 1;
  final i0 = (u0 * n).floor(), i1 = math.min(n, (u1 * n).ceil());
  final q = [for (var i = i0; i <= i1; i++) v.project(pts[i])];
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus;
  for (final pass in const [0, 1]) {
    paint.strokeWidth = pass == 1 ? width : width * 4.5;
    for (var k = 0; k < q.length - 1; k++) {
      final f = (q[k].$3 || q[k + 1].$3) ? .16 : 1.0;
      paint.color = c.withValues(alpha: Motion.clamp01((pass == 1 ? alpha : alpha * .14) * f));
      canvas.drawLine(q[k].$1, q[k + 1].$1, paint);
    }
  }
}

(Offset, double, bool) arcAt(GlobeView v, List<Vec3> pts, double u) {
  final n = pts.length - 1;
  final f = Motion.clamp01(u) * n;
  final i = math.min(n - 1, f.floor());
  final t = f - i;
  final a = pts[i], b = pts[i + 1];
  return v.project((Motion.lerp(a.$1, b.$1, t), Motion.lerp(a.$2, b.$2, t), Motion.lerp(a.$3, b.$3, t)));
}

/// Paints the dotted earth: back light, body, graticule, land as points of
/// light (Spain / GCC optionally highlighted), terminator shade and rim light.
void paintGlobe(Canvas canvas, GlobeView v,
    {double alpha = 1, double highlightSpain = 0, double highlightGcc = 0, bool sparse = false, double dot = 1.7}) {
  final c = v.center, r = v.radius;
  Glow.draw(canvas, Sem.ai, c + Offset(-r * .55, -r * .62), r * 1.45, .13 * alpha);
  Glow.draw(canvas, AppColors.blue, c, r * 1.4, .2 * alpha);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = ui.Gradient.radial(c + Offset(-r * .38, -r * .46), r * 1.05, [
        const Color(0xFF18305F).withValues(alpha: .92 * alpha),
        const Color(0xFF09142E).withValues(alpha: .96 * alpha),
        const Color(0xFF040918).withValues(alpha: alpha),
      ], const [0, .55, 1]),
  );

  // Graticule.
  final grid = Path();
  void line(Iterable<Vec3> pts) {
    var pen = false;
    for (final p in pts) {
      final (x, y, z) = v.rotate(p.$1, p.$2, p.$3);
      if (z < 0) {
        pen = false;
        continue;
      }
      final o = c + Offset(r * x, -r * y);
      if (!pen) {
        grid.moveTo(o.dx, o.dy);
        pen = true;
      } else {
        grid.lineTo(o.dx, o.dy);
      }
    }
  }

  for (var la = -60; la <= 60; la += 30) {
    line([for (var lo = -180; lo <= 180; lo += 5) latLon(la.toDouble(), lo.toDouble())]);
  }
  for (var lo = -180; lo < 180; lo += 30) {
    line([for (var la = -85; la <= 85; la += 5) latLon(la.toDouble(), lo.toDouble())]);
  }
  canvas.drawPath(
      grid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Sem.data.withValues(alpha: .075 * alpha));

  // Land: points of light, brighter toward the viewer.
  final g = GeoData.instance;
  final paint = Paint();
  final n = g.flags.length;
  final step = sparse ? 2 : 1;
  for (var i = 0; i < n; i += step) {
    final (x, y, z) = v.rotate(g.xyz[i * 3], g.xyz[i * 3 + 1], g.xyz[i * 3 + 2]);
    if (z <= .03) continue;
    var col = Sem.dataSoft;
    var a = .14 + .5 * z * math.sqrt(z);
    var s = dot;
    final f = g.flags[i];
    if (f == 1 && highlightSpain > 0) {
      col = Sem.mix(Sem.dataSoft, const Color(0xFFBED7FF), highlightSpain);
      a = Motion.lerp(a, .62 + .38 * z, highlightSpain);
      s = dot * Motion.lerp(1, 1.35, highlightSpain);
    } else if (f == 2 && highlightGcc > 0) {
      col = Sem.mix(Sem.dataSoft, Sem.link, highlightGcc);
      a = Motion.lerp(a, .38 + .5 * z, highlightGcc);
      s = dot * Motion.lerp(1, 1.2, highlightGcc);
    }
    paint.color = col.withValues(alpha: Motion.clamp01(a * alpha));
    canvas.drawRect(Rect.fromCenter(center: c + Offset(r * x, -r * y), width: s, height: s), paint);
  }

  // Shade and rim light.
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = ui.Gradient.radial(c + Offset(r * .45, r * .5), r * 1.15, [
        const Color(0xFF02050E).withValues(alpha: .5 * alpha),
        const Color(0x0002050E),
      ]),
  );
  canvas.drawCircle(
    c,
    r * 1.1,
    Paint()
      ..shader = ui.Gradient.radial(c, r * 1.1, [
        Sem.data.withValues(alpha: 0),
        Sem.data.withValues(alpha: 0),
        Sem.data.withValues(alpha: .3 * alpha),
        Sem.dataSoft.withValues(alpha: .12 * alpha),
        Sem.data.withValues(alpha: 0),
      ], const [0, .82, .91, .96, 1]),
  );
}
