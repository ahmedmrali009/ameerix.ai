import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum StatementMode { sequence, handOff, finale }

/// Full-viewport editorial statement whose words are revealed by scroll.
///
/// * [StatementMode.sequence]: lines reveal one after another.
/// * [StatementMode.handOff]: the first line recedes as the second arrives
///   ("The right market is only half the decision." → "Then find the right partner.").
/// * [StatementMode.finale]: lines reveal and a rule draws underneath.
///
/// Words rise out of a soft blur (a mask-like reveal). Selected lines get a
/// luminous treatment: [emphasis] lines the blue→violet intelligence
/// gradient, the [gold] line the opportunity gold. Words are split on spaces;
/// Chinese (no spaces) animates per line, so it works for every script.
class RevealText extends StatelessWidget {
  const RevealText({
    super.key,
    required this.lines,
    this.mode = StatementMode.sequence,
    this.heightFactor = 2.4,
    this.medium = false,
    this.emphasis = const {},
    this.gold,
    this.tone = SectionTone.dark,
    this.grid = false,
  });

  final List<String> lines;
  final StatementMode mode;
  final double heightFactor;
  final bool medium;
  final Set<int> emphasis;
  final int? gold;
  final SectionTone tone;

  /// A perspective data grid on the floor (network lines becoming a grid).
  final bool grid;

  @override
  Widget build(BuildContext context) {
    return PinnedStorySection(
      heightFactor: heightFactor,
      compactHeightFactor: heightFactor * .75,
      semanticLabel: lines.join(' '),
      builder: (context, progress, visible, size) {
        final t = AppTypography.of(context);
        final locale = Localizations.localeOf(context).languageCode;
        final base = medium ? (size.width * .056).clamp(34.0, 96.0) : (size.width * .064).clamp(38.0, 112.0);
        final latin = t.usesUppercase;
        final style = t.display.copyWith(
          fontSize: base,
          height: latin ? 1.0 : 1.3,
          letterSpacing: latin ? -base * .045 : 0,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        );
        final lineWords = [for (final l in lines) locale == 'zh' ? [l] : l.split(' ')];
        final palette = TonePalette.forTone(tone);
        return Stack(children: [
          Positioned.fill(child: ColoredBox(color: palette.background)),
          Positioned.fill(child: AmbientLighting(palette: palette)),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: Alignment(0, .25), radius: .7, colors: [Color(0x243B82F6), Color(0x003B82F6)]),
              ),
            ),
          ),
          if (grid)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) => CustomPaint(painter: _GridFloor(progress.value)),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(Breakpoints.gutter(context), 80, Breakpoints.gutter(context), 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: ExcludeSemantics(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (context, _) {
                      final p = progress.value;
                      final n = lines.length;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < n; i++) _line(lineWords[i], i, n, p, style, context),
                          if (mode == StatementMode.finale) ...[
                            const SizedBox(height: 40),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: Motion.easeOut(Motion.seg(p, .2, .9)),
                                child: Container(
                                  height: 1.5,
                                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.electric, AppColors.violet, Color(0x008B5CF6)])),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget _line(List<String> words, int i, int n, double p, TextStyle style, BuildContext context) {
    final a = i * (.7 / n), b = a + .28;
    Widget line = Wrap(
      children: [
        for (var k = 0; k < words.length; k++)
          Builder(builder: (context) {
            final r = Motion.easeOut(Motion.seg(p, a + k * .02, b + k * .02));
            Widget word = Text(k < words.length - 1 ? '${words[k]} ' : words[k], style: style);
            if (r < .99) {
              word = ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: (1 - r) * 8, sigmaY: (1 - r) * 8), child: word);
            }
            return Opacity(
              opacity: .06 + .94 * r,
              child: Transform.translate(offset: Offset(0, (1 - r) * style.fontSize! * .45), child: word),
            );
          }),
      ],
    );
    final grad = i == gold ? AppColors.opportunity : (emphasis.contains(i) ? AppColors.intelligence : null);
    if (grad != null) {
      line = ShaderMask(blendMode: BlendMode.srcIn, shaderCallback: (r) => grad.createShader(r), child: line);
    }
    if (mode == StatementMode.handOff && i == 0) {
      final d = Motion.seg(p, .5, .72);
      line = Opacity(
        opacity: 1 - d * .72,
        child: Transform.scale(scale: 1 - d * .12, alignment: AlignmentDirectional.centerStart.resolve(Directionality.of(context)), child: line),
      );
    }
    if (mode != StatementMode.handOff) {
      final z = Motion.seg(p, .8, 1);
      line = Transform.scale(scale: 1 - z * .04, child: line);
    }
    return line;
  }
}

class _GridFloor extends CustomPainter {
  _GridFloor(this.p);
  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final horizon = h * .52, vx = w / 2;
    final paint = Paint()..strokeWidth = 1;
    for (var k = -14; k <= 14; k++) {
      paint.color = AppColors.electric.withValues(alpha: .1);
      canvas.drawLine(Offset(vx + k * w * .012, horizon), Offset(vx + k * w * .12, h), paint);
    }
    final shift = (p * 3) % 1;
    for (var k = 0; k < 14; k++) {
      final t = (k + shift) / 14;
      final y = horizon + (h - horizon) * t * t;
      paint.color = AppColors.electric.withValues(alpha: .16 * t);
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridFloor old) => old.p != p;
}
