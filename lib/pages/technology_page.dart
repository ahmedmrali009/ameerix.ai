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
import '../widgets/visuals/architecture_diagram.dart';

class TechnologyPage extends StatelessWidget {
  const TechnologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.technology,
      metaTitle: (l) => l.metaTitleTechnology,
      metaDescription: (l) => l.metaDescTechnology,
      sections: [
        PageHero(
          eyebrow: l.techEyebrow,
          title: l.techPageTitle,
          body: l.techPageBody,
          actions: [
            AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, variant: ButtonVariant.secondary),
          ],
        ),
        const _ArchitectureSection(),
        const _ScoringSection(),
        const _AiSection(),
        const _DataSection(),
        const _SecuritySection(),
        const CtaSection(),
      ],
    );
  }
}

class _ArchitectureSection extends StatelessWidget {
  const _ArchitectureSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 960,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(child: SectionHeading(eyebrow: l.techEyebrow, title: l.archTitle, body: l.archBody)),
        end: const Reveal(delay: Duration(milliseconds: 120), child: ArchitectureDiagram()),
      ),
    );
  }
}

class _ScoringSection extends StatelessWidget {
  const _ScoringSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Section(
      tone: SectionTone.muted,
      child: ResponsiveGrid(
        minItemWidth: 360,
        maxColumns: 2,
        spacing: 20,
        children: [
          FeatureCard(icon: Icons.rule_outlined, title: l.scoringTitle, body: l.scoringBody),
          FeatureCard(icon: Icons.stairs_outlined, title: l.progressTitle, body: l.progressBody),
        ],
      ),
    );
  }
}

class _AiSection extends StatelessWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = SiteContent(l).aiPoints;
    return Section(
      tone: SectionTone.dark,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        start: Reveal(child: SectionHeading(title: l.aiTitle, body: l.aiBody)),
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

class _DataSection extends StatelessWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 980,
        gap: 72,
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Reveal(child: SectionHeading(title: content.modules[3].name, body: content.modules[3].description)),
            const Gap(28),
            Text(
              t.usesUppercase ? l.graphSourcesTitle.toUpperCase() : l.graphSourcesTitle,
              style: t.eyebrow.copyWith(color: AppColors.grey500),
            ),
            const Gap(8),
            const DataSourcesBlock(),
          ],
        ),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Reveal(child: Heading(l.dataPrinciplesTitle, style: t.h2, level: 2)),
            const Gap(28),
            ResponsiveGrid(
              minItemWidth: 220,
              maxColumns: 2,
              spacing: 14,
              children: [
                for (final p in content.dataPrinciples)
                  FeatureCard(icon: p.icon, title: p.title, body: p.body, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.dark,
      child: ResponsiveGrid(
        minItemWidth: 360,
        maxColumns: 2,
        spacing: 20,
        children: [
          HoverCard(
            hoverable: false,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(Icons.lock_outline, size: 48, filled: true),
                const Gap(24),
                Heading(l.securityTitle, style: t.h3, level: 2),
                const Gap(20),
                MarkerList(items: content.securityPoints, marker: ListMarker.check, small: true),
              ],
            ),
          ),
          HoverCard(
            hoverable: false,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(Icons.policy_outlined, size: 48, filled: true),
                const Gap(24),
                Heading(l.complianceTitle, style: t.h3, level: 2),
                const Gap(20),
                Text(l.complianceBody, style: t.body.copyWith(color: AppColors.grey400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
