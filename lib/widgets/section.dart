import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../core/breakpoints.dart';
import '../theme/app_colors.dart';

/// Centres content and applies the responsive horizontal gutter.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = AppConfig.maxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = Breakpoints.gutter(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// A full-width page band in one of the cinematic environments
/// (see [SectionTone]), with its soft ambient lighting.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.child,
    this.tone = SectionTone.light,
    this.topPadding,
    this.bottomPadding,
    this.borderTop = false,
    this.background,
  });

  final Widget child;
  final SectionTone tone;
  final double? topPadding;
  final double? bottomPadding;
  final bool borderTop;

  /// Optional decorative layer painted behind the content.
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final palette = TonePalette.forTone(tone);
    final spacing = Breakpoints.sectionSpacing(context);
    Widget content = Padding(
      padding: EdgeInsets.only(top: topPadding ?? spacing, bottom: bottomPadding ?? spacing),
      child: ContentWidth(child: child),
    );
    if (background != null || palette.lighting.isNotEmpty) {
      content = Stack(
        children: [
          if (palette.lighting.isNotEmpty) Positioned.fill(child: ExcludeSemantics(child: AmbientLighting(palette: palette))),
          if (background != null) Positioned.fill(child: ExcludeSemantics(child: background!)),
          content,
        ],
      );
    }
    return Tone(
      palette: palette,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.background,
          border: borderTop ? Border(top: BorderSide(color: palette.border)) : null,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: palette.body),
          child: content,
        ),
      ),
    );
  }
}

/// Vertical spacing helper.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
