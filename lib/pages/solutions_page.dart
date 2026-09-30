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

class SolutionsPage extends StatelessWidget {
  const SolutionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.solutions,
      metaTitle: (l) => l.metaTitleSolutions,
      metaDescription: (l) => l.metaDescSolutions,
      sections: [
        PageHero(
          eyebrow: l.solutionsEyebrow,
          title: l.solutionsTitle,
          body: l.solutionsBody,
          actions: [
            AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaViewIndustries, route: AppRoutes.industries, variant: ButtonVariant.secondary),
          ],
        ),
        const _SegmentsSection(),
        const _IdealCustomerSection(),
        const GccBuyersSection(tone: SectionTone.dark),
        const _PartnersSection(),
        const CtaSection(),
      ],
    );
  }
}

class _SegmentsSection extends StatelessWidget {
  const _SegmentsSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final segments = SiteContent(l).segments;

    Widget labelled(String label, String value, {bool strong = false}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.usesUppercase ? label.toUpperCase() : label,
              style: t.eyebrow.copyWith(color: AppColors.grey500, fontSize: 11),
            ),
            const Gap(6),
            Text(
              value,
              style: (strong ? t.label : t.bodySmall).copyWith(
                color: strong ? AppColors.black : AppColors.grey600,
              ),
            ),
          ],
        );

    return Section(
      tone: SectionTone.light,
      child: ResponsiveGrid(
        minItemWidth: 290,
        maxColumns: 3,
        children: [
          for (var i = 0; i < segments.length; i++)
            HoverCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(segments[i].icon),
                      const Spacer(),
                      ExcludeSemantics(
                        child: Text(
                          (i + 1).toString().padLeft(2, '0'),
                          style: t.caption.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Heading(segments[i].title, style: t.h3, level: 2),
                  const Gap(20),
                  labelled(l.labelNeed, segments[i].need),
                  const Gap(16),
                  Container(height: 1, color: AppColors.lineLight),
                  const Gap(16),
                  labelled(l.labelModules, segments[i].modules, strong: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IdealCustomerSection extends StatelessWidget {
  const _IdealCustomerSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final roles = SiteContent(l).roles;
    return Section(
      tone: SectionTone.muted,
      child: SplitLayout(
        breakpoint: 900,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(child: SectionHeading(eyebrow: l.idealEyebrow, title: l.idealTitle, body: l.idealBody)),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: HoverCard(
            hoverable: false,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(l.rolesTitle, style: t.h3, level: 3),
                const Gap(24),
                MarkerList(items: roles, marker: ListMarker.check),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnersSection extends StatelessWidget {
  const _PartnersSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.partnersEyebrow, title: l.partnersTitle, body: l.partnersBody)),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 3,
            spacing: 16,
            children: [
              for (final p in content.partnerTypes)
                FeatureCard(icon: p.icon, title: p.title, body: p.body, compact: true),
            ],
          ),
          const Gap(56),
          Reveal(
            child: Tone(
              palette: TonePalette.dark,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
                child: SplitLayout(
                  breakpoint: 800,
                  gap: 48,
                  startFlex: 2,
                  endFlex: 3,
                  stackGap: 24,
                  start: Heading(l.principlesTitle, style: t.h3, level: 3),
                  end: MarkerList(items: content.partnerPrinciples, marker: ListMarker.check),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
