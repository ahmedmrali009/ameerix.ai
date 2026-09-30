import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/reveal.dart';
import '../../widgets/section.dart';
import '../../widgets/site_header.dart';
import '../../widgets/text_blocks.dart';
import '../../widgets/visuals/dot_grid_background.dart';

/// Dark introductory band at the top of inner pages. Contains the page's
/// single `<h1>`.
class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.body,
    this.actions = const [],
    this.trailing,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String? body;
  final List<Widget> actions;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final spacing = Breakpoints.sectionSpacing(context);
    final header = SiteHeader.heightOf(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(child: Eyebrow(eyebrow)),
        const Gap(24),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Heading(title, style: t.h1, level: 1),
          ),
        ),
        if (body != null) ...[
          const Gap(24),
          Reveal(
            delay: const Duration(milliseconds: 160),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(body!, style: t.lead.copyWith(color: AppColors.grey400)),
            ),
          ),
        ],
        if (actions.isNotEmpty) ...[
          const Gap(36),
          Reveal(
            delay: const Duration(milliseconds: 240),
            child: Wrap(spacing: 12, runSpacing: 12, children: actions),
          ),
        ],
        if (footer != null) ...[const Gap(36), Reveal(delay: const Duration(milliseconds: 280), child: footer!)],
      ],
    );

    return Section(
      tone: SectionTone.dark,
      topPadding: header + spacing * 0.85,
      bottomPadding: spacing * 0.85,
      background: const DotGridBackground(focal: Alignment(0.8, -0.4), maxOpacity: 0.12),
      child: trailing == null
          ? content
          : SplitLayout(
              start: content,
              end: Reveal(delay: const Duration(milliseconds: 200), child: trailing!),
              startFlex: 6,
              endFlex: 5,
              crossAxisAlignment: CrossAxisAlignment.center,
              breakpoint: 980,
              stackGap: 56,
            ),
    );
  }
}
