import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../models/site_content.dart';
import '../sections/shared/content_sections.dart';
import '../sections/shared/cta_section.dart';
import '../sections/shared/page_hero.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/text_blocks.dart';

class IndustriesPage extends StatelessWidget {
  const IndustriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final industries = SiteContent(l).industries;
    return PageScaffold(
      path: AppRoutes.industries,
      metaTitle: (l) => l.metaTitleIndustries,
      metaDescription: (l) => l.metaDescIndustries,
      sections: [
        PageHero(
          eyebrow: l.industriesEyebrow,
          title: l.industriesTitle,
          body: l.industriesBody,
          actions: [
            AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaViewSolutions, route: AppRoutes.solutions, variant: ButtonVariant.secondary),
          ],
        ),
        Section(
          tone: SectionTone.light,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < industries.length; i++) ...[
                if (i > 0) const Gap(20),
                Reveal(child: IndustryDetailCard(item: industries[i], index: i)),
              ],
              const Gap(28),
              Reveal(child: NoteBox(l.industriesMoreNote)),
            ],
          ),
        ),
        const GccBuyersSection(tone: SectionTone.dark),
        const StatsSection(tone: SectionTone.muted),
        const CtaSection(),
      ],
    );
  }
}
