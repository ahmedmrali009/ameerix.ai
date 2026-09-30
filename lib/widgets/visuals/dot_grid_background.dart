import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Decorative dot grid that fades out from a focal point. Monochrome, cheap
/// to paint (a single CustomPainter, repaint only on resize).
class DotGridBackground extends StatelessWidget {
  const DotGridBackground({
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.spacing = 28,
    this.focal = const Alignment(0.6, -0.2),
    this.maxOpacity = 0.14,
  });

  final Color color;
  final double spacing;
  final Alignment focal;
  final double maxOpacity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DotGridPainter(color: color, spacing: spacing, focal: focal, maxOpacity: maxOpacity),
        size: Size.infinite,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color, required this.spacing, required this.focal, required this.maxOpacity});

  final Color color;
  final double spacing;
  final Alignment focal;
  final double maxOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = focal.alongSize(size);
    final radius = math.max(size.width, size.height) * 0.65;
    final paint = Paint();
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        final d = (Offset(x, y) - center).distance / radius;
        final o = (1 - d).clamp(0.0, 1.0) * maxOpacity;
        if (o < 0.01) continue;
        paint.color = color.withValues(alpha: o);
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) =>
      old.color != color || old.spacing != spacing || old.focal != focal || old.maxOpacity != maxOpacity;
}
