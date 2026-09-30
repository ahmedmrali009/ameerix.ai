import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../models/site_content.dart';
import '../sections/shared/content_sections.dart';
import '../sections/shared/cta_section.dart';
import '../sections/shared/page_hero.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons.dart';
import '../widgets/cards.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/text_blocks.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.about,
      metaTitle: (l) => l.metaTitleAbout,
      metaDescription: (l) => l.metaDescAbout,
      sections: [
        PageHero(
          eyebrow: l.aboutEyebrow,
          title: l.aboutTitle,
          body: l.aboutBody,
          actions: [
            AppButton(label: l.ctaContactUs, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, variant: ButtonVariant.secondary),
          ],
        ),
        const _PurposeSection(),
        const _SpainSection(),
        const InternationalSection(tone: SectionTone.dark),
        const _CultureSection(),
        const _RoadmapSection(),
        const CtaSection(),
      ],
    );
  }
}

class _PurposeSection extends StatelessWidget {
  const _PurposeSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Section(
      tone: SectionTone.light,
      child: ResponsiveGrid(
        minItemWidth: 280,
        maxColumns: 3,
        children: [
          FeatureCard(icon: Icons.visibility_outlined, title: l.visionTitle, body: l.visionBody),
          FeatureCard(icon: Icons.flag_outlined, title: l.missionTitle, body: l.missionBody),
          FeatureCard(icon: Icons.lightbulb_outline, title: l.whyExistTitle, body: l.whyExistBody),
        ],
      ),
    );
  }
}

class _SpainSection extends StatelessWidget {
  const _SpainSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = SiteContent(l).spainPoints;
    return Section(
      tone: SectionTone.muted,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(child: SectionHeading(eyebrow: l.cityBarcelona, title: l.spainTitle, body: l.spainBody)),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: HoverCard(
            hoverable: false,
            padding: const EdgeInsets.all(32),
            child: MarkerList(items: points, marker: ListMarker.check, spacing: 18),
          ),
        ),
      ),
    );
  }
}

class _CultureSection extends StatelessWidget {
  const _CultureSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final culture = SiteContent(l).culture;
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 900,
        gap: 64,
        start: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading(l.cultureTitle, style: t.h2, level: 2),
              const Gap(28),
              MarkerList(items: culture, marker: ListMarker.number, spacing: 18),
            ],
          ),
        ),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: Tone(
            palette: TonePalette.dark,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(Icons.balance_outlined, size: 44),
                  const Gap(24),
                  Heading(l.ethicsTitle, style: t.h3, level: 3),
                  const Gap(14),
                  Text(l.ethicsBody, style: t.body.copyWith(color: AppColors.grey400)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapSection extends StatelessWidget {
  const _RoadmapSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final phases = SiteContent(l).roadmap;
    return Section(
      tone: SectionTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(title: l.roadmapTitle, body: l.roadmapBody)),
          const Gap(48),
          ResponsiveGrid(
            minItemWidth: 230,
            maxColumns: 4,
            spacing: 16,
            children: [
              for (var i = 0; i < phases.length; i++)
                HoverCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(l.phaseLabel('${i + 1}')),
                      const Gap(20),
                      Heading(phases[i].title, style: t.h3, level: 3),
                      const Gap(10),
                      Text(phases[i].body, style: t.bodySmall.copyWith(color: AppColors.grey600)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
