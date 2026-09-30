import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'section.dart';

/// Semantic heading. [level] 1–6 maps to `<h1>`…`<h6>` on the web.
class Heading extends StatelessWidget {
  const Heading(this.text, {super.key, required this.style, this.level = 2, this.textAlign, this.color});

  final String text;
  final TextStyle style;
  final int level;
  final TextAlign? textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Tone.of(context);
    return Semantics(
      header: true,
      headingLevel: level,
      child: Text(text, textAlign: textAlign, style: style.copyWith(color: color ?? palette.heading)),
    );
  }
}

/// Small kicker label with a leading rule.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final label = t.usesUppercase ? text.toUpperCase() : text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [palette.accent.withValues(alpha: .15), palette.accent]),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(label, style: t.eyebrow.copyWith(color: palette.accent)),
        ),
      ],
    );
  }
}

/// Eyebrow + title + optional lead paragraph.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.body,
    this.center = false,
    this.maxWidth = 760,
    this.level = 2,
    this.large = false,
  });

  final String? eyebrow;
  final String title;
  final String? body;
  final bool center;
  final double maxWidth;
  final int level;

  /// Use the h1 size (page heroes / key statements).
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final align = center ? TextAlign.center : TextAlign.start;
    return Align(
      alignment: center ? Alignment.topCenter : AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[Eyebrow(eyebrow!, center: center), const Gap(20)],
            Heading(title, style: large ? t.h1 : t.h2, level: level, textAlign: align),
            if (body != null) ...[
              const Gap(20),
              Text(body!, textAlign: align, style: t.lead.copyWith(color: palette.body)),
            ],
          ],
        ),
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText(this.text, {super.key, this.small = false, this.lead = false, this.color, this.textAlign});

  final String text;
  final bool small;
  final bool lead;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final style = lead ? t.lead : (small ? t.bodySmall : t.body);
    return Text(text, textAlign: textAlign, style: style.copyWith(color: color ?? palette.body));
  }
}

/// A vertical list with check / dash markers.
class MarkerList extends StatelessWidget {
  const MarkerList({super.key, required this.items, this.marker = ListMarker.check, this.spacing = 14, this.small = false});

  final List<String> items;
  final ListMarker marker;
  final double spacing;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final style = (small ? t.bodySmall : t.body).copyWith(color: palette.body);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: small ? 2 : 3),
                child: _Marker(marker: marker, palette: palette, index: i),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(items[i], style: style)),
            ],
          ),
        ],
      ],
    );
  }
}

enum ListMarker { check, dash, number, cross }

class _Marker extends StatelessWidget {
  const _Marker({required this.marker, required this.palette, required this.index});
  final ListMarker marker;
  final TonePalette palette;
  final int index;

  @override
  Widget build(BuildContext context) {
    switch (marker) {
      case ListMarker.check:
        return ExcludeSemantics(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: palette.borderStrong)),
            child: Icon(Icons.check, size: 13, color: palette.heading),
          ),
        );
      case ListMarker.cross:
        return ExcludeSemantics(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: palette.borderStrong)),
            child: Icon(Icons.close, size: 12, color: palette.subtle),
          ),
        );
      case ListMarker.dash:
        return ExcludeSemantics(
          child: SizedBox(
            width: 20,
            height: 20,
            child: Center(child: Container(width: 10, height: 1.5, color: palette.heading)),
          ),
        );
      case ListMarker.number:
        return ExcludeSemantics(
          child: SizedBox(
            width: 24,
            child: Text(
              (index + 1).toString().padLeft(2, '0'),
              style: AppTypography.of(context).caption.copyWith(
                    color: palette.subtle,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        );
    }
  }
}

/// Small rounded tag.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.icon, this.inverted = false});

  final String text;
  final IconData? icon;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final fg = inverted ? palette.inverse : palette.heading;
    final bg = inverted ? palette.heading : Colors.transparent;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 12, 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: inverted ? palette.heading : palette.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 8)],
          Flexible(child: Text(text, style: t.caption.copyWith(color: fg, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

/// Muted informational note with an icon (status, disclaimers).
class NoteBox extends StatelessWidget {
  const NoteBox(this.text, {super.key, this.icon = Icons.info_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: palette.isDark ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: palette.subtle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: t.bodySmall.copyWith(color: palette.body))),
        ],
      ),
    );
  }
}
