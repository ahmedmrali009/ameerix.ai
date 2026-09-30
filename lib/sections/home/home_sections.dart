import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../core/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../../models/site_content.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/reveal.dart';
import '../../widgets/section.dart';
import '../../widgets/site_header.dart';
import '../../widgets/text_blocks.dart';
import '../../widgets/visuals/dot_grid_background.dart';
import '../../widgets/visuals/market_score_visual.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final header = SiteHeader.heightOf(context);
    final spacing = Breakpoints.sectionSpacing(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(child: Pill(l.badgePilot, icon: Icons.fiber_manual_record)),
        const Gap(28),
        Reveal(delay: const Duration(milliseconds: 60), child: Eyebrow(l.homeEyebrow)),
        const Gap(20),
        Reveal(
          delay: const Duration(milliseconds: 120),
          child: Heading(l.homeHeroTitle, style: t.display, level: 1),
        ),
        const Gap(24),
        Reveal(
          delay: const Duration(milliseconds: 180),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(l.homeHeroBody, style: t.lead.copyWith(color: AppColors.grey400)),
          ),
        ),
        const Gap(36),
        Reveal(
          delay: const Duration(milliseconds: 240),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, showArrow: true),
              AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, variant: ButtonVariant.secondary),
            ],
          ),
        ),
        const Gap(32),
        Reveal(
          delay: const Duration(milliseconds: 300),
          child: Text(l.homeHeroNote, style: t.caption.copyWith(color: AppColors.grey500)),
        ),
      ],
    );

    return ConstrainedBox(
      // Fill most of the first screen on large displays without forcing
      // excessive height on short/mobile viewports.
      constraints: BoxConstraints(minHeight: screenHeight >= 760 && !Breakpoints.isCompact(context) ? screenHeight * 0.92 : 0.0),
      child: Section(
        tone: SectionTone.dark,
        topPadding: header + spacing * 0.9,
        bottomPadding: spacing,
        background: const DotGridBackground(focal: Alignment(0.75, -0.1), maxOpacity: 0.16),
        child: SplitLayout(
          breakpoint: 1000,
          gap: 56,
          startFlex: 7,
          endFlex: 5,
          stackGap: 56,
          crossAxisAlignment: CrossAxisAlignment.center,
          start: copy,
          end: const Reveal(
            delay: Duration(milliseconds: 250),
            child: Center(child: MarketScoreVisual()),
          ),
        ),
      ),
    );
  }
}

class WhatWeDoSection extends StatelessWidget {
  const WhatWeDoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pillars = SiteContent(l).pillars;
    return Section(
      tone: SectionTone.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(eyebrow: l.homeWhatEyebrow, title: l.homeWhatTitle, body: l.homeWhatBody, maxWidth: 820),
          ),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 3,
            children: [
              for (var i = 0; i < pillars.length; i++)
                FeatureCard(icon: pillars[i].icon, index: i, title: pillars[i].title, body: pillars[i].body),
            ],
          ),
        ],
      ),
    );
  }
}

class ProblemSection extends StatelessWidget {
  const ProblemSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final problems = SiteContent(l).problems;
    return Section(
      tone: SectionTone.midnight,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        start: Reveal(
          child: SectionHeading(eyebrow: l.problemEyebrow, title: l.problemTitle, body: l.problemBody),
        ),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < problems.length; i++)
              Reveal(
                delay: Duration(milliseconds: 70 * i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.lineDark)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: t.caption.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Expanded(child: Text(problems[i], style: t.h4.copyWith(color: AppColors.white, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ),
            Container(height: 1, color: AppColors.lineDark),
          ],
        ),
      ),
    );
  }
}

class SolutionSection extends StatelessWidget {
  const SolutionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final points = SiteContent(l).solutionPoints;
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(
          child: SectionHeading(eyebrow: l.solutionEyebrow, title: l.solutionTitle, body: l.solutionBody),
        ),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Tone(
              palette: TonePalette.dark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < points.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, thickness: 1, color: AppColors.lineDark),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconBadge(Icons.check, size: 36, filled: true),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(points[i], style: t.h4.copyWith(color: AppColors.white, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TechTeaserSection extends StatelessWidget {
  const TechTeaserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chips = SiteContent(l).techChips;
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(eyebrow: l.techEyebrow, title: l.techTitle, body: l.techBody),
              const Gap(32),
              AppButton(
                label: l.ctaReadTechnology,
                route: AppRoutes.technology,
                variant: ButtonVariant.secondary,
                showArrow: true,
              ),
            ],
          ),
        ),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: ResponsiveGrid(
            minItemWidth: 170,
            maxColumns: 2,
            spacing: 12,
            reveal: false,
            children: [
              for (final c in chips)
                HoverCard(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c,
                          style: AppTypography.of(context).label.copyWith(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
