import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../../motion/motion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/text_blocks.dart';

/// Padding that keeps pinned stages clear of the sticky header.
EdgeInsets stagePadding(BuildContext context, {double bottomFraction = .05}) {
  final size = MediaQuery.sizeOf(context);
  final compact = size.width < 960;
  return EdgeInsets.fromLTRB(
    Breakpoints.gutter(context),
    (compact ? 64 : 76) + size.height * (compact ? .02 : .04),
    Breakpoints.gutter(context),
    size.height * bottomFraction,
  );
}

/// Gives [child] the full available width but unbounded height, then
/// scales it down if it would not fit the stage (short laptop screens,
/// long translations). Guarantees no vertical overflow in pinned scenes.
class FitStage extends StatelessWidget {
  const FitStage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: SizedBox(width: c.maxWidth, child: child),
      ),
    );
  }
}

/// Places [child] centred on a point, without measuring it.
class CenteredAt extends StatelessWidget {
  const CenteredAt({super.key, required this.x, required this.y, required this.child, this.scale = 1, this.opacity = 1});

  final double x;
  final double y;
  final double scale;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (opacity <= .01) return const SizedBox.shrink();
    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        translation: const Offset(-.5, -.5),
        child: Transform.scale(
          scale: scale,
          child: Opacity(opacity: Motion.clamp01(opacity), child: child),
        ),
      ),
    );
  }
}

/// Caption column used by pinned stories: eyebrow, "03 / 08" counter,
/// cross-fading stage titles and a segmented progress rail.
class StageCaption extends StatelessWidget {
  const StageCaption({
    super.key,
    required this.eyebrow,
    required this.stages,
    required this.position,
    this.title,
    this.body,
    this.showCounter = true,
    this.footer,
  });

  final String eyebrow;
  final String? title;
  final String? body;

  /// (title, body) per stage.
  final List<(String, String?)> stages;

  /// Continuous stage position: 2.0 = third stage fully shown.
  final double position;
  final bool showCounter;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final compact = MediaQuery.sizeOf(context).width < 960;
    final current = position.round().clamp(0, stages.length - 1);
    return Tone(
      palette: TonePalette.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          if (title != null) ...[
            SizedBox(height: compact ? 10 : 18),
            Heading(title!, style: t.h2.copyWith(fontSize: compact ? 24 : null), level: 2),
          ],
          if (body != null && !compact) ...[
            const SizedBox(height: 12),
            Text(body!, style: t.bodySmall.copyWith(color: AppColors.grey400)),
          ],
          if (showCounter) ...[
            SizedBox(height: compact ? 10 : 20),
            ExcludeSemantics(
              child: Text(
                l.stageCounter((current + 1).toString().padLeft(2, '0'), stages.length.toString().padLeft(2, '0')),
                style: t.caption.copyWith(
                  color: AppColors.electric,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
          SizedBox(height: compact ? 8 : 14),
          SizedBox(
            height: compact ? 104 : 170,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < stages.length; i++)
                  _StageText(
                    title: stages[i].$1,
                    body: stages[i].$2,
                    offset: i - position,
                    compact: compact,
                    active: i == current,
                  ),
              ],
            ),
          ),
          SizedBox(height: compact ? 6 : 18),
          ExcludeSemantics(child: StageRail(count: stages.length, position: position)),
          if (footer != null) ...[const SizedBox(height: 18), footer!],
        ],
      ),
    );
  }
}

class _StageText extends StatelessWidget {
  const _StageText({required this.title, required this.body, required this.offset, required this.compact, required this.active});

  final String title;
  final String? body;
  final double offset;
  final bool compact;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final o = Motion.clamp01(1 - offset.abs() * 2.2);
    if (o <= .01) return const SizedBox.shrink();
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, offset * 18),
        child: Opacity(
          opacity: o,
          child: ExcludeSemantics(
            excluding: !active,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.h2.copyWith(fontSize: compact ? 21 : 32, color: AppColors.white)),
                if (body != null) ...[
                  SizedBox(height: compact ? 6 : 12),
                  Text(body!, style: (compact ? t.caption : t.body).copyWith(color: AppColors.grey400), maxLines: compact ? 3 : 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StageRail extends StatelessWidget {
  const StageRail({super.key, required this.count, required this.position});
  final int count;
  final double position;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(color: AppColors.lineDarkStrong, borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: Motion.clamp01(position + .5 - i),
                child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.electric, AppColors.violet]))),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Small outlined label: "Illustrative example", "Demo", …
class SceneTag extends StatelessWidget {
  const SceneTag(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC030712),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lineDarkStrong),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.grey300, fontSize: 11.5, letterSpacing: .3)),
    );
  }
}

/// Fictional, clearly labelled partner "intelligence dossier" used in demos:
/// match-strength ring (gold = priority), channel / geography / portfolio fit
/// bars and a verification state. Never a real company.
class DemoDistributorCard extends StatelessWidget {
  const DemoDistributorCard({super.key, required this.name, required this.values, this.width = 300, this.rows = 3});

  final String name;

  /// Category, geography, channel fit, portfolio compatibility (0–1).
  final List<double> values;
  final double width;

  /// Number of factor bars shown (0–3).
  final int rows;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final strength = (values.reduce((a, b) => a + b) / values.length * 100).round();
    final bars = [(l.matchF3, values[2]), (l.matchF2, values[1]), (l.matchF4, values[3])];
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEB14203C), Color(0xF008101E)],
        ),
        border: Border.all(color: const Color(0x47F4C76B)),
        boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 60, spreadRadius: -28, offset: Offset(0, 24))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CustomPaint(
                  painter: _RingPainter(strength / 100),
                  child: Center(
                    child: Text('$strength',
                        style: t.caption.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.demoDistributor(name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.label.copyWith(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(l.dossierMatch, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey500, fontSize: 11)),
                ]),
              ),
              SceneTag(l.labelDemo),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold, boxShadow: [BoxShadow(color: AppColors.gold, blurRadius: 8)]),
            ),
            const SizedBox(width: 6),
            Flexible(child: Text(l.dossierPriority, style: t.caption.copyWith(color: AppColors.gold, fontSize: 11))),
          ]),
          for (var i = 0; i < rows.clamp(0, 3); i++)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(bars[i].$1,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 11.5)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.lineDarkStrong, borderRadius: BorderRadius.circular(3)),
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: bars[i].$2,
                        child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.blue, AppColors.cyan]))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.lineDark))),
            child: Row(children: [
              Expanded(child: Text(l.dossierVerification, style: t.caption.copyWith(color: AppColors.grey400, fontSize: 11))),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green, boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 6)]),
              ),
              const SizedBox(width: 6),
              Text(l.dossierChecked, style: t.caption.copyWith(color: const Color(0xFFCFFAE8), fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - 2.5);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = AppColors.gold.withValues(alpha: .15);
    canvas.drawArc(r, 0, math.pi * 2, false, p);
    p
      ..color = AppColors.gold
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

/// Illustrative demo data shared by several scenes. Values are
/// demonstration-only and always rendered with an "Illustrative"/"Demo" tag.
class DemoData {
  const DemoData._();

  /// Plan order of the six GCC markets with illustrative scores
  /// (82/74 for UAE/KSA come from the business plan's own worked example).
  static List<(String, int)> markets(AppLocalizations l) => [
        (l.countryBahrain, 51),
        (l.countryKuwait, 58),
        (l.countryOman, 54),
        (l.countryQatar, 63),
        (l.countryKsa, 74),
        (l.countryUae, 82),
      ];

  static const List<(String, List<double>)> distributors = [
    ('A', [.93, .86, .9, .82]),
    ('B', [.88, .9, .78, .85]),
    ('C', [.82, .8, .86, .91]),
  ];
}
