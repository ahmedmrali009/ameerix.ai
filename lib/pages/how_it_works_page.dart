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

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.howItWorks,
      metaTitle: (l) => l.metaTitleHowItWorks,
      metaDescription: (l) => l.metaDescHowItWorks,
      sections: [
        PageHero(
          eyebrow: l.howEyebrow,
          title: l.howTitle,
          body: l.howBody,
          actions: [
            AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaExplorePlatform, route: AppRoutes.platform, variant: ButtonVariant.secondary),
          ],
        ),
        const HowItWorksSection(tone: SectionTone.light, showLink: false, showHeading: false),
        const _ProcessSection(),
        const _LoopSection(),
        const CtaSection(),
      ],
    );
  }
}

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = SiteContent(l).processSteps;
    return Section(
      tone: SectionTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.processEyebrow, title: l.processTitle)),
          const Gap(48),
          ResponsiveGrid(
            minItemWidth: 200,
            maxColumns: 5,
            spacing: 16,
            children: [
              for (var i = 0; i < steps.length; i++)
                FeatureCard(icon: steps[i].icon, index: i, title: steps[i].title, body: steps[i].body, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoopSection extends StatelessWidget {
  const _LoopSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final metrics = SiteContent(l).metrics;
    return Section(
      tone: SectionTone.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SplitLayout(
            breakpoint: 900,
            gap: 72,
            start: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(Icons.autorenew_outlined, size: 48, filled: true),
                  const Gap(24),
                  Heading(l.loopTitle, style: t.h2, level: 2),
                  const Gap(20),
                  Text(l.loopBody, style: t.lead.copyWith(color: AppColors.grey400)),
                ],
              ),
            ),
            end: Reveal(
              delay: const Duration(milliseconds: 120),
              child: HoverCard(
                hoverable: false,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Heading(l.metricsTitle, style: t.h3, level: 3),
                    const Gap(24),
                    MarkerList(items: metrics, marker: ListMarker.number, spacing: 16),
                  ],
                ),
              ),
            ),
          ),
          const Gap(48),
          Reveal(child: NoteBox(l.adviceNote, icon: Icons.gavel_outlined)),
        ],
      ),
    );
  }
}
