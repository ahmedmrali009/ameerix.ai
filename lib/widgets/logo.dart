import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// The Ameerix mark: an open "A" whose apex joins two markets, with a node
/// at its centre. Drawn in code so it stays crisp at every size.
class AmeerixMark extends StatelessWidget {
  const AmeerixMark({super.key, this.size = 30, this.foreground = Colors.white, this.background = const Color(0xFF030712)});

  final double size;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(foreground, background)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.fg, this.bg);
  final Color fg;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(22 * s));
    canvas.drawRRect(rrect, Paint()..color = bg);
    final border = Paint()
      ..color = fg.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect.deflate(0.5), border);
    final stroke = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(28 * s, 76 * s)
      ..lineTo(50 * s, 24 * s)
      ..lineTo(72 * s, 76 * s);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(Offset(50 * s, 60 * s), 6.5 * s, Paint()..color = fg);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.fg != fg || old.bg != bg;
}

/// Mark + wordmark. The wordmark is always set in Latin (brand name).
class AmeerixLogo extends StatelessWidget {
  const AmeerixLogo({super.key, this.showTagline = false, this.color = Colors.white, this.linked = true});

  final bool showTagline;
  final Color color;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AmeerixMark(size: 30, foreground: color, background: color == Colors.white ? const Color(0xFF030712) : Colors.white),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.brandName,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontFamily: AppTypography.latinFamily,
                fontSize: 17,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.2,
                color: color,
              ),
            ),
            if (showTagline)
              Text(
                'MARKET INTELLIGENCE',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: AppTypography.latinFamily,
                  fontSize: 9.5,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
    if (!linked) return Semantics(label: l.appTitle, child: ExcludeSemantics(child: logo));
    return Pressable(
      route: AppRoutes.home,
      semanticLabel: l.a11yLogo,
      excludeChildSemantics: true,
      builder: (context, s) => FocusRing(visible: s.focused, radius: 8, child: logo),
    );
  }
}
